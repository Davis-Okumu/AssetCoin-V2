
import crypto from "crypto";
import bcrypt from "bcryptjs";

import pool from "../config/database.js";

const RESET_TOKEN_EXPIRY_MINUTES = 15;

// =========================
// CREATE SECURITY NOTIFICATION
// =========================

async function createPasswordSecurityNotification(
  connection,
  userId,
  title,
  message
) {
  await connection.execute(
    `INSERT INTO notifications (
      userId,
      type,
      title,
      message,
      deliveryMethod,
      status
    )
    VALUES (?, 'security', ?, ?, 'in_app', 'new')`,
    [
      userId,
      title,
      message,
    ]
  );
}

// =========================
// REQUEST PASSWORD RESET
// =========================

async function requestPasswordReset(email) {
  const normalizedEmail = email?.trim().toLowerCase();

  if (!normalizedEmail) {
    throw Object.assign(
      new Error("Please provide your email address."),
      { statusCode: 400 }
    );
  }

  /*
   * Always use the same public response regardless
   * of whether the email exists.
   */
  const genericMessage =
    "If an account exists with that email, a password reset request has been created.";

  const [users] = await pool.execute(
    `SELECT
      id,
      email,
      accountStatus
    FROM users
    WHERE email = ?
    LIMIT 1`,
    [normalizedEmail]
  );

  if (users.length === 0) {
    return {
      message: genericMessage,
      resetToken: null,
    };
  }

  const user = users[0];

  if (user.accountStatus !== "active") {
    return {
      message: genericMessage,
      resetToken: null,
    };
  }

  // Invalidate previous unused reset tokens.
  await pool.execute(
    `UPDATE password_reset_tokens
     SET usedAt = CURRENT_TIMESTAMP
     WHERE userId = ?
       AND usedAt IS NULL`,
    [user.id]
  );

  // Generate a secure reset token.
  const resetToken = crypto
    .randomBytes(32)
    .toString("hex");

  // Store only its SHA-256 hash.
  const tokenHash = crypto
    .createHash("sha256")
    .update(resetToken)
    .digest("hex");

  await pool.execute(
    `INSERT INTO password_reset_tokens (
      userId,
      tokenHash,
      expiresAt
    )
    VALUES (
      ?,
      ?,
      DATE_ADD(
        CURRENT_TIMESTAMP,
        INTERVAL ? MINUTE
      )
    )`,
    [
      user.id,
      tokenHash,
      RESET_TOKEN_EXPIRY_MINUTES,
    ]
  );

  return {
    message: genericMessage,

    /*
     * DEVELOPMENT ONLY.
     * Replace this with email delivery before production.
     */
    resetToken,
  };
}

// =========================
// RESET PASSWORD
// =========================

async function resetPassword({
  token,
  newPassword,
}) {
  if (!token?.trim() || !newPassword) {
    throw Object.assign(
      new Error(
        "Reset token and new password are required."
      ),
      { statusCode: 400 }
    );
  }

  if (newPassword.length < 8) {
    throw Object.assign(
      new Error(
        "Password must contain at least 8 characters."
      ),
      { statusCode: 400 }
    );
  }

  const tokenHash = crypto
    .createHash("sha256")
    .update(token.trim())
    .digest("hex");

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // =========================
    // FIND AND LOCK RESET TOKEN
    // =========================

    const [resetTokens] = await connection.execute(
      `SELECT
        id,
        userId,
        expiresAt,
        usedAt
      FROM password_reset_tokens
      WHERE tokenHash = ?
        AND usedAt IS NULL
        AND expiresAt > CURRENT_TIMESTAMP
      LIMIT 1
      FOR UPDATE`,
      [tokenHash]
    );

    if (resetTokens.length === 0) {
      throw Object.assign(
        new Error(
          "Invalid or expired password reset token."
        ),
        { statusCode: 400 }
      );
    }

    const resetToken = resetTokens[0];

    // =========================
    // HASH NEW PASSWORD
    // =========================

    const passwordHash = await bcrypt.hash(
      newPassword,
      12
    );

    // =========================
    // UPDATE USER PASSWORD
    // =========================

    const [updateResult] = await connection.execute(
      `UPDATE users
       SET passwordHash = ?
       WHERE id = ?
         AND accountStatus = 'active'`,
      [
        passwordHash,
        resetToken.userId,
      ]
    );

    if (updateResult.affectedRows === 0) {
      throw Object.assign(
        new Error("Unable to reset the password."),
        { statusCode: 400 }
      );
    }

    // =========================
    // MARK RESET TOKEN AS USED
    // =========================

    await connection.execute(
      `UPDATE password_reset_tokens
       SET usedAt = CURRENT_TIMESTAMP
       WHERE id = ?
         AND usedAt IS NULL`,
      [resetToken.id]
    );

    // =========================
    // INVALIDATE OTHER RESET TOKENS
    // =========================

    await connection.execute(
      `UPDATE password_reset_tokens
       SET usedAt = CURRENT_TIMESTAMP
       WHERE userId = ?
         AND id != ?
         AND usedAt IS NULL`,
      [
        resetToken.userId,
        resetToken.id,
      ]
    );

    // =========================
    // UPDATE SECURITY SETTINGS
    // =========================

    await connection.execute(
      `INSERT INTO user_security_settings (
        userId,
        passwordChangedAt
      ) VALUES (?, CURRENT_TIMESTAMP)
      ON DUPLICATE KEY UPDATE
        passwordChangedAt = CURRENT_TIMESTAMP`,
      [resetToken.userId]
    );

    // =========================
    // REVOKE ALL EXISTING SESSIONS
    // =========================

    await connection.execute(
      `UPDATE user_sessions
       SET revokedAt = CURRENT_TIMESTAMP
       WHERE userId = ?
         AND revokedAt IS NULL`,
      [resetToken.userId]
    );

    // =========================
    // RECORD PASSWORD RESET
    // =========================

    await connection.execute(
      `INSERT INTO login_activity (
        userId,
        eventType,
        description
      ) VALUES (?, 'password_reset', ?)`,
      [
        resetToken.userId,
        "Account password was reset successfully. Existing sessions were revoked.",
      ]
    );

    // =========================
    // PASSWORD RESET NOTIFICATION
    // =========================

    await createPasswordSecurityNotification(
      connection,
      resetToken.userId,
      "Password Reset Successful",
      "Your AssetCoin password was reset successfully. All existing sessions have been signed out. If you did not request this change, please contact support."
    );

    // =========================
    // COMMIT TRANSACTION
    // =========================

    await connection.commit();

    return {
      message: "Password reset successfully. Please log in again.",
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
// CHANGE PASSWORD
// =========================

async function changePassword({
  userId,
  currentPassword,
  newPassword,
}) {
  if (!currentPassword || !newPassword) {
    throw Object.assign(
      new Error(
        "Current password and new password are required."
      ),
      { statusCode: 400 }
    );
  }

  if (newPassword.length < 8) {
    throw Object.assign(
      new Error(
        "New password must contain at least 8 characters."
      ),
      { statusCode: 400 }
    );
  }

  if (currentPassword === newPassword) {
    throw Object.assign(
      new Error(
        "Your new password must be different from your current password."
      ),
      { statusCode: 400 }
    );
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // =========================
    // LOCK USER RECORD
    // =========================

    const [users] = await connection.execute(
      `SELECT
        id,
        passwordHash,
        accountStatus
      FROM users
      WHERE id = ?
      LIMIT 1
      FOR UPDATE`,
      [userId]
    );

    if (
      users.length === 0 ||
      users[0].accountStatus !== "active"
    ) {
      throw Object.assign(
        new Error("Unable to change your password."),
        { statusCode: 403 }
      );
    }

    const user = users[0];

    // =========================
    // VERIFY CURRENT PASSWORD
    // =========================

    const passwordMatches = await bcrypt.compare(
      currentPassword,
      user.passwordHash
    );

    if (!passwordMatches) {
      throw Object.assign(
        new Error("Your current password is incorrect."),
        { statusCode: 400 }
      );
    }

    // =========================
    // HASH NEW PASSWORD
    // =========================

    const passwordHash = await bcrypt.hash(
      newPassword,
      12
    );

    // =========================
    // SAVE NEW PASSWORD
    // =========================

    await connection.execute(
      `UPDATE users
       SET passwordHash = ?
       WHERE id = ?`,
      [
        passwordHash,
        userId,
      ]
    );

    // =========================
    // UPDATE PASSWORD-CHANGE TIMESTAMP
    // =========================

    await connection.execute(
      `INSERT INTO user_security_settings (
        userId,
        passwordChangedAt
      ) VALUES (?, CURRENT_TIMESTAMP)
      ON DUPLICATE KEY UPDATE
        passwordChangedAt = CURRENT_TIMESTAMP`,
      [userId]
    );

    // =========================
    // INVALIDATE OUTSTANDING RESET TOKENS
    // =========================

    await connection.execute(
      `UPDATE password_reset_tokens
       SET usedAt = CURRENT_TIMESTAMP
       WHERE userId = ?
         AND usedAt IS NULL`,
      [userId]
    );

    // =========================
    // REVOKE ALL EXISTING SESSIONS
    // =========================

    await connection.execute(
      `UPDATE user_sessions
       SET revokedAt = CURRENT_TIMESTAMP
       WHERE userId = ?
         AND revokedAt IS NULL`,
      [userId]
    );

    // =========================
    // RECORD PASSWORD CHANGE
    // =========================

    await connection.execute(
      `INSERT INTO login_activity (
        userId,
        eventType,
        description
      ) VALUES (?, 'password_changed', ?)`,
      [
        userId,
        "Account password was changed successfully. Existing sessions were revoked.",
      ]
    );

    // =========================
    // PASSWORD CHANGE NOTIFICATION
    // =========================

    await createPasswordSecurityNotification(
      connection,
      userId,
      "Password Changed Successfully",
      "Your AssetCoin account password was changed successfully. All existing sessions have been signed out. If you did not make this change, please contact support."
    );

    // =========================
    // COMMIT TRANSACTION
    // =========================

    await connection.commit();

    return {
      message: "Password changed successfully. Please log in again.",
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
  requestPasswordReset,
  resetPassword,
  changePassword,
};

