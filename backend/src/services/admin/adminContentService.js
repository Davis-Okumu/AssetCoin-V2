
import pool from "../../config/database.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

/**
 * ============================================================
 * ADMIN CONTENT MANAGEMENT SERVICE
 * ============================================================
 *
 * Manages:
 * - Announcements
 * - News articles
 * - Publications
 *
 * Content is managed by authorized admin staff.
 * All write operations are audited.
 *
 * This service does not manage customer notifications.
 * ============================================================
 */

const CONTENT_TYPES = {
    announcements: {
        table: "announcements",
        idColumn: "id",
        staffColumn: "publishedByStaffId",
        fields: ["title", "content", "imageUrl", "expiresAt"],
        required: ["title", "content"],
        categories: [],
        hasSummary: false,
        hasImage: true,
        hasDocument: false,
    },
    news: {
        table: "news",
        idColumn: "id",
        staffColumn: "authorStaffId",
        fields: [
            "title",
            "summary",
            "content",
            "imageUrl",
            "category",
        ],
        required: ["title", "content"],
        categories: [
            "market",
            "asset",
            "tokenization",
            "education",
            "company",
            "general",
        ],
        hasSummary: true,
        hasImage: true,
        hasDocument: false,
    },
    publications: {
        table: "publications",
        idColumn: "id",
        staffColumn: "authorStaffId",
        fields: [
            "title",
            "summary",
            "content",
            "imageUrl",
            "documentUrl",
            "category",
        ],
        required: ["title"],
        categories: [
            "education",
            "guide",
            "report",
            "platform",
            "general",
        ],
        hasSummary: true,
        hasImage: true,
        hasDocument: true,
    },
};

function getContentConfig(type) {
    const config = CONTENT_TYPES[String(type ?? "").toLowerCase()];

    if (!config) {
        const error = new Error(
            "Invalid content type. Use announcements, news, or publications.",
        );
        error.statusCode = 400;
        throw error;
    }

    return config;
}

function normalizeId(value) {
    const id = Number(value);

    if (!Number.isSafeInteger(id) || id <= 0) {
        const error = new Error("A valid content ID is required.");
        error.statusCode = 400;
        throw error;
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

function validateContentInput(type, input, { partial = false } = {}) {
    const config = getContentConfig(type);

    if (!input || typeof input !== "object" || Array.isArray(input)) {
        const error = new Error("A valid content object is required.");
        error.statusCode = 400;
        throw error;
    }

    const data = {};

    for (const field of config.fields) {
        if (!Object.prototype.hasOwnProperty.call(input, field)) {
            continue;
        }

        const value = input[field];

        if (value === null || value === "") {
            if (config.required.includes(field)) {
                const error = new Error(`${field} cannot be empty.`);
                error.statusCode = 400;
                throw error;
            }

            data[field] = null;
            continue;
        }

        if (field === "expiresAt") {
            const date = new Date(value);

            if (Number.isNaN(date.getTime())) {
                const error = new Error("expiresAt must be a valid date.");
                error.statusCode = 400;
                throw error;
            }

            data[field] = date;
            continue;
        }

        if (typeof value !== "string") {
            const error = new Error(`${field} must be a string.`);
            error.statusCode = 400;
            throw error;
        }

        const trimmed = value.trim();

        if (config.required.includes(field) && !trimmed) {
            const error = new Error(`${field} cannot be empty.`);
            error.statusCode = 400;
            throw error;
        }

        const maxLengths = {
            title: 250,
            summary: 500,
            imageUrl: 255,
            documentUrl: 500,
        };

        if (
            maxLengths[field] &&
            trimmed.length > maxLengths[field]
        ) {
            const error = new Error(
                `${field} cannot exceed ${maxLengths[field]} characters.`,
            );
            error.statusCode = 400;
            throw error;
        }

        if (
            field === "category" &&
            config.categories.length > 0 &&
            !config.categories.includes(trimmed)
        ) {
            const error = new Error(
                `Invalid category. Allowed values: ${config.categories.join(", ")}.`,
            );
            error.statusCode = 400;
            throw error;
        }

        data[field] = trimmed;
    }

    if (!partial) {
        for (const field of config.required) {
            if (
                !Object.prototype.hasOwnProperty.call(data, field) ||
                !data[field]
            ) {
                const error = new Error(`${field} is required.`);
                error.statusCode = 400;
                throw error;
            }
        }
    }

    if (partial && Object.keys(data).length === 0) {
        const error = new Error("Provide at least one field to update.");
        error.statusCode = 400;
        throw error;
    }

    return data;
}

async function getById(connection, config, id) {
    const [rows] = await connection.execute(
        `SELECT *
         FROM \`${config.table}\`
         WHERE \`${config.idColumn}\` = ?
         LIMIT 1`,
        [id],
    );

    return rows[0] ?? null;
}

async function withAuditTransaction({
    staffId,
    action,
    entityType,
    entityId,
    oldValues,
    newValues,
    requestContext = {},
    execute,
}) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        // Execute the operation and retrieve its result.
        const result = await execute(connection);

        // Record the actual before-and-after values returned by the
        // operation, falling back to explicitly supplied audit values.
        await writeAdminAuditLog({
            connection,
            staffId,
            action,
            module: "content",
            entityType,
            entityId:
                entityId ??
                result?.id ??
                result?.item?.id ??
                null,
            oldValues:
                result?.oldValues ??
                oldValues ??
                null,
            newValues:
                result?.newValues ??
                newValues ??
                result ??
                null,
            ipAddress: requestContext.ipAddress ?? null,
            userAgent: requestContext.userAgent ?? null,
        });

        await connection.commit();

        return result;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * CONTENT OVERVIEW
 */

export async function getContentOverview() {
    const [announcementCounts] = await pool.execute(`
        SELECT
            COUNT(*) AS total,
            SUM(status = 'draft') AS drafts,
            SUM(status = 'published') AS published,
            SUM(status = 'archived') AS archived
        FROM announcements
    `);

    const [newsCounts] = await pool.execute(`
        SELECT
            COUNT(*) AS total,
            SUM(status = 'draft') AS drafts,
            SUM(status = 'published') AS published,
            SUM(status = 'archived') AS archived
        FROM news
    `);

    const [publicationCounts] = await pool.execute(`
        SELECT
            COUNT(*) AS total,
            SUM(status = 'draft') AS drafts,
            SUM(status = 'published') AS published,
            SUM(status = 'archived') AS archived
        FROM publications
    `);

    return {
        announcements: announcementCounts[0],
        news: newsCounts[0],
        publications: publicationCounts[0],
    };
}

/**
 * LIST CONTENT
 */

export async function listContent(type, query = {}) {
    const config = getContentConfig(type);
    const { limit, page, offset } = normalizePagination(query);

    const conditions = [];
    const params = [];

    if (query.status) {
        if (!["draft", "published", "archived"].includes(query.status)) {
            const error = new Error("Invalid content status.");
            error.statusCode = 400;
            throw error;
        }

        conditions.push("status = ?");
        params.push(query.status);
    }

    if (query.category && config.categories.length > 0) {
        if (!config.categories.includes(query.category)) {
            const error = new Error("Invalid content category.");
            error.statusCode = 400;
            throw error;
        }

        conditions.push("category = ?");
        params.push(query.category);
    }

    if (query.search) {
        const search = String(query.search).trim().slice(0, 150);

        if (search) {
            conditions.push("(title LIKE ? OR content LIKE ?)");
            params.push(`%${search}%`, `%${search}%`);
        }
    }

    const whereClause = conditions.length
        ? `WHERE ${conditions.join(" AND ")}`
        : "";

    const [countRows] = await pool.execute(
        `SELECT COUNT(*) AS total
         FROM \`${config.table}\`
         ${whereClause}`,
        params,
    );

    const [items] = await pool.execute(
        `SELECT *
         FROM \`${config.table}\`
         ${whereClause}
         ORDER BY createdAt DESC, id DESC
         LIMIT ? OFFSET ?`,
        [...params, limit, offset],
    );

    return {
        items,
        pagination: {
            page,
            limit,
            total: Number(countRows[0].total),
            totalPages: Math.ceil(Number(countRows[0].total) / limit),
        },
    };
}

/**
 * GET CONTENT DETAILS
 */

export async function getContentDetails(type, rawId) {
    const config = getContentConfig(type);
    const id = normalizeId(rawId);
    const item = await getById(pool, config, id);

    if (!item) {
        const error = new Error("Content not found.");
        error.statusCode = 404;
        throw error;
    }

    return item;
}

/**
 * CREATE CONTENT
 */

export async function createContent(
    type,
    input,
    staffId,
    requestContext = {},
) {
    const config = getContentConfig(type);
    const data = validateContentInput(type, input);

    return withAuditTransaction({
        staffId,
        action: "content.created",
        entityType: type,
        requestContext,
        newValues: data,
        execute: async (connection) => {
            const fields = [...Object.keys(data), config.staffColumn];
            const values = [...Object.values(data), staffId];
            const placeholders = fields.map(() => "?").join(", ");

            const [result] = await connection.execute(
                `INSERT INTO \`${config.table}\`
                 (${fields.map((field) => `\`${field}\``).join(", ")})
                 VALUES (${placeholders})`,
                values,
            );

            const item = await getById(
                connection,
                config,
                result.insertId,
            );

            return {
                id: result.insertId,
                newValues: item,
                item,
            };
        },
    }).then((result) => result.item);
}

/**
 * UPDATE DRAFT OR EXISTING CONTENT
 */

export async function updateContent(
    type,
    rawId,
    input,
    staffId,
    requestContext = {},
) {
    const config = getContentConfig(type);
    const id = normalizeId(rawId);
    const data = validateContentInput(type, input, { partial: true });

    return withAuditTransaction({
        staffId,
        action: "content.updated",
        entityType: type,
        entityId: id,
        requestContext,
        execute: async (connection) => {
            const existing = await getById(connection, config, id);

            if (!existing) {
                const error = new Error("Content not found.");
                error.statusCode = 404;
                throw error;
            }

            const assignments = Object.keys(data)
                .map((field) => `\`${field}\` = ?`)
                .join(", ");

            await connection.execute(
                `UPDATE \`${config.table}\`
                 SET ${assignments}
                 WHERE \`${config.idColumn}\` = ?`,
                [...Object.values(data), id],
            );

            const updated = await getById(connection, config, id);

            return {
                id,
                oldValues: existing,
                newValues: updated,
                item: updated,
            };
        },
    }).then((result) => result.item);
}

/**
 * PUBLISH CONTENT
 */

export async function publishContent(
    type,
    rawId,
    staffId,
    requestContext = {},
) {
    const config = getContentConfig(type);
    const id = normalizeId(rawId);

    if (type === "publications" && !config.hasDocument) {
        const error = new Error("Invalid publication configuration.");
        error.statusCode = 400;
        throw error;
    }

    return withAuditTransaction({
        staffId,
        action: "content.published",
        entityType: type,
        entityId: id,
        requestContext,
        execute: async (connection) => {
            const existing = await getById(connection, config, id);

            if (!existing) {
                const error = new Error("Content not found.");
                error.statusCode = 404;
                throw error;
            }

            if (type === "publications" && !existing.documentUrl) {
                const error = new Error(
                    "Add a document URL before publishing this publication.",
                );
                error.statusCode = 400;
                throw error;
            }

            const updates = [
                "status = 'published'",
                "publishedAt = COALESCE(publishedAt, CURRENT_TIMESTAMP)",
            ];
            const values = [];

            if (type === "announcements") {
                updates.push("publishedByStaffId = ?");
                values.push(staffId);
            }

            values.push(id);

            await connection.execute(
                `UPDATE \`${config.table}\`
                 SET ${updates.join(", ")}
                 WHERE \`${config.idColumn}\` = ?`,
                values,
            );

            const updated = await getById(connection, config, id);

            return {
                id,
                oldValues: existing,
                newValues: updated,
                item: updated,
            };
        },
    }).then((result) => result.item);
}

/**
 * ARCHIVE CONTENT
 */

export async function archiveContent(
    type,
    rawId,
    staffId,
    requestContext = {},
) {
    const config = getContentConfig(type);
    const id = normalizeId(rawId);

    return withAuditTransaction({
        staffId,
        action: "content.archived",
        entityType: type,
        entityId: id,
        requestContext,
        execute: async (connection) => {
            const existing = await getById(connection, config, id);

            if (!existing) {
                const error = new Error("Content not found.");
                error.statusCode = 404;
                throw error;
            }

            await connection.execute(
                `UPDATE \`${config.table}\`
                 SET status = 'archived'
                 WHERE \`${config.idColumn}\` = ?`,
                [id],
            );

            const updated = await getById(connection, config, id);

            return {
                id,
                oldValues: existing,
                newValues: updated,
                item: updated,
            };
        },
    }).then((result) => result.item);
}

/**
 * DELETE CONTENT
 */

export async function deleteContent(
    type,
    rawId,
    staffId,
    requestContext = {},
) {
    const config = getContentConfig(type);
    const id = normalizeId(rawId);

    return withAuditTransaction({
        staffId,
        action: "content.deleted",
        entityType: type,
        entityId: id,
        requestContext,
        execute: async (connection) => {
            const existing = await getById(connection, config, id);

            if (!existing) {
                const error = new Error("Content not found.");
                error.statusCode = 404;
                throw error;
            }

            if (existing.status === "published") {
                const error = new Error(
                    "Published content cannot be deleted. Archive it instead.",
                );
                error.statusCode = 409;
                throw error;
            }

            await connection.execute(
                `DELETE FROM \`${config.table}\`
                 WHERE \`${config.idColumn}\` = ?`,
                [id],
            );

            return {
                id,
                deleted: true,
                oldValues: existing,
                newValues: null,
                title: existing.title,
                status: existing.status,
            };
        },
    });
}
