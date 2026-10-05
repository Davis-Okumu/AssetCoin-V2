import pool from "../../config/database.js";

import {
  hashToken,
  verifyAdminPassword,
} from "../../utils/adminSecurity.js";

import {
  createAdminJwt,
} from "../../utils/adminJwt.js";

import {
  getAdminPermissions,
} from "./adminPermissionService.js";

import {
  createAdminAuditLog,
} from "./adminAuditService.js";

const MAX_FAILED_LOGIN_ATTEMPTS = 5;

const LOCK_DURATION_MINUTES = 15;

const SESSION_DURATION_HOURS = 8;

/**
 * Normalize an admin login identifier.
 */
function normalizeIdentifier(identifier) {
  return identifier
    .trim()
    .toLowerCase();
}

/**
 * Convert database admin record into API response model.
 */
function buildAdminResponse({
  staff,
  permissions,
}) {
  return {
    id: staff.id,
    firstName: staff.firstName,
    lastName: staff.lastName,
    email: staff.email,
    phone: staff.phone,
    profilePhotoUrl: staff.profilePhotoUrl,
    role: staff.roleCode,
    roleName: staff.roleName,
    isActive:
      staff.accountStatus === "active",
    permissions,
  };
}

/**
 * Authenticate administrator.
 */
export async function loginAdmin({
  identifier,
  password,
  ipAddress,
  userAgent,
  deviceType,
}) {
  const normalizedIdentifier =
    normalizeIdentifier(identifier);

  const connection =
    await pool.getConnection();

  let staff = null;

  try {
    await connection.beginTransaction();

    const [staffRows] =
      await connection.execute(
        `
          SELECT
            s.id,
            s.firstName,
            s.lastName,
            s.email,
            s.phone,
            s.passwordHash,
            s.roleId,
            s.profilePhotoUrl,
            s.accountStatus,
            s.lastLoginAt,
            s.passwordChangedAt,
            s.failedLoginAttempts,
            s.lockedUntil,

            r.name AS roleName,
            r.code AS roleCode,
            r.isActive AS roleIsActive

          FROM admin_staff s

          INNER JOIN admin_roles r
            ON r.id = s.roleId

          WHERE
            (
              LOWER(s.email) = ?
              OR s.phone = ?
            )

          LIMIT 1

          FOR UPDATE
        `,
        [
          normalizedIdentifier,
          identifier.trim(),
        ],
      );

    staff = staffRows[0] || null;

    /*
     * Unknown administrator.
     *
     * We deliberately do not reveal whether
     * an email/phone exists.
     */
    if (!staff) {
      await connection.commit();

      return {
        success: false,
        code: "INVALID_CREDENTIALS",
        message:
          "Invalid administrator credentials.",
      };
    }

    /*
     * Account status checks.
     */
    if (
      staff.accountStatus ===
      "deactivated"
    ) {
      await recordLoginActivity(
        connection,
        staff.id,
        "login_failed",
        ipAddress,
        userAgent,
        "Login attempted on a deactivated account.",
      );

      await connection.commit();

      return {
        success: false,
        code: "ACCOUNT_DEACTIVATED",
        message:
          "This administrator account has been deactivated.",
      };
    }

    if (
      staff.accountStatus ===
      "suspended"
    ) {
      await recordLoginActivity(
        connection,
        staff.id,
        "login_failed",
        ipAddress,
        userAgent,
        "Login attempted on a suspended account.",
      );

      await connection.commit();

      return {
        success: false,
        code: "ACCOUNT_SUSPENDED",
        message:
          "This administrator account has been suspended.",
      };
    }

    /*
     * Role must still be active.
     */
    if (!staff.roleIsActive) {
      await recordLoginActivity(
        connection,
        staff.id,
        "login_failed",
        ipAddress,
        userAgent,
        "Login attempted with an inactive administrator role.",
      );

      await connection.commit();

      return {
        success: false,
        code: "ROLE_INACTIVE",
        message:
          "The administrator role is currently inactive.",
      };
    }

    /*
     * Check temporary lock.
     */
    if (
      staff.lockedUntil &&
      new Date(staff.lockedUntil) >
        new Date()
    ) {
      await recordLoginActivity(
        connection,
        staff.id,
        "login_failed",
        ipAddress,
        userAgent,
        "Login attempted while account was temporarily locked.",
      );

      await connection.commit();

      return {
        success: false,
        code: "ACCOUNT_LOCKED",
        message:
          "Your administrator account is temporarily locked. Please try again later.",
      };
    }

    /*
     * If lock has expired, clear it.
     */
    if (
      staff.lockedUntil &&
      new Date(staff.lockedUntil) <=
        new Date()
    ) {
      await connection.execute(
        `
          UPDATE admin_staff
          SET
            accountStatus = 'active',
            failedLoginAttempts = 0,
            lockedUntil = NULL
          WHERE id = ?
        `,
        [staff.id],
      );

      staff.failedLoginAttempts = 0;
    }

    /*
     * Verify password.
     */
    const passwordValid =
      await verifyAdminPassword(
        password,
        staff.passwordHash,
      );

    if (!passwordValid) {
      const failedAttempts =
        Number(
          staff.failedLoginAttempts || 0,
        ) + 1;

      if (
        failedAttempts >=
        MAX_FAILED_LOGIN_ATTEMPTS
      ) {
        await connection.execute(
          `
            UPDATE admin_staff
            SET
              accountStatus = 'locked',
              failedLoginAttempts = ?,
              lockedUntil = DATE_ADD(
                NOW(),
                INTERVAL ? MINUTE
              )
            WHERE id = ?
          `,
          [
            failedAttempts,
            LOCK_DURATION_MINUTES,
            staff.id,
          ],
        );

        await recordLoginActivity(
          connection,
          staff.id,
          "account_locked",
          ipAddress,
          userAgent,
          "Administrator account locked after repeated failed login attempts.",
        );
      } else {
        await connection.execute(
          `
            UPDATE admin_staff
            SET failedLoginAttempts = ?
            WHERE id = ?
          `,
          [
            failedAttempts,
            staff.id,
          ],
        );

        await recordLoginActivity(
          connection,
          staff.id,
          "login_failed",
          ipAddress,
          userAgent,
          "Invalid administrator password.",
        );
      }

      await connection.commit();

      return {
        success: false,
        code: "INVALID_CREDENTIALS",
        message:
          "Invalid administrator credentials.",
      };
    }

    /*
     * Get effective permissions.
     */
    const permissions =
      await getAdminPermissions(
        staff.id,
        staff.roleId,
      );

    /*
     * Create a temporary database session
     * first so its ID can be placed inside
     * the JWT.
     */
    const expiresAt =
      new Date(
        Date.now() +
          SESSION_DURATION_HOURS *
            60 *
            60 *
            1000,
      );

    const [sessionResult] =
      await connection.execute(
        `
          INSERT INTO admin_sessions (
            staffId,
            sessionTokenHash,
            deviceName,
            deviceType,
            ipAddress,
            userAgent,
            lastActiveAt,
            expiresAt
          )
          VALUES (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            NOW(),
            ?
          )
        `,
        [
          staff.id,
          "pending",
          null,
          deviceType,
          ipAddress,
          userAgent,
          expiresAt,
        ],
      );

    const sessionId =
      sessionResult.insertId;

    /*
     * Generate JWT.
     */
    const token = createAdminJwt({
      staffId: staff.id,
      sessionId,
      role: staff.roleCode,
    });

    /*
     * Store SHA-256 hash of JWT.
     *
     * Raw JWT is never stored in database.
     */
    const sessionTokenHash =
      hashToken(token);

    await connection.execute(
      `
        UPDATE admin_sessions
        SET sessionTokenHash = ?
        WHERE id = ?
      `,
      [
        sessionTokenHash,
        sessionId,
      ],
    );

    /*
     * Reset failed login counters.
     */
    await connection.execute(
      `
        UPDATE admin_staff
        SET
          accountStatus = 'active',
          failedLoginAttempts = 0,
          lockedUntil = NULL,
          lastLoginAt = NOW()
        WHERE id = ?
      `,
      [staff.id],
    );

    await recordLoginActivity(
      connection,
      staff.id,
      "login_success",
      ipAddress,
      userAgent,
      "Administrator login successful.",
    );

    await connection.commit();

    /*
     * Write an audit record outside the
     * authentication transaction.
     */
    await createAdminAuditLog({
      staffId: staff.id,
      action: "admin.login",
      module: "authentication",
      entityType: "admin_staff",
      entityId: staff.id,
      newValues: {
        event: "login_success",
        sessionId,
      },
      ipAddress,
      userAgent,
    });

    return {
      success: true,
      token,
      expiresAt,
      admin: buildAdminResponse({
        staff,
        permissions,
      }),
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * Get current administrator from a validated session.
 */
export async function getCurrentAdmin({
  staffId,
  sessionId,
  token,
}) {
  const tokenHash =
    hashToken(token);

  const [rows] = await pool.execute(
    `
      SELECT
        s.id,
        s.firstName,
        s.lastName,
        s.email,
        s.phone,
        s.profilePhotoUrl,
        s.roleId,
        s.accountStatus,

        r.name AS roleName,
        r.code AS roleCode,
        r.isActive AS roleIsActive

      FROM admin_staff s

      INNER JOIN admin_roles r
        ON r.id = s.roleId

      INNER JOIN admin_sessions session
        ON session.staffId = s.id

      WHERE
        s.id = ?
        AND session.id = ?
        AND session.sessionTokenHash = ?
        AND session.revokedAt IS NULL
        AND session.expiresAt > NOW()
        AND s.accountStatus = 'active'
        AND r.isActive = TRUE

      LIMIT 1
    `,
    [
      staffId,
      sessionId,
      tokenHash,
    ],
  );

  const staff = rows[0];

  if (!staff) {
    return null;
  }

  const permissions =
    await getAdminPermissions(
      staff.id,
      staff.roleId,
    );

  await pool.execute(
    `
      UPDATE admin_sessions
      SET lastActiveAt = NOW()
      WHERE id = ?
    `,
    [sessionId],
  );

  return buildAdminResponse({
    staff,
    permissions,
  });
}

/**
 * Revoke the current administrator session.
 */
export async function logoutAdmin({
  staffId,
  sessionId,
}) {
  const connection =
    await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [result] =
      await connection.execute(
        `
          UPDATE admin_sessions
          SET revokedAt = NOW()
          WHERE
            id = ?
            AND staffId = ?
            AND revokedAt IS NULL
        `,
        [
          sessionId,
          staffId,
        ],
      );

    if (result.affectedRows > 0) {
      await recordLoginActivity(
        connection,
        staffId,
        "logout",
        null,
        null,
        "Administrator logged out.",
      );
    }

    await connection.commit();

    await createAdminAuditLog({
      staffId,
      action: "admin.logout",
      module: "authentication",
      entityType: "admin_sessions",
      entityId: sessionId,
      newValues: {
        event: "logout",
      },
    });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * Record administrator login/session activity.
 */
async function recordLoginActivity(
  connection,
  staffId,
  eventType,
  ipAddress,
  userAgent,
  description,
) {
  await connection.execute(
    `
      INSERT INTO admin_login_activity (
        staffId,
        eventType,
        ipAddress,
        userAgent,
        description
      )
      VALUES (?, ?, ?, ?, ?)
    `,
    [
      staffId,
      eventType,
      ipAddress,
      userAgent,
      description,
    ],
  );
}