
import pool from "../config/database.js";

// =====================================================
// GET USER NOTIFICATIONS
// =====================================================

export async function getUserNotifications(
  userId,
  {
    status,
    type,
    limit = 30,
    offset = 0,
  } = {}
) {
  const conditions = [
    "userId = ?",
    "deliveryMethod = 'in_app'",
    "status IN ('new', 'viewed')",
  ];

  const values = [userId];

  if (status && ["new", "viewed"].includes(status)) {
    conditions.push("status = ?");
    values.push(status);
  }

  const allowedTypes = [
    "system",
    "trading",
    "wallet",
    "kyc",
    "asset",
    "security",
  ];

  if (type && allowedTypes.includes(type)) {
    conditions.push("type = ?");
    values.push(type);
  }

  const safeLimit = Math.min(
    Math.max(Number(limit) || 30, 1),
    100
  );

  const safeOffset = Math.max(
    Number(offset) || 0,
    0
  );

  const sql = `
    SELECT
      id,
      type,
      title,
      message,
      referenceType,
      referenceId,
      status,
      readAt,
      createdAt
    FROM notifications
    WHERE ${conditions.join(" AND ")}
    ORDER BY createdAt DESC
    LIMIT ? OFFSET ?
  `;

  values.push(safeLimit, safeOffset);

  const [rows] = await pool.query(sql, values);

  return rows;
}

// =====================================================
// GET SINGLE NOTIFICATION
// =====================================================

export async function getNotificationById(
  userId,
  notificationId
) {
  const sql = `
    SELECT
      id,
      type,
      title,
      message,
      referenceType,
      referenceId,
      status,
      readAt,
      createdAt
    FROM notifications
    WHERE id = ?
      AND userId = ?
      AND deliveryMethod = 'in_app'
      AND status IN ('new', 'viewed')
    LIMIT 1
  `;

  const [rows] = await pool.query(sql, [
    notificationId,
    userId,
  ]);

  return rows[0] || null;
}

// =====================================================
// MARK ONE NOTIFICATION AS VIEWED
// =====================================================

export async function markNotificationAsViewed(
  userId,
  notificationId
) {
  const sql = `
    UPDATE notifications
    SET
      status = 'viewed',
      readAt = COALESCE(readAt, CURRENT_TIMESTAMP)
    WHERE id = ?
      AND userId = ?
      AND deliveryMethod = 'in_app'
      AND status IN ('new', 'viewed')
  `;

  const [result] = await pool.query(sql, [
    notificationId,
    userId,
  ]);

  return result.affectedRows > 0;
}

// =====================================================
// MARK ALL NOTIFICATIONS AS VIEWED
// =====================================================

export async function markAllNotificationsAsViewed(
  userId
) {
  const sql = `
    UPDATE notifications
    SET
      status = 'viewed',
      readAt = CURRENT_TIMESTAMP
    WHERE userId = ?
      AND deliveryMethod = 'in_app'
      AND status = 'new'
  `;

  const [result] = await pool.query(sql, [userId]);

  return result.affectedRows;
}


// =====================================================
// NOTIFICATION PREFERENCE CONSTANTS
// =====================================================

export const NOTIFICATION_TYPES = [
  "system",
  "trading",
  "wallet",
  "kyc",
  "asset",
  "security",
];

const DEFAULT_NOTIFICATION_PREFERENCES = {
  inAppEnabled: true,
  emailEnabled: false,
  smsEnabled: false,
};

// =====================================================
// ENSURE USER NOTIFICATION PREFERENCES EXIST
// =====================================================

async function ensureUserNotificationPreferences(
  userId,
  connection = pool
) {
  const values = [];

  for (const type of NOTIFICATION_TYPES) {
    values.push(
      userId,
      type,
      DEFAULT_NOTIFICATION_PREFERENCES.inAppEnabled,
      DEFAULT_NOTIFICATION_PREFERENCES.emailEnabled,
      DEFAULT_NOTIFICATION_PREFERENCES.smsEnabled
    );
  }

  const placeholders = NOTIFICATION_TYPES
    .map(() => "(?, ?, ?, ?, ?)")
    .join(", ");

  await connection.execute(
    `
      INSERT IGNORE INTO user_notification_preferences (
        userId,
        notificationType,
        inAppEnabled,
        emailEnabled,
        smsEnabled
      )
      VALUES ${placeholders}
    `,
    values
  );
}

// =====================================================
// GET USER NOTIFICATION PREFERENCES
// =====================================================

export async function getUserNotificationPreferences(userId) {
  await ensureUserNotificationPreferences(userId);

  const [rows] = await pool.execute(
    `
      SELECT
        notificationType,
        inAppEnabled,
        emailEnabled,
        smsEnabled,
        createdAt,
        updatedAt
      FROM user_notification_preferences
      WHERE userId = ?
      ORDER BY FIELD(
        notificationType,
        'security',
        'wallet',
        'trading',
        'asset',
        'kyc',
        'system'
      )
    `,
    [userId]
  );

  return rows.map((row) => ({
    ...row,
    inAppEnabled: Boolean(row.inAppEnabled),
    emailEnabled: Boolean(row.emailEnabled),
    smsEnabled: Boolean(row.smsEnabled),
  }));
}

// =====================================================
// UPDATE USER NOTIFICATION PREFERENCES
// =====================================================

export async function updateUserNotificationPreferences(
  userId,
  preferences
) {
  if (!Array.isArray(preferences) || preferences.length === 0) {
    throw new Error("At least one notification preference is required.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    await ensureUserNotificationPreferences(
      userId,
      connection
    );

    for (const preference of preferences) {
      const {
        notificationType,
        inAppEnabled,
        emailEnabled,
        smsEnabled,
      } = preference;

      if (!NOTIFICATION_TYPES.includes(notificationType)) {
        throw new Error(
          `Unsupported notification type: ${notificationType}`
        );
      }

      const updates = [];
      const values = [];

      if (typeof inAppEnabled === "boolean") {
        updates.push("inAppEnabled = ?");
        values.push(inAppEnabled);
      }

      if (typeof emailEnabled === "boolean") {
        updates.push("emailEnabled = ?");
        values.push(emailEnabled);
      }

      if (typeof smsEnabled === "boolean") {
        updates.push("smsEnabled = ?");
        values.push(smsEnabled);
      }

      if (updates.length === 0) {
        throw new Error(
          `No valid delivery preferences supplied for ${notificationType}.`
        );
      }

      values.push(userId, notificationType);

      await connection.execute(
        `
          UPDATE user_notification_preferences
          SET ${updates.join(", ")}
          WHERE userId = ?
            AND notificationType = ?
        `,
        values
      );
    }

    await connection.commit();

    return await getUserNotificationPreferences(userId);
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// CHECK NOTIFICATION DELIVERY PREFERENCE
// =====================================================

export async function isNotificationChannelEnabled(
  userId,
  notificationType,
  deliveryMethod
) {
  if (!NOTIFICATION_TYPES.includes(notificationType)) {
    return false;
  }

  const channelColumns = {
    in_app: "inAppEnabled",
    email: "emailEnabled",
    sms: "smsEnabled",
  };

  const column = channelColumns[deliveryMethod];

  if (!column) {
    return false;
  }

  await ensureUserNotificationPreferences(userId);

  const [rows] = await pool.execute(
    `
      SELECT ${column} AS enabled
      FROM user_notification_preferences
      WHERE userId = ?
        AND notificationType = ?
      LIMIT 1
    `,
    [userId, notificationType]
  );

  return rows.length > 0 && Boolean(rows[0].enabled);
}

