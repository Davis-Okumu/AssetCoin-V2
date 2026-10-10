
import pool from "../../config/database.js";

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;

function normalizeId(value) {
    const id = Number(value);

    return Number.isSafeInteger(id) && id > 0 ? id : null;
}

function normalizePagination(pageValue, limitValue) {
    const requestedPage = Number(pageValue);
    const requestedLimit = Number(limitValue);

    const page =
        Number.isSafeInteger(requestedPage) && requestedPage > 0
            ? requestedPage
            : 1;

    const limit =
        Number.isSafeInteger(requestedLimit) && requestedLimit > 0
            ? Math.min(requestedLimit, MAX_LIMIT)
            : DEFAULT_LIMIT;

    return {
        page,
        limit,
        offset: (page - 1) * limit,
    };
}

function normalizeFilter(value, allowedValues) {
    if (typeof value !== "string" || !value.trim()) {
        return null;
    }

    const normalized = value.trim().toLowerCase();

    return allowedValues.includes(normalized) ? normalized : null;
}

async function getOwnedNotification(notificationId, staffId) {
    const [rows] = await pool.query(
        `SELECT
            id,
            staffId,
            type,
            title,
            message,
            referenceType,
            referenceId,
            status,
            readAt,
            createdAt
         FROM admin_notifications
         WHERE id = ? AND staffId = ?
         LIMIT 1`,
        [notificationId, staffId],
    );

    return rows[0] ?? null;
}

/**
 * ============================================================
 * ADMIN NOTIFICATIONS OVERVIEW
 * ============================================================
 *
 * Counts are restricted to notifications assigned to the
 * currently authenticated admin staff member.
 */
export async function getAdminNotificationsOverview(staffId) {
    const normalizedStaffId = normalizeId(staffId);

    if (!normalizedStaffId) {
        throw new Error("A valid admin staff ID is required.");
    }

    const [rows] = await pool.query(
        `SELECT
            COUNT(*) AS total,
            COALESCE(SUM(status = 'new'), 0) AS unread,
            COALESCE(SUM(status = 'read'), 0) AS readCount,
            COALESCE(SUM(status = 'archived'), 0) AS archived
         FROM admin_notifications
         WHERE staffId = ?`,
        [normalizedStaffId],
    );

    const result = rows[0];

    return {
        total: Number(result.total),
        unread: Number(result.unread),
        read: Number(result.readCount),
        archived: Number(result.archived),
    };
}

/**
 * ============================================================
 * LIST ADMIN NOTIFICATIONS
 * ============================================================
 */
export async function getAdminNotifications(staffId, filters = {}) {
    const normalizedStaffId = normalizeId(staffId);

    if (!normalizedStaffId) {
        throw new Error("A valid admin staff ID is required.");
    }

    const { page, limit, offset } = normalizePagination(
        filters.page,
        filters.limit,
    );

    const allowedTypes = [
        "system",
        "security",
        "workflow",
        "approval",
        "asset",
        "kyc",
        "tokenization",
        "trading",
        "finance",
        "support",
    ];

    const allowedStatuses = ["new", "read", "archived"];

    const type = normalizeFilter(filters.type, allowedTypes);
    const status = normalizeFilter(filters.status, allowedStatuses);
    const search =
        typeof filters.search === "string"
            ? filters.search.trim().slice(0, 200)
            : "";

    const conditions = ["staffId = ?"];
    const parameters = [normalizedStaffId];

    if (type) {
        conditions.push("type = ?");
        parameters.push(type);
    }

    if (status) {
        conditions.push("status = ?");
        parameters.push(status);
    }

    if (search) {
        conditions.push("(title LIKE ? OR message LIKE ?)");
        parameters.push(`%${search}%`, `%${search}%`);
    }

    const whereClause = conditions.join(" AND ");

    const [countRows] = await pool.query(
        `SELECT COUNT(*) AS total
         FROM admin_notifications
         WHERE ${whereClause}`,
        parameters,
    );

    const total = Number(countRows[0].total);

    const [rows] = await pool.query(
        `SELECT
            id,
            staffId,
            type,
            title,
            message,
            referenceType,
            referenceId,
            status,
            readAt,
            createdAt
         FROM admin_notifications
         WHERE ${whereClause}
         ORDER BY createdAt DESC, id DESC
         LIMIT ? OFFSET ?`,
        [...parameters, limit, offset],
    );

    return {
        items: rows,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
    };
}

/**
 * ============================================================
 * MARK NOTIFICATION AS READ
 * ============================================================
 */
export async function markAdminNotificationAsRead(
    notificationId,
    staffId,
) {
    const normalizedId = normalizeId(notificationId);
    const normalizedStaffId = normalizeId(staffId);

    if (!normalizedId || !normalizedStaffId) {
        throw new Error("Valid notification and staff IDs are required.");
    }

    const notification = await getOwnedNotification(
        normalizedId,
        normalizedStaffId,
    );

    if (!notification) {
        return null;
    }

    if (notification.status === "archived") {
        return {
            conflict: true,
            message: "Archived notifications cannot be marked as read.",
        };
    }

    if (notification.status === "new") {
        await pool.query(
            `UPDATE admin_notifications
             SET status = 'read', readAt = CURRENT_TIMESTAMP
             WHERE id = ? AND staffId = ? AND status = 'new'`,
            [normalizedId, normalizedStaffId],
        );
    }

    return getOwnedNotification(normalizedId, normalizedStaffId);
}

/**
 * ============================================================
 * ARCHIVE NOTIFICATION
 * ============================================================
 */
export async function archiveAdminNotification(
    notificationId,
    staffId,
) {
    const normalizedId = normalizeId(notificationId);
    const normalizedStaffId = normalizeId(staffId);

    if (!normalizedId || !normalizedStaffId) {
        throw new Error("Valid notification and staff IDs are required.");
    }

    const notification = await getOwnedNotification(
        normalizedId,
        normalizedStaffId,
    );

    if (!notification) {
        return null;
    }

    if (notification.status !== "archived") {
        await pool.query(
            `UPDATE admin_notifications
             SET status = 'archived'
             WHERE id = ? AND staffId = ?`,
            [normalizedId, normalizedStaffId],
        );
    }

    return getOwnedNotification(normalizedId, normalizedStaffId);
}
