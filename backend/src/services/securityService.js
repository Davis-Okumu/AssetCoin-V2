
import pool from "../config/database.js";

// =========================================================
// SECURITY SERVICE
// =========================================================

// =========================
// GET SECURITY SETTINGS
// =========================

async function getSecuritySettings(userId) {
  const [settings] = await pool.execute(
    `SELECT
      biometricEnabled,
      twoFactorEnabled,
      twoFactorMethod,
      twoFactorVerifiedAt,
      loginNotificationEnabled,
      passwordChangedAt,
      createdAt,
      updatedAt
    FROM user_security_settings
    WHERE userId = ?
    LIMIT 1`,
    [userId]
  );

  // Return default settings if an existing account
  // does not yet have a security settings record.
  if (settings.length === 0) {
    return {
      biometricEnabled: false,
      twoFactorEnabled: false,
      twoFactorMethod: null,
      twoFactorVerifiedAt: null,
      loginNotificationEnabled: true,
      passwordChangedAt: null,
      createdAt: null,
      updatedAt: null,
    };
  }

  return settings[0];
}

// =========================
// GET ACTIVE SESSIONS
// =========================

async function getActiveSessions(userId, currentSessionId = null) {
  const [sessions] = await pool.execute(
    `SELECT
      id,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      lastActiveAt,
      expiresAt,
      createdAt
    FROM user_sessions
    WHERE userId = ?
      AND revokedAt IS NULL
      AND expiresAt > CURRENT_TIMESTAMP
    ORDER BY lastActiveAt DESC`,
    [userId]
  );

  return sessions.map((session) => ({
    ...session,
    isCurrent: currentSessionId
      ? String(session.id) === String(currentSessionId)
      : false,
  }));
}

// =========================
// REVOKE INDIVIDUAL SESSION
// =========================


async function revokeSession(
  userId,
  sessionId,
  currentSessionId = null
) {
  if (
    currentSessionId !== null &&
    String(sessionId) === String(currentSessionId)
  ) {
    const error = new Error(
      "Use the logout endpoint to revoke your current session."
    );
    error.statusCode = 400;
    throw error;
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [result] = await connection.execute(
      `UPDATE user_sessions
       SET revokedAt = CURRENT_TIMESTAMP
       WHERE id = ?
         AND userId = ?
         AND revokedAt IS NULL
         AND expiresAt > CURRENT_TIMESTAMP`,
      [sessionId, userId]
    );

    if (result.affectedRows === 0) {
      const error = new Error(
        "Session not found or already revoked."
      );
      error.statusCode = 404;
      throw error;
    }

    await connection.execute(
      `INSERT INTO login_activity (
        userId,
        eventType,
        description
      )
      VALUES (?, 'session_revoked', ?)`,
      [
        userId,
        "A device session was revoked.",
      ]
    );

    await connection.commit();

    return {
      message: "Session revoked successfully.",
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =========================
// REVOKE OTHER SESSIONS
// =========================

async function revokeOtherSessions(
  userId,
  currentSessionId
) {
  if (!currentSessionId) {
    throw Object.assign(
      new Error(
        "The current session could not be identified."
      ),
      { statusCode: 400 }
    );
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [result] = await connection.execute(
      `UPDATE user_sessions
       SET revokedAt = CURRENT_TIMESTAMP
       WHERE userId = ?
         AND id != ?
         AND revokedAt IS NULL`,
      [
        userId,
        currentSessionId,
      ]
    );

    if (result.affectedRows > 0) {
      await connection.execute(
        `INSERT INTO login_activity (
          userId,
          eventType,
          description
        ) VALUES (?, 'session_revoked', ?)`,
        [
          userId,
          `Revoked ${result.affectedRows} other device session(s).`,
        ]
      );
    }

    await connection.commit();

    return {
      revokedCount: result.affectedRows,
      message: result.affectedRows > 0
        ? "Other device sessions have been logged out."
        : "There are no other active sessions.",
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =========================
// GET LOGIN ACTIVITY
// =========================

async function getLoginActivity(
  userId,
  limit = 30,
  offset = 0
) {
  const safeLimit = Math.min(
    Math.max(Number.parseInt(limit, 10) || 30, 1),
    100
  );

  const safeOffset = Math.max(
    Number.parseInt(offset, 10) || 0,
    0
  );

  const [activities] = await pool.execute(
    `SELECT
      id,
      eventType,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      description,
      createdAt
    FROM login_activity
    WHERE userId = ?
    ORDER BY createdAt DESC, id DESC
    LIMIT ? OFFSET ?`,
    [
      userId,
      safeLimit,
      safeOffset,
    ]
  );

  return activities;
}

// =========================
// UPDATE SECURITY SETTINGS
// =========================

async function updateSecuritySettings(
  userId,
  settings
) {
  const {
    biometricEnabled,
    loginNotificationEnabled,
  } = settings;

  const updates = [];
  const values = [];

  if (biometricEnabled !== undefined) {
    if (typeof biometricEnabled !== "boolean") {
      throw Object.assign(
        new Error("Biometric preference must be true or false."),
        { statusCode: 400 }
      );
    }

    updates.push("biometricEnabled = ?");
    values.push(biometricEnabled);
  }

  if (loginNotificationEnabled !== undefined) {
    if (typeof loginNotificationEnabled !== "boolean") {
      throw Object.assign(
        new Error("Login notification preference must be true or false."),
        { statusCode: 400 }
      );
    }

    updates.push("loginNotificationEnabled = ?");
    values.push(loginNotificationEnabled);
  }

  if (updates.length === 0) {
    throw Object.assign(
      new Error("No valid security settings were provided."),
      { statusCode: 400 }
    );
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // Ensure that existing accounts have a settings row.
    await connection.execute(
      `INSERT INTO user_security_settings (
        userId,
        biometricEnabled,
        twoFactorEnabled,
        loginNotificationEnabled
      ) VALUES (?, FALSE, FALSE, TRUE)
      ON DUPLICATE KEY UPDATE userId = userId`,
      [userId]
    );

    values.push(userId);

    await connection.execute(
      `UPDATE user_security_settings
       SET ${updates.join(", ")}
       WHERE userId = ?`,
      values
    );

    const [result] = await connection.execute(
      `SELECT
        biometricEnabled,
        twoFactorEnabled,
        twoFactorMethod,
        twoFactorVerifiedAt,
        loginNotificationEnabled,
        passwordChangedAt,
        createdAt,
        updatedAt
      FROM user_security_settings
      WHERE userId = ?
      LIMIT 1`,
      [userId]
    );

    await connection.commit();

    return result[0];
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}


// =========================
// LOG OUT CURRENT SESSION
// =========================

async function logoutCurrentSession(
  userId,
  sessionId
) {
  if (!sessionId) {
    throw Object.assign(
      new Error("The current session could not be identified."),
      { statusCode: 400 }
    );
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [result] = await connection.execute(
      `UPDATE user_sessions
       SET revokedAt = CURRENT_TIMESTAMP
       WHERE id = ?
         AND userId = ?
         AND revokedAt IS NULL`,
      [
        sessionId,
        userId,
      ]
    );

    if (result.affectedRows === 0) {
      throw Object.assign(
        new Error("This session has already been logged out."),
        { statusCode: 404 }
      );
    }

    await connection.execute(
      `INSERT INTO login_activity (
        userId,
        eventType,
        description
      ) VALUES (?, 'logout', ?)`,
      [
        userId,
        "User logged out successfully.",
      ]
    );

    await connection.commit();

    return {
      message: "You have been logged out successfully.",
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (_) {
      // Preserve the original error.
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =========================
// EXPORT SERVICE
// =========================

export {
  getSecuritySettings,
  getActiveSessions,
  revokeSession,
  revokeOtherSessions,
  getLoginActivity,
  updateSecuritySettings,
  logoutCurrentSession,
};