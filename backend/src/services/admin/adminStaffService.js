
import {
    hashAdminPassword,
} from "../../utils/adminSecurity.js";

import pool from "../../config/database.js";
import { getAdminPermissions } from "./adminPermissionService.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

const STAFF_STATUSES = [
    "active",
    "suspended",
    "deactivated",
    "locked",
];

const MANAGEABLE_STATUSES = [
    "active",
    "suspended",
    "deactivated",
];

const PASSWORD_MIN_LENGTH = 12;

/**
 * ============================================================
 * ADMIN STAFF MANAGEMENT SERVICE
 * ============================================================
 *
 * Responsibilities:
 * - Staff directory and overview statistics.
 * - Staff account creation and updates.
 * - Role assignment.
 * - Individual permission overrides.
 * - Account status management.
 * - Login activity and session management.
 * - Hash-linked audit records for mutations.
 *
 * Customer accounts remain in the users table.
 * Administrative accounts remain in admin_staff.
 * ============================================================
 */

function createError(message, statusCode = 400) {
    const error = new Error(message);
    error.statusCode = statusCode;
    return error;
}

function normalizeId(value, label = "Staff ID") {
    const id = Number(value);

    if (!Number.isSafeInteger(id) || id <= 0) {
        throw createError(`A valid ${label} is required.`);
    }

    return id;
}

function normalizePagination(query = {}) {
    const requestedLimit = Number.parseInt(query.limit, 10);
    const requestedPage = Number.parseInt(query.page, 10);

    const limit = Number.isInteger(requestedLimit)
        ? Math.min(Math.max(requestedLimit, 1), 100)
        : 20;

    const page = Number.isInteger(requestedPage)
        ? Math.max(requestedPage, 1)
        : 1;

    return {
        limit,
        page,
        offset: (page - 1) * limit,
    };
}

function normalizeText(value, field, maxLength, { required = false } = {}) {
    if (value === undefined || value === null) {
        if (required) {
            throw createError(`${field} is required.`);
        }

        return null;
    }

    if (typeof value !== "string") {
        throw createError(`${field} must be a string.`);
    }

    const normalized = value.trim();

    if (required && !normalized) {
        throw createError(`${field} is required.`);
    }

    if (normalized.length > maxLength) {
        throw createError(
            `${field} cannot exceed ${maxLength} characters.`,
        );
    }

    return normalized || null;
}

function normalizeEmail(value) {
    const email = normalizeText(value, "Email", 254, {
        required: true,
    }).toLowerCase();

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw createError("A valid email address is required.");
    }

    return email;
}

function normalizePhone(value, { required = false } = {}) {
    const phone = normalizeText(value, "Phone", 30, { required });

    if (phone && !/^\+?[0-9\s().-]{7,30}$/.test(phone)) {
        throw createError("A valid phone number is required.");
    }

    return phone;
}

function validatePassword(password) {
    if (typeof password !== "string" ||
        password.length < PASSWORD_MIN_LENGTH ||
        password.length > 128 ||
        !/[a-z]/.test(password) ||
        !/[A-Z]/.test(password) ||
        !/[0-9]/.test(password) ||
        !/[^A-Za-z0-9]/.test(password)) {
        throw createError(
            "Password must be 12–128 characters and include uppercase, lowercase, a number, and a special character.",
        );
    }

    return password;
}

function normalizeRequestContext(context = {}) {
    return {
        ipAddress: context.ipAddress ?? null,
        userAgent: context.userAgent ?? null,
    };
}

function isSuperAdmin(admin) {
    return (
        admin?.role === "super_admin" ||
        admin?.roleCode === "super_admin" ||
        admin?.role_code === "super_admin"
    );
}

function assertSuperAdminForElevation(admin, roleCode) {
    if (roleCode === "super_admin" && !isSuperAdmin(admin)) {
        throw createError(
            "Only a super administrator can assign the super administrator role.",
            403,
        );
    }
}

async function withAuditTransaction({
    staffId,
    action,
    entityType = "admin_staff",
    entityId = null,
    requestContext = {},
    execute,
}) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const result = await execute(connection);

        await writeAdminAuditLog({
            connection,
            staffId,
            action,
            module: "staff",
            entityType,
            entityId: entityId ?? result?.id ?? null,
            oldValues: result?.oldValues ?? null,
            newValues: result?.newValues ?? null,
            ...normalizeRequestContext(requestContext),
        });

        await connection.commit();

        return result;
    } catch (error) {
        try {
            await connection.rollback();
        } catch (rollbackError) {
            console.error("Staff transaction rollback failed:", rollbackError);
        }

        if (error?.code === "ER_DUP_ENTRY") {
            throw createError(
                "The email address or phone number is already assigned to another staff account.",
                409,
            );
        }

        throw error;
    } finally {
        connection.release();
    }
}

async function getStaffById(connection, staffId, { forUpdate = false } = {}) {
    const [rows] = await connection.execute(
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
                s.lastLoginAt,
                s.passwordChangedAt,
                s.failedLoginAttempts,
                s.lockedUntil,
                s.createdAt,
                s.updatedAt,
                r.name AS roleName,
                r.code AS roleCode,
                r.isActive AS roleIsActive
            FROM admin_staff s
            INNER JOIN admin_roles r ON r.id = s.roleId
            WHERE s.id = ?
            LIMIT 1
            ${forUpdate ? "FOR UPDATE" : ""}
        `,
        [staffId],
    );

    return rows[0] ?? null;
}

async function getRoleById(connection, roleId, { forUpdate = false } = {}) {
    const [rows] = await connection.execute(
        `
            SELECT id, name, code, description, isSystemRole, isActive
            FROM admin_roles
            WHERE id = ?
            LIMIT 1
            ${forUpdate ? "FOR UPDATE" : ""}
        `,
        [roleId],
    );

    return rows[0] ?? null;
}

async function ensureRoleIsAssignable(connection, roleId, admin) {
    const role = await getRoleById(connection, roleId, {
        forUpdate: true,
    });

    if (!role) {
        throw createError("The selected administrator role does not exist.", 404);
    }

    if (!role.isActive) {
        throw createError("The selected administrator role is inactive.", 409);
    }

    assertSuperAdminForElevation(admin, role.code);

    return role;
}

async function assertNotLastActiveSuperAdmin(
    connection,
    targetStaff,
    nextRoleCode,
    nextStatus,
) {
    const targetIsActiveSuperAdmin =
        targetStaff.roleCode === "super_admin" &&
        targetStaff.accountStatus === "active";

    const remainsActiveSuperAdmin =
        nextRoleCode === "super_admin" &&
        nextStatus === "active";

    if (!targetIsActiveSuperAdmin || remainsActiveSuperAdmin) {
        return;
    }

    // Lock the role row to serialize concurrent super-admin changes.
    await connection.execute(
        "SELECT id FROM admin_roles WHERE code = 'super_admin' FOR UPDATE",
    );

    const [rows] = await connection.execute(
        `
            SELECT COUNT(*) AS total
            FROM admin_staff s
            INNER JOIN admin_roles r ON r.id = s.roleId
            WHERE r.code = 'super_admin'
              AND r.isActive = TRUE
              AND s.accountStatus = 'active'
              AND s.id <> ?
        `,
        [targetStaff.id],
    );

    if (Number(rows[0]?.total ?? 0) === 0) {
        throw createError(
            "This action would remove the last active super administrator. Assign another active super administrator first.",
            409,
        );
    }
}

async function getRolePermissions(connection, roleId) {
    const [rows] = await connection.execute(
        `
            SELECT p.id, p.name, p.code, p.module, p.action, p.description
            FROM admin_role_permissions rp
            INNER JOIN admin_permissions p ON p.id = rp.permissionId
            WHERE rp.roleId = ?
            ORDER BY p.module, p.action
        `,
        [roleId],
    );

    return rows;
}

/**
 * STAFF OVERVIEW
 */
export async function getStaffOverview() {
    const [rows] = await pool.execute(`
        SELECT
            COUNT(*) AS total,
            SUM(accountStatus = 'active') AS active,
            SUM(accountStatus = 'suspended') AS suspended,
            SUM(accountStatus = 'deactivated') AS deactivated,
            SUM(accountStatus = 'locked') AS locked
        FROM admin_staff
    `);

    const [roleRows] = await pool.execute(`
        SELECT COUNT(*) AS total
        FROM admin_roles
        WHERE isActive = TRUE
    `);

    return {
        ...rows[0],
        total: Number(rows[0]?.total ?? 0),
        active: Number(rows[0]?.active ?? 0),
        suspended: Number(rows[0]?.suspended ?? 0),
        deactivated: Number(rows[0]?.deactivated ?? 0),
        locked: Number(rows[0]?.locked ?? 0),
        activeRoles: Number(roleRows[0]?.total ?? 0),
    };
}

/**
 * LIST STAFF
 */
export async function listStaff(query = {}) {
    const { limit, page, offset } = normalizePagination(query);

    const conditions = [];
    const params = [];

    if (query.status) {
        if (!STAFF_STATUSES.includes(query.status)) {
            throw createError("Invalid staff account status.");
        }

        conditions.push("s.accountStatus = ?");
        params.push(query.status);
    }

    if (query.roleId !== undefined && query.roleId !== "") {
        const roleId = normalizeId(query.roleId, "Role ID");
        conditions.push("s.roleId = ?");
        params.push(roleId);
    }

    if (query.search) {
        const search = String(query.search).trim().slice(0, 150);

        if (search) {
            conditions.push(`
                (
                    s.firstName LIKE ?
                    OR s.lastName LIKE ?
                    OR s.email LIKE ?
                    OR s.phone LIKE ?
                    OR r.name LIKE ?
                )
            `);

            const term = `%${search}%`;
            params.push(term, term, term, term, term);
        }
    }

    const whereClause = conditions.length
        ? `WHERE ${conditions.join(" AND ")}`
        : "";

    const [countRows] = await pool.execute(
        `
            SELECT COUNT(*) AS total
            FROM admin_staff s
            INNER JOIN admin_roles r ON r.id = s.roleId
            ${whereClause}
        `,
        params,
    );

    const [items] = await pool.execute(
        `
            SELECT
                s.id,
                s.firstName,
                s.lastName,
                s.email,
                s.phone,
                s.profilePhotoUrl,
                s.roleId,
                r.name AS roleName,
                r.code AS roleCode,
                s.accountStatus,
                s.lastLoginAt,
                s.createdAt,
                s.updatedAt
            FROM admin_staff s
            INNER JOIN admin_roles r ON r.id = s.roleId
            ${whereClause}
            ORDER BY s.createdAt DESC, s.id DESC
            LIMIT ? OFFSET ?
        `,
        [...params, limit, offset],
    );

    const total = Number(countRows[0]?.total ?? 0);

    return {
        items,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
    };
}

/**
 * GET STAFF DETAILS
 */
export async function getStaffDetails(rawStaffId) {
    const staffId = normalizeId(rawStaffId);

    const staff = await getStaffById(pool, staffId);

    if (!staff) {
        throw createError("Staff account not found.", 404);
    }

    const permissions = await getAdminPermissions(
        staff.id,
        staff.roleId,
    );

    const rolePermissions = await getRolePermissions(pool, staff.roleId);

    const [overrides] = await pool.execute(
        `
            SELECT
                p.id AS permissionId,
                p.name,
                p.code,
                p.module,
                p.action,
                sp.accessType
            FROM admin_staff_permissions sp
            INNER JOIN admin_permissions p ON p.id = sp.permissionId
            WHERE sp.staffId = ?
            ORDER BY p.module, p.action
        `,
        [staffId],
    );

    return {
        ...staff,
        permissions,
        rolePermissions,
        permissionOverrides: overrides,
    };
}

/**
 * LIST ACTIVE ROLES AND THEIR BASE PERMISSIONS
 */
export async function listStaffRoles() {
    const [roles] = await pool.execute(`
        SELECT
            r.id,
            r.name,
            r.code,
            r.description,
            r.isSystemRole,
            r.isActive,
            COUNT(DISTINCT s.id) AS staffCount
        FROM admin_roles r
        LEFT JOIN admin_staff s ON s.roleId = r.id
        WHERE r.isActive = TRUE
        GROUP BY
            r.id, r.name, r.code, r.description,
            r.isSystemRole, r.isActive
        ORDER BY r.name
    `);

    return roles;
}

/**
 * LIST AVAILABLE PERMISSIONS
 */
export async function listStaffPermissions() {
    const [rows] = await pool.execute(`
        SELECT id, name, code, module, action, description
        FROM admin_permissions
        ORDER BY module, action
    `);

    return rows;
}

/**
 * CREATE STAFF
 */
export async function createStaff(
    input,
    actor,
    staffId,
    requestContext = {},
) {
    if (!input || typeof input !== "object" || Array.isArray(input)) {
        throw createError("A valid staff object is required.");
    }

    const firstName = normalizeText(input.firstName, "First name", 100, {
        required: true,
    });

    const lastName = normalizeText(input.lastName, "Last name", 100, {
        required: true,
    });

    const email = normalizeEmail(input.email);
    const phone = normalizePhone(input.phone);
    const roleId = normalizeId(input.roleId, "Role ID");
    const password = validatePassword(input.password);

    if (input.profilePhotoUrl !== undefined &&
        input.profilePhotoUrl !== null &&
        typeof input.profilePhotoUrl !== "string") {
        throw createError("Profile photo URL must be a string.");
    }

    const profilePhotoUrl = normalizeText(
        input.profilePhotoUrl,
        "Profile photo URL",
        500,
    );

    const passwordHash = await hashAdminPassword(password);

    return withAuditTransaction({
        staffId,
        action: "staff.created",
        requestContext,
        execute: async (connection) => {
            const role = await ensureRoleIsAssignable(
                connection,
                roleId,
                actor,
            );

            const [result] = await connection.execute(
                `
                    INSERT INTO admin_staff (
                        firstName,
                        lastName,
                        email,
                        phone,
                        passwordHash,
                        roleId,
                        profilePhotoUrl,
                        accountStatus,
                        failedLoginAttempts
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, 'active', 0)
                `,
                [
                    firstName,
                    lastName,
                    email,
                    phone,
                    passwordHash,
                    roleId,
                    profilePhotoUrl,
                ],
            );

            const created = await getStaffById(
                connection,
                result.insertId,
            );

            return {
                id: result.insertId,
                oldValues: null,
                newValues: {
                    ...created,
                    passwordHash: undefined,
                    assignedRole: role.code,
                },
                item: {
                    ...created,
                    assignedRole: role.code,
                },
            };
        },
    }).then((result) => result.item);
}

/**
 * UPDATE STAFF PROFILE AND/OR ROLE
 */
export async function updateStaff(
    rawStaffId,
    input,
    actor,
    actorStaffId,
    requestContext = {},
) {
    const staffId = normalizeId(rawStaffId);

    if (!input || typeof input !== "object" || Array.isArray(input)) {
        throw createError("A valid staff update object is required.");
    }

    const allowedFields = [
        "firstName",
        "lastName",
        "email",
        "phone",
        "profilePhotoUrl",
        "roleId",
    ];

    const provided = allowedFields.filter((field) =>
        Object.prototype.hasOwnProperty.call(input, field),
    );

    if (provided.length === 0) {
        throw createError("Provide at least one staff field to update.");
    }

    const data = {};

    for (const field of provided) {
        switch (field) {
            case "firstName":
                data.firstName = normalizeText(input.firstName, "First name", 100, {
                    required: true,
                });
                break;

            case "lastName":
                data.lastName = normalizeText(input.lastName, "Last name", 100, {
                    required: true,
                });
                break;

            case "email":
                data.email = normalizeEmail(input.email);
                break;

            case "phone":
                data.phone = normalizePhone(input.phone);
                break;

            case "profilePhotoUrl":
                data.profilePhotoUrl = normalizeText(
                    input.profilePhotoUrl,
                    "Profile photo URL",
                    500,
                );
                break;

            case "roleId":
                data.roleId = normalizeId(input.roleId, "Role ID");
                break;
        }
    }

    return withAuditTransaction({
        staffId: actorStaffId,
        action: "staff.updated",
        entityId: staffId,
        requestContext,
        execute: async (connection) => {
            const existing = await getStaffById(
                connection,
                staffId,
                { forUpdate: true },
            );

            if (!existing) {
                throw createError("Staff account not found.", 404);
            }

            if (data.roleId !== undefined) {
                await ensureRoleIsAssignable(
                    connection,
                    data.roleId,
                    actor,
                );
            }

            if (data.roleId !== undefined) {
                const nextRole = await getRoleById(
                    connection,
                    data.roleId,
                );

                await assertNotLastActiveSuperAdmin(
                    connection,
                    existing,
                    nextRole.code,
                    existing.accountStatus,
                );
            }

            const assignments = Object.keys(data)
                .map((field) => `\`${field}\` = ?`)
                .join(", ");

            await connection.execute(
                `
                    UPDATE admin_staff
                    SET ${assignments}
                    WHERE id = ?
                `,
                [...Object.values(data), staffId],
            );

            const updated = await getStaffById(connection, staffId);

            return {
                id: staffId,
                oldValues: existing,
                newValues: updated,
                item: updated,
            };
        },
    }).then((result) => result.item);
}

/**
 * CHANGE STAFF ACCOUNT STATUS
 *
 * A locked account is unlocked by explicitly setting it to active.
 * Login failure counters are cleared on reactivation.
 */
export async function updateStaffStatus(
    rawStaffId,
    status,
    actor,
    actorStaffId,
    requestContext = {},
) {
    const staffId = normalizeId(rawStaffId);

    if (!MANAGEABLE_STATUSES.includes(status)) {
        throw createError(
            `Status must be one of: ${MANAGEABLE_STATUSES.join(", ")}. Locked accounts can be reactivated by setting status to active.`,
        );
    }

    if (staffId === Number(actorStaffId) && status !== "active") {
        throw createError(
            "You cannot suspend or deactivate your own administrator account.",
            409,
        );
    }

    return withAuditTransaction({
        staffId: actorStaffId,
        action: `staff.status_${status}`,
        entityId: staffId,
        requestContext,
        execute: async (connection) => {
            const existing = await getStaffById(
                connection,
                staffId,
                { forUpdate: true },
            );

            if (!existing) {
                throw createError("Staff account not found.", 404);
            }

            await assertNotLastActiveSuperAdmin(
                connection,
                existing,
                existing.roleCode,
                status,
            );

            await connection.execute(
                `
                    UPDATE admin_staff
                    SET
                        accountStatus = ?,
                        failedLoginAttempts = CASE
                            WHEN ? = 'active' THEN 0
                            ELSE failedLoginAttempts
                        END,
                        lockedUntil = CASE
                            WHEN ? = 'active' THEN NULL
                            ELSE lockedUntil
                        END
                    WHERE id = ?
                `,
                [status, status, status, staffId],
            );

            // Revoke active sessions whenever an account is disabled.
            if (status !== "active") {
                await connection.execute(
                    `
                        UPDATE admin_sessions
                        SET revokedAt = NOW()
                        WHERE staffId = ?
                          AND revokedAt IS NULL
                    `,
                    [staffId],
                );
            }

            const updated = await getStaffById(connection, staffId);

            return {
                id: staffId,
                oldValues: existing,
                newValues: updated,
                item: updated,
            };
        },
    }).then((result) => result.item);
}

/**
 * SET INDIVIDUAL PERMISSION OVERRIDES
 *
 * Each supplied permission is either granted or denied.
 * Omitted permissions remain unchanged.
 */
export async function updateStaffPermissions(
    rawStaffId,
    overrides,
    actor,
    actorStaffId,
    requestContext = {},
) {
    const staffId = normalizeId(rawStaffId);

    if (!Array.isArray(overrides) || overrides.length === 0) {
        throw createError("Provide at least one permission override.");
    }

    if (!isSuperAdmin(actor)) {
        throw createError(
            "Only a super administrator can change individual staff permission overrides.",
            403,
        );
    }

    const normalizedOverrides = [];
    const seen = new Set();

    for (const item of overrides) {
        if (!item || typeof item !== "object") {
            throw createError("Each permission override must be an object.");
        }

        const permissionId = normalizeId(
            item.permissionId,
            "Permission ID",
        );

        if (seen.has(permissionId)) {
            throw createError("A permission can only be included once per request.");
        }

        seen.add(permissionId);

        if (!["grant", "deny"].includes(item.accessType)) {
            throw createError("Permission accessType must be grant or deny.");
        }

        normalizedOverrides.push({
            permissionId,
            accessType: item.accessType,
        });
    }

    return withAuditTransaction({
        staffId: actorStaffId,
        action: "staff.permissions_updated",
        entityId: staffId,
        requestContext,
        execute: async (connection) => {
            const existingStaff = await getStaffById(
                connection,
                staffId,
                { forUpdate: true },
            );

            if (!existingStaff) {
                throw createError("Staff account not found.", 404);
            }

            const [oldRows] = await connection.execute(
                `
                    SELECT
                        sp.permissionId,
                        p.code,
                        sp.accessType
                    FROM admin_staff_permissions sp
                    INNER JOIN admin_permissions p
                        ON p.id = sp.permissionId
                    WHERE sp.staffId = ?
                `,
                [staffId],
            );

            for (const item of normalizedOverrides) {
                const [permissionRows] = await connection.execute(
                    "SELECT id FROM admin_permissions WHERE id = ? LIMIT 1",
                    [item.permissionId],
                );

                if (!permissionRows.length) {
                    throw createError(
                        `Permission ${item.permissionId} does not exist.`,
                        404,
                    );
                }

                await connection.execute(
                    `
                        INSERT INTO admin_staff_permissions (
                            staffId,
                            permissionId,
                            accessType
                        )
                        VALUES (?, ?, ?)
                        ON DUPLICATE KEY UPDATE
                            accessType = VALUES(accessType)
                    `,
                    [
                        staffId,
                        item.permissionId,
                        item.accessType,
                    ],
                );
            }

            const [newRows] = await connection.execute(
                `
                    SELECT
                        sp.permissionId,
                        p.code,
                        sp.accessType
                    FROM admin_staff_permissions sp
                    INNER JOIN admin_permissions p
                        ON p.id = sp.permissionId
                    WHERE sp.staffId = ?
                    ORDER BY p.module, p.action
                `,
                [staffId],
            );

            return {
                id: staffId,
                oldValues: oldRows,
                newValues: newRows,
                item: {
                    staffId,
                    permissionOverrides: newRows,
                },
            };
        },
    }).then((result) => result.item);
}

/**
 * REMOVE AN INDIVIDUAL PERMISSION OVERRIDE
 */
export async function removeStaffPermissionOverride(
    rawStaffId,
    rawPermissionId,
    actor,
    actorStaffId,
    requestContext = {},
) {
    const staffId = normalizeId(rawStaffId);
    const permissionId = normalizeId(rawPermissionId, "Permission ID");

    if (!isSuperAdmin(actor)) {
        throw createError(
            "Only a super administrator can remove individual staff permission overrides.",
            403,
        );
    }

    return withAuditTransaction({
        staffId: actorStaffId,
        action: "staff.permission_override_removed",
        entityId: staffId,
        requestContext,
        execute: async (connection) => {
            const [rows] = await connection.execute(
                `
                    SELECT
                        sp.permissionId,
                        p.code,
                        sp.accessType
                    FROM admin_staff_permissions sp
                    INNER JOIN admin_permissions p
                        ON p.id = sp.permissionId
                    WHERE sp.staffId = ?
                      AND sp.permissionId = ?
                    FOR UPDATE
                `,
                [staffId, permissionId],
            );

            if (!rows.length) {
                throw createError("Permission override not found.", 404);
            }

            await connection.execute(
                `
                    DELETE FROM admin_staff_permissions
                    WHERE staffId = ?
                      AND permissionId = ?
                `,
                [staffId, permissionId],
            );

            return {
                id: staffId,
                oldValues: rows[0],
                newValues: null,
                item: {
                    staffId,
                    removedPermissionId: permissionId,
                },
            };
        },
    }).then((result) => result.item);
}

/**
 * STAFF LOGIN ACTIVITY
 */
export async function getStaffActivity(rawStaffId, query = {}) {
    const staffId = normalizeId(rawStaffId);
    const { limit, page, offset } = normalizePagination(query);

    const [staffRows] = await pool.execute(
        "SELECT id FROM admin_staff WHERE id = ? LIMIT 1",
        [staffId],
    );

    if (!staffRows.length) {
        throw createError("Staff account not found.", 404);
    }

    const [countRows] = await pool.execute(
        "SELECT COUNT(*) AS total FROM admin_login_activity WHERE staffId = ?",
        [staffId],
    );

    const [items] = await pool.execute(
        `
            SELECT
                id,
                staffId,
                eventType,
                ipAddress,
                userAgent,
                description,
                createdAt
            FROM admin_login_activity
            WHERE staffId = ?
            ORDER BY createdAt DESC, id DESC
            LIMIT ? OFFSET ?
        `,
        [staffId, limit, offset],
    );

    const total = Number(countRows[0]?.total ?? 0);

    return {
        items,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
    };
}

/**
 * STAFF SESSIONS
 */
export async function getStaffSessions(rawStaffId, query = {}) {
    const staffId = normalizeId(rawStaffId);
    const { limit, page, offset } = normalizePagination(query);

    const [staffRows] = await pool.execute(
        "SELECT id FROM admin_staff WHERE id = ? LIMIT 1",
        [staffId],
    );

    if (!staffRows.length) {
        throw createError("Staff account not found.", 404);
    }

    const [countRows] = await pool.execute(
        "SELECT COUNT(*) AS total FROM admin_sessions WHERE staffId = ?",
        [staffId],
    );

    const [items] = await pool.execute(
        `
            SELECT
                id,
                staffId,
                deviceName,
                deviceType,
                ipAddress,
                userAgent,
                lastActiveAt,
                expiresAt,
                revokedAt,
                createdAt
            FROM admin_sessions
            WHERE staffId = ?
            ORDER BY createdAt DESC, id DESC
            LIMIT ? OFFSET ?
        `,
        [staffId, limit, offset],
    );

    const total = Number(countRows[0]?.total ?? 0);

    return {
        items,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
    };
}

/**
 * REVOKE A SPECIFIC STAFF SESSION
 */
export async function revokeStaffSession(
    rawStaffId,
    rawSessionId,
    actor,
    actorStaffId,
    requestContext = {},
) {
    const staffId = normalizeId(rawStaffId);
    const sessionId = normalizeId(rawSessionId, "Session ID");

    if (staffId === Number(actorStaffId)) {
        throw createError(
            "Use the normal logout function to revoke your own current session.",
            409,
        );
    }

    return withAuditTransaction({
        staffId: actorStaffId,
        action: "staff.session_revoked",
        entityType: "admin_sessions",
        entityId: sessionId,
        requestContext,
        execute: async (connection) => {
            const [rows] = await connection.execute(
                `
                    SELECT
                        id,
                        staffId,
                        deviceName,
                        deviceType,
                        ipAddress,
                        lastActiveAt,
                        expiresAt,
                        revokedAt,
                        createdAt
                    FROM admin_sessions
                    WHERE id = ?
                      AND staffId = ?
                    LIMIT 1
                    FOR UPDATE
                `,
                [sessionId, staffId],
            );

            if (!rows.length) {
                throw createError("Staff session not found.", 404);
            }

            const existing = rows[0];

            if (existing.revokedAt) {
                throw createError("This session has already been revoked.", 409);
            }

            await connection.execute(
                `
                    UPDATE admin_sessions
                    SET revokedAt = NOW()
                    WHERE id = ?
                      AND staffId = ?
                      AND revokedAt IS NULL
                `,
                [sessionId, staffId],
            );

            return {
                id: sessionId,
                oldValues: existing,
                newValues: {
                    ...existing,
                    revokedAt: new Date().toISOString(),
                },
                item: {
                    sessionId,
                    staffId,
                    revoked: true,
                },
            };
        },
    }).then((result) => result.item);
}
