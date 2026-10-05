import pool from "../../config/database.js";

import {
    generateSecureToken,
    hashAdminPassword,
    hashToken,
} from "../../utils/adminSecurity.js";

import {
    createAdminAuditLog,
} from "./adminAuditService.js";

// =========================================================
// PASSWORD RESET CONFIGURATION
// =========================================================

const RESET_TOKEN_EXPIRY_MINUTES = 30;

// =========================================================
// HELPERS
// =========================================================

function normalizeIdentifier(identifier) {
    if (
        !identifier ||
        typeof identifier !== "string"
    ) {
        return "";
    }

    return identifier.trim().toLowerCase();
}

function getResetExpiryDate() {
    const expiry =
        new Date();

    expiry.setMinutes(
        expiry.getMinutes() +
        RESET_TOKEN_EXPIRY_MINUTES,
    );

    return expiry;
}

// =========================================================
// REQUEST PASSWORD RESET
// =========================================================

/**
 * Create an administrator password reset token.
 *
 * IMPORTANT:
 * Only the SHA-256 hash of the reset token
 * is stored in the database.
 *
 * The raw token is never stored.
 */
export async function requestAdminPasswordReset({
    identifier,
    ipAddress = null,
    userAgent = null,
}) {
    const normalizedIdentifier =
        normalizeIdentifier(identifier);

    if (!normalizedIdentifier) {
        return {
            success: false,
            code: "INVALID_IDENTIFIER",
            message:
                "Email or phone number is required.",
        };
    }

    // =======================================================
    // FIND ADMINISTRATOR
    // =======================================================

    const [staffRows] =
        await pool.execute(
            `
        SELECT
          s.id,
          s.firstName,
          s.lastName,
          s.email,
          s.phone,
          s.passwordHash,
          s.accountStatus,
          r.id AS roleId,
          r.code AS roleCode,
          r.isActive AS roleIsActive
        FROM admin_staff s
        INNER JOIN admin_roles r
          ON r.id = s.roleId
        WHERE
          LOWER(s.email) = ?
          OR s.phone = ?
        LIMIT 1
      `,
            [
                normalizedIdentifier,
                identifier.trim(),
            ],
        );

    /*
     * IMPORTANT SECURITY BEHAVIOUR:
     *
     * Do not reveal whether the administrator exists.
     *
     * The controller will return the same generic
     * response whether the account was found or not.
     */
    if (staffRows.length === 0) {
        return {
            success: true,
            accountFound: false,
            resetToken: null,
        };
    }

    const staff =
        staffRows[0];

    // =======================================================
    // ACCOUNT STATUS CHECK
    // =======================================================

    /*
     * Suspended and deactivated administrators should not
     * receive password-reset credentials.
     *
     * We still return a generic success response to the
     * client so the existence/status of the account is not
     * disclosed.
     */
    if (
        staff.accountStatus !== "active" ||
        Number(staff.roleIsActive) !== 1
    ) {
        return {
            success: true,
            accountFound: false,
            resetToken: null,
        };
    }

    // =======================================================
    // GENERATE SECURE RESET TOKEN
    // =======================================================

    const resetToken =
        generateSecureToken(48);

    const tokenHash =
        hashToken(resetToken);

    const expiresAt =
        getResetExpiryDate();

    // =======================================================
    // INVALIDATE PREVIOUS RESET TOKENS
    // =======================================================

    await pool.execute(
        `
      UPDATE admin_password_reset_tokens
      SET usedAt = NOW()
      WHERE
        staffId = ?
        AND usedAt IS NULL
        AND expiresAt > NOW()
    `,
        [staff.id],
    );

    // =======================================================
    // STORE NEW RESET TOKEN
    // =======================================================

    await pool.execute(
        `
      INSERT INTO admin_password_reset_tokens (
        staffId,
        tokenHash,
        expiresAt
      )
      VALUES (?, ?, ?)
    `,
        [
            staff.id,
            tokenHash,
            expiresAt,
        ],
    );

    // =======================================================
    // RECORD RESET REQUEST
    // =======================================================

    await pool.execute(
        `
      INSERT INTO admin_login_activity (
        staffId,
        eventType,
        ipAddress,
        userAgent,
        description
      )
      VALUES (?, 'password_reset', ?, ?, ?)
    `,
        [
            staff.id,
            ipAddress,
            userAgent,
            "Administrator password reset requested.",
        ],
    );

    // =======================================================
    // AUDIT LOG
    // =======================================================

    await createAdminAuditLog({
        staffId: staff.id,
        action: "password_reset_requested",
        module: "authentication",
        entityType: "admin_staff",
        entityId: staff.id,
        oldValues: null,
        newValues: {
            resetTokenCreated: true,
            expiresAt,
        },
        ipAddress,
        userAgent,
    });

    return {
        success: true,
        accountFound: true,
        resetToken,
        expiresAt,
        staff: {
            id: staff.id,
            firstName: staff.firstName,
            lastName: staff.lastName,
            email: staff.email,
            phone: staff.phone,
        },
    };
}

// =========================================================
// RESET ADMINISTRATOR PASSWORD
// =========================================================

/**
 * Reset an administrator password using a valid
 * password-reset token.
 */
export async function resetAdminPassword({
    resetToken,
    newPassword,
    ipAddress = null,
    userAgent = null,
}) {
    if (
        !resetToken ||
        typeof resetToken !== "string"
    ) {
        return {
            success: false,
            code: "INVALID_RESET_TOKEN",
            message:
                "Password reset token is required.",
        };
    }

    if (
        !newPassword ||
        typeof newPassword !== "string"
    ) {
        return {
            success: false,
            code: "INVALID_PASSWORD",
            message:
                "New password is required.",
        };
    }

    // =======================================================
    // PASSWORD VALIDATION
    // =======================================================

    if (newPassword.length < 8) {
        return {
            success: false,
            code: "WEAK_PASSWORD",
            message:
                "Password must contain at least 8 characters.",
        };
    }

    /*
     * Prevent accidentally accepting extremely large input.
     */
    if (newPassword.length > 128) {
        return {
            success: false,
            code: "INVALID_PASSWORD",
            message:
                "Password cannot exceed 128 characters.",
        };
    }

    // =======================================================
    // HASH RESET TOKEN
    // =======================================================

    const tokenHash =
        hashToken(
            resetToken.trim(),
        );

    // =======================================================
    // FIND VALID RESET TOKEN
    // =======================================================

    const [tokenRows] =
        await pool.execute(
            `
        SELECT
          prt.id,
          prt.staffId,
          prt.expiresAt,
          prt.usedAt,

          s.firstName,
          s.lastName,
          s.email,
          s.phone,
          s.accountStatus,

          r.code AS roleCode,
          r.isActive AS roleIsActive

        FROM admin_password_reset_tokens prt

        INNER JOIN admin_staff s
          ON s.id = prt.staffId

        INNER JOIN admin_roles r
          ON r.id = s.roleId

        WHERE
          prt.tokenHash = ?
        LIMIT 1
      `,
            [tokenHash],
        );

    if (tokenRows.length === 0) {
        return {
            success: false,
            code: "INVALID_RESET_TOKEN",
            message:
                "The password reset token is invalid or has expired.",
        };
    }

    const tokenRecord =
        tokenRows[0];

    // =======================================================
    // TOKEN STATUS
    // =======================================================

    if (tokenRecord.usedAt) {
        return {
            success: false,
            code: "RESET_TOKEN_USED",
            message:
                "This password reset token has already been used.",
        };
    }

    if (
        new Date(tokenRecord.expiresAt) <=
        new Date()
    ) {
        return {
            success: false,
            code: "RESET_TOKEN_EXPIRED",
            message:
                "The password reset token has expired.",
        };
    }

    // =======================================================
    // ACCOUNT STATUS
    // =======================================================

    if (
        tokenRecord.accountStatus !== "active" ||
        Number(tokenRecord.roleIsActive) !== 1
    ) {
        return {
            success: false,
            code: "ACCOUNT_INACTIVE",
            message:
                "This administrator account is not active.",
        };
    }

    // =======================================================
    // HASH NEW PASSWORD
    // =======================================================

    const passwordHash =
        await hashAdminPassword(
            newPassword,
        );

    // =======================================================
    // DATABASE TRANSACTION
    // =======================================================

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        // =====================================================
        // UPDATE PASSWORD
        // =====================================================

        await connection.execute(
            `
        UPDATE admin_staff
        SET
          passwordHash = ?,
          passwordChangedAt = NOW(),
          failedLoginAttempts = 0,
          lockedUntil = NULL,
          accountStatus = 'active',
          updatedAt = NOW()
        WHERE id = ?
      `,
            [
                passwordHash,
                tokenRecord.staffId,
            ],
        );

        // =====================================================
        // MARK RESET TOKEN AS USED
        // =====================================================

        await connection.execute(
            `
        UPDATE admin_password_reset_tokens
        SET usedAt = NOW()
        WHERE id = ?
      `,
            [tokenRecord.id],
        );

        // =====================================================
        // REVOKE ALL EXISTING ADMIN SESSIONS
        // =====================================================

        await connection.execute(
            `
        UPDATE admin_sessions
        SET revokedAt = NOW()
        WHERE
          staffId = ?
          AND revokedAt IS NULL
      `,
            [tokenRecord.staffId],
        );

        // =====================================================
        // RECORD PASSWORD RESET ACTIVITY
        // =====================================================

        await connection.execute(
            `
        INSERT INTO admin_login_activity (
          staffId,
          eventType,
          ipAddress,
          userAgent,
          description
        )
        VALUES (?, 'password_reset', ?, ?, ?)
      `,
            [
                tokenRecord.staffId,
                ipAddress,
                userAgent,
                "Administrator password was successfully reset.",
            ],
        );

        await connection.commit();
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }

    // =======================================================
    // AUDIT LOG
    // =======================================================

    await createAdminAuditLog({
        staffId: tokenRecord.staffId,
        action: "password_reset",
        module: "authentication",
        entityType: "admin_staff",
        entityId: tokenRecord.staffId,
        oldValues: null,
        newValues: {
            passwordChanged: true,
            allSessionsRevoked: true,
        },
        ipAddress,
        userAgent,
    });

    return {
        success: true,
        code: "PASSWORD_RESET_SUCCESS",
        message:
            "Administrator password has been reset successfully.",
        staff: {
            id: tokenRecord.staffId,
            firstName: tokenRecord.firstName,
            lastName: tokenRecord.lastName,
            email: tokenRecord.email,
            phone: tokenRecord.phone,
        },
    };
}