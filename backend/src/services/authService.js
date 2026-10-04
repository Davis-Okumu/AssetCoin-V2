
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";

import pool from "../config/database.js";

// =========================
// JWT CONFIGURATION
// =========================

function generateToken(user, sessionId = null) {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error("JWT_SECRET is not configured.");
  }

  return jwt.sign(
    {
      sub: String(user.id),
      role: user.role,
      ...(sessionId ? { sid: String(sessionId) } : {}),
    },
    secret,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || "1d",
    }
  );
}

// =========================
// SAFE USER RESPONSE
// =========================

function formatUser(user) {
  return {
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    email: user.email,
    nationalId: user.nationalId,
    kycStatus: user.kycStatus,
    role: user.role,
    accountStatus: user.accountStatus,
  };
}

// =========================
// WALLET ADDRESS
// =========================

function generateWalletAddress() {
  return `ACW-${crypto.randomBytes(16).toString("hex")}`;
}

// =========================
// AUDIT LOG HASH
// =========================

function generateAuditLogHash({
  userId,
  action,
  entityType,
  entityId,
  oldValues,
  newValues,
  ipAddress,
  userAgent,
  previousHash,
}) {
  const payload = JSON.stringify({
    userId,
    action,
    entityType,
    entityId,
    oldValues,
    newValues,
    ipAddress,
    userAgent,
    previousHash,
  });

  return crypto
    .createHash("sha256")
    .update(payload)
    .digest("hex");
}

// =========================
// SESSION TOKEN HASH
// =========================

function generateSessionTokenHash(token) {
  return crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
}

// =========================
// CREATE USER SESSION
// =========================

async function createUserSession(
  connection,
  user,
  requestInfo = {}
) {
  const {
    ipAddress = null,
    userAgent = null,
    deviceName = null,
    deviceType = "unknown",
  } = requestInfo;

  /*
   * First create a temporary unique hash because
   * the session ID is needed in the JWT payload.
   */
  const temporaryHash = crypto
    .randomBytes(32)
    .toString("hex");

  const [sessionResult] = await connection.execute(
    `INSERT INTO user_sessions (
      userId,
      sessionTokenHash,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      lastActiveAt,
      expiresAt
    ) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?)`,
    [
      user.id,
      temporaryHash,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      new Date(Date.now() + 24 * 60 * 60 * 1000),
    ]
  );

  const sessionId = sessionResult.insertId;

  // Generate the JWT with the database session ID.
  const token = generateToken(user, sessionId);

  // Read the actual JWT expiry instead of assuming one day.
  const decodedToken = jwt.decode(token);

  if (!decodedToken?.exp) {
    throw new Error("Unable to determine authentication token expiry.");
  }

  const expiresAt = new Date(decodedToken.exp * 1000);

  // Replace the temporary hash with the actual JWT hash.
  const sessionTokenHash = generateSessionTokenHash(token);

  await connection.execute(
    `UPDATE user_sessions
     SET sessionTokenHash = ?,
         expiresAt = ?
     WHERE id = ?`,
    [
      sessionTokenHash,
      expiresAt,
      sessionId,
    ]
  );

  return token;
}

// =========================
// LOGIN ACTIVITY
// =========================

async function recordLoginActivity(
  connection,
  {
    userId,
    eventType,
    ipAddress = null,
    userAgent = null,
    deviceName = null,
    deviceType = "unknown",
    description = null,
  }
) {
  await connection.execute(
    `INSERT INTO login_activity (
      userId,
      eventType,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      description
    ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      userId,
      eventType,
      deviceName,
      deviceType,
      ipAddress,
      userAgent,
      description,
    ]
  );
}

async function recordFailedLoginAttempt(userId, requestInfo = {}) {
  try {
    await pool.execute(
      `INSERT INTO login_activity (
        userId,
        eventType,
        deviceName,
        deviceType,
        ipAddress,
        userAgent,
        description
      )
      VALUES (?, 'login_failed', ?, ?, ?, ?, ?)`,
      [
        userId || null,
        requestInfo.deviceName || null,
        requestInfo.deviceType || "unknown",
        requestInfo.ipAddress || null,
        requestInfo.userAgent || null,
        "Unsuccessful login attempt.",
      ]
    );
  } catch (error) {
    // A logging failure should not change the login response.
    console.error(
      "Failed login activity recording error:",
      error.message
    );
  }
}

// =========================
// REGISTER USER
// =========================

async function registerUser(data, requestInfo = {}) {
  const {
    firstName,
    lastName,
    phone,
    email,
    nationalId,
    password,
  } = data;

  const {
    ipAddress = null,
    userAgent = null,
  } = requestInfo;

  // =========================
  // VALIDATION
  // =========================

  if (
    !firstName?.trim() ||
    !lastName?.trim() ||
    !phone?.trim() ||
    !nationalId?.trim() ||
    !password
  ) {
    throw Object.assign(
      new Error("Please provide all required registration fields."),
      { statusCode: 400 }
    );
  }

  if (password.length < 8) {
    throw Object.assign(
      new Error("Password must contain at least 8 characters."),
      { statusCode: 400 }
    );
  }

  const normalizedEmail =
    email?.trim().toLowerCase() || null;

  // =========================
  // CHECK FOR DUPLICATES
  // =========================

  let duplicateQuery = `
    SELECT id
    FROM users
    WHERE phone = ? OR nationalId = ?
  `;

  const duplicateParams = [
    phone.trim(),
    nationalId.trim(),
  ];

  if (normalizedEmail) {
    duplicateQuery += " OR email = ?";
    duplicateParams.push(normalizedEmail);
  }

  duplicateQuery += " LIMIT 1";

  const [existingUsers] = await pool.execute(
    duplicateQuery,
    duplicateParams
  );

  if (existingUsers.length > 0) {
    throw Object.assign(
      new Error(
        "An account with this phone number, email, or national ID already exists."
      ),
      { statusCode: 409 }
    );
  }

  // =========================
  // HASH PASSWORD
  // =========================

  const passwordHash = await bcrypt.hash(
    password,
    12
  );

  // =========================
  // CREATE USER + WALLET
  // + AUDIT LOG
  // + NOTIFICATION
  // + SECURITY SETTINGS
  // + USER SESSION
  // =========================

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // =========================
    // CREATE USER
    // =========================

    const [result] = await connection.execute(
      `INSERT INTO users (
        firstName,
        lastName,
        phone,
        email,
        nationalId,
        passwordHash
      ) VALUES (?, ?, ?, ?, ?, ?)`,
      [
        firstName.trim(),
        lastName.trim(),
        phone.trim(),
        normalizedEmail,
        nationalId.trim(),
        passwordHash,
      ]
    );

    const userId = result.insertId;

    // =========================
    // CREATE WALLET
    // =========================

    await connection.execute(
      `INSERT INTO wallets (
        userId,
        walletAddress,
        fiatBalance,
        lockedFiatBalance,
        currency,
        status
      ) VALUES (?, ?, 0.00, 0.00, 'KES', 'active')`,
      [
        userId,
        generateWalletAddress(),
      ]
    );

    // =========================
    // GET PREVIOUS AUDIT HASH
    // =========================

    const [previousAuditLogs] =
      await connection.execute(
        `SELECT logHash
         FROM audit_logs
         ORDER BY id DESC
         LIMIT 1`
      );

    const previousHash =
      previousAuditLogs.length > 0
        ? previousAuditLogs[0].logHash
        : null;

    // =========================
    // AUDIT LOG
    // =========================

    const auditAction = "USER_REGISTERED";
    const auditEntityType = "user";
    const auditEntityId = userId;

    const oldValues = null;

    const newValues = {
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      email: normalizedEmail,
      nationalId: nationalId.trim(),
      kycStatus: "pending",
      role: "user",
      accountStatus: "active",
    };

    const logHash = generateAuditLogHash({
      userId,
      action: auditAction,
      entityType: auditEntityType,
      entityId: auditEntityId,
      oldValues,
      newValues,
      ipAddress,
      userAgent,
      previousHash,
    });

    await connection.execute(
      `INSERT INTO audit_logs (
        userId,
        action,
        entityType,
        entityId,
        oldValues,
        newValues,
        ipAddress,
        userAgent,
        previousHash,
        logHash
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        auditAction,
        auditEntityType,
        auditEntityId,
        null,
        JSON.stringify(newValues),
        ipAddress,
        userAgent,
        previousHash,
        logHash,
      ]
    );

    // =========================
    // WELCOME NOTIFICATION
    // =========================

    await connection.execute(
      `INSERT INTO notifications (
        userId,
        type,
        title,
        message,
        deliveryMethod,
        status
      ) VALUES (?, 'system', ?, ?, 'in_app', 'new')`,
      [
        userId,
        "Welcome to AssetCoin",
        "Your AssetCoin account has been created successfully. Your KES wallet is ready to use.",
      ]
    );

    // =========================
    // CREATE SECURITY SETTINGS
    // =========================

    await connection.execute(
      `INSERT INTO user_security_settings (
        userId,
        biometricEnabled,
        twoFactorEnabled,
        loginNotificationEnabled
      ) VALUES (?, FALSE, FALSE, TRUE)`,
      [userId]
    );

    // =========================
    // GET CREATED USER
    // =========================

    const [users] = await connection.execute(
      `SELECT
        id,
        firstName,
        lastName,
        phone,
        email,
        nationalId,
        kycStatus,
        role,
        accountStatus
      FROM users
      WHERE id = ?`,
      [userId]
    );

    const user = users[0];

    // =========================
    // CREATE INITIAL SESSION
    // =========================

    const token = await createUserSession(
      connection,
      user,
      {
        ipAddress,
        userAgent,
      }
    );

    // =========================
    // COMMIT
    // =========================

    await connection.commit();

    return {
      user: formatUser(user),
      token,
    };
  } catch (error) {
    await connection.rollback();

    if (error.code === "ER_DUP_ENTRY") {
      throw Object.assign(
        new Error(
          "An account with these details already exists."
        ),
        { statusCode: 409 }
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =========================
// LOGIN USER
// =========================


async function loginUser(
  identifier,
  password,
  requestInfo = {}
) {
  if (!identifier?.trim() || !password) {
    throw Object.assign(
      new Error(
        "Please provide your email or phone number and password."
      ),
      { statusCode: 400 }
    );
  }

  const normalizedIdentifier = identifier.trim();

  const [users] = await pool.execute(
    `SELECT
      id,
      firstName,
      lastName,
      phone,
      email,
      nationalId,
      passwordHash,
      kycStatus,
      role,
      accountStatus
    FROM users
    WHERE phone = ? OR email = ?
    LIMIT 1`,
    [
      normalizedIdentifier,
      normalizedIdentifier.toLowerCase(),
    ]
  );

  // No account matches the supplied identifier.
  if (users.length === 0) {
    await recordFailedLoginAttempt(null, requestInfo);

    throw Object.assign(
      new Error(
        "Unable to sign in with those credentials."
      ),
      { statusCode: 401 }
    );
  }

  const user = users[0];

  // Check the password.
  const passwordMatches = await bcrypt.compare(
    password,
    user.passwordHash
  );

  if (!passwordMatches) {
    await recordFailedLoginAttempt(user.id, requestInfo);

    throw Object.assign(
      new Error(
        "Unable to sign in with those credentials."
      ),
      { statusCode: 401 }
    );
  }

  // Do not reveal account status through a different login response.
  if (user.accountStatus !== "active") {
    await recordFailedLoginAttempt(user.id, requestInfo);

    throw Object.assign(
      new Error(
        "Unable to sign in with those credentials."
      ),
      { statusCode: 401 }
    );
  }


  // =========================
  // CREATE SESSION + RECORD LOGIN
  // =========================

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const token = await createUserSession(
      connection,
      user,
      requestInfo
    );

    // =========================
    // UPDATE LAST LOGIN
    // =========================

    await connection.execute(
      `UPDATE users
       SET lastLoginAt = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [user.id]
    );

    // =========================
    // RECORD SUCCESSFUL LOGIN
    // =========================

// =========================
// RECORD SUCCESSFUL LOGIN
// =========================

await recordLoginActivity(connection, {
  userId: user.id,
  eventType: "login_success",
  ...requestInfo,
  description: "User logged in successfully.",
});

// =========================
// CHECK LOGIN NOTIFICATION PREFERENCE
// =========================

const [securitySettings] = await connection.execute(
  `SELECT loginNotificationEnabled
   FROM user_security_settings
   WHERE userId = ?
   LIMIT 1`,
  [user.id]
);

// Default to enabled if an older account has no settings row.
const loginNotificationEnabled =
  securitySettings.length === 0 ||
  Boolean(securitySettings[0].loginNotificationEnabled);

// =========================
// CREATE LOGIN SECURITY NOTIFICATION
// =========================

if (loginNotificationEnabled) {
  await connection.execute(
    `INSERT INTO notifications (
      userId,
      type,
      title,
      message,
      deliveryMethod,
      status
    ) VALUES (?, 'security', ?, ?, 'in_app', 'new')`,
    [
      user.id,
      "New Sign-in to Your AssetCoin Account",
      "A successful sign-in to your AssetCoin account was recorded. If you do not recognise this activity, review your active sessions and change your password.",
    ]
  );
}

await connection.commit();

    return {
      user: formatUser(user),
      token,
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =========================
// EXPORT SERVICE
// =========================

export {
  registerUser,
  loginUser,
};