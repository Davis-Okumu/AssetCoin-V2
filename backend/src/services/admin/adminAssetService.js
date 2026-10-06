import pool from "../../config/database.js";

import { writeAdminAuditLog } from "./adminAuditService.js";


// =========================================================
// ADMIN ASSET SERVICE
// =========================================================
//
// Responsibilities:
// - List assets for administrators.
// - Retrieve complete asset review information.
// - Review submitted assets.
// - Approve assets.
// - Reject assets.
// - Request changes.
// - Suspend assets.
// - Record normalized asset reviews.
// - Record asset status history.
// - Write hash-linked administrator audit logs.
// - Protect mutations with database transactions.
// - Lock assets with FOR UPDATE before mutations.
//
// IMPORTANT:
// - This service is for the ADMIN API only.
// - Customer-facing assetService.js is not modified here.
// - Financial/token balances are not changed by this service.
// - Permission checks belong to admin middleware/routes.
// - Business mutations and audit logs use the SAME transaction.
//
// =========================================================


// =========================================================
// CONSTANTS
// =========================================================

const ASSET_STATUSES = [
    "draft",
    "pending",
    "under_review",
    "changes_required",
    "approved",
    "rejected",
    "tokenized",
    "suspended",
];

const REVIEW_DECISIONS = [
    "under_review",
    "changes_required",
    "approved",
    "rejected",
];

const STATUS_CHANGEABLE = [
    "suspended",
    "approved",
];

const SORT_COLUMNS = {
    id: "a.id",
    assetCode: "a.assetCode",
    name: "a.name",
    assetType: "a.assetType",
    estimatedValue: "a.estimatedValue",
    status: "a.status",
    createdAt: "a.createdAt",
    updatedAt: "a.updatedAt",
};


// =========================================================
// GENERAL HELPERS
// =========================================================

function toPositiveInt(value, fallback = null) {
    const number = Number(value);

    if (!Number.isInteger(number) || number <= 0) {
        return fallback;
    }

    return number;
}


function cleanString(value, fallback = null) {
    if (value === undefined || value === null) {
        return fallback;
    }

    const cleaned = String(value).trim();

    return cleaned.length > 0 ? cleaned : fallback;
}


function normalizeStatus(value) {
    return cleanString(value)?.toLowerCase() ?? null;
}


function normalizeDecision(value) {
    return cleanString(value)?.toLowerCase() ?? null;
}


function parseBoolean(value) {
    if (value === true || value === false) {
        return value;
    }

    if (value === "true" || value === "1") {
        return true;
    }

    if (value === "false" || value === "0") {
        return false;
    }

    return null;
}


function parsePagination(query = {}) {
    const page = Math.max(
        1,
        toPositiveInt(query.page, 1),
    );

    const limit = Math.min(
        100,
        Math.max(
            1,
            toPositiveInt(query.limit, 20),
        ),
    );

    return {
        page,
        limit,
        offset: (page - 1) * limit,
    };
}


function getSort(query = {}) {
    const requestedSort = cleanString(query.sort, "createdAt");

    const sortColumn =
        SORT_COLUMNS[requestedSort] ??
        SORT_COLUMNS.createdAt;

    const direction =
        String(query.order ?? "DESC").toUpperCase() === "ASC"
            ? "ASC"
            : "DESC";

    return {
        sortColumn,
        direction,
    };
}


function createServiceError(message, statusCode = 400) {
    const error = new Error(message);

    error.statusCode = statusCode;

    return error;
}


function getRequestContext(adminContext = {}) {
    return {
        adminId:
            adminContext.adminId ??
            adminContext.staffId ??
            null,

        ipAddress:
            adminContext.ipAddress ??
            null,

        userAgent:
            adminContext.userAgent ??
            null,
    };
}


// =========================================================
// ASSET SERIALIZATION
// =========================================================

function serializeAsset(row) {
    if (!row) {
        return null;
    }

    return {
        id: row.id,
        ownerId: row.ownerId,
        assetCode: row.assetCode,

        assetType: row.assetType,

        name: row.name,
        description: row.description,

        location: row.location,
        latitude: row.latitude,
        longitude: row.longitude,

        registrationNumber: row.registrationNumber,

        estimatedValue: row.estimatedValue,
        currency: row.currency,

        status: row.status,

        rejectionReason:
            row.rejectionReason ?? null,

        approvedBy:
            row.approvedBy ?? null,

        approvedAt:
            row.approvedAt ?? null,

        reviewedBy:
            row.reviewedBy ?? null,

        reviewedAt:
            row.reviewedAt ?? null,

        reviewNotes:
            row.reviewNotes ?? null,

        createdAt:
            row.createdAt ?? null,

        updatedAt:
            row.updatedAt ?? null,

        owner: {
            id: row.ownerId,
            firstName: row.ownerFirstName ?? null,
            lastName: row.ownerLastName ?? null,
            email: row.ownerEmail ?? null,
            phone: row.ownerPhone ?? null,
            kycStatus: row.ownerKycStatus ?? null,
        },

        reviewSummary: {
            reviewCount:
                Number(row.reviewCount ?? 0),

            latestDecision:
                row.latestReviewDecision ?? null,

            latestReviewAt:
                row.latestReviewAt ?? null,
        },

        tokenSummary: {
            tokenCount:
                Number(row.tokenCount ?? 0),

            tokenCode:
                row.tokenCode ?? null,

            tokenName:
                row.tokenName ?? null,

            totalSupply:
                row.totalSupply ?? null,

            availableSupply:
                row.availableSupply ?? null,

            tokenPrice:
                row.tokenPrice ?? null,

            tokenCurrency:
                row.tokenCurrency ?? null,

            tokenStatus:
                row.tokenStatus ?? null,
        },
    };
}


// =========================================================
// ASSET SELECT
// =========================================================
//
// Centralized base SELECT so list/detail queries remain
// consistent.
//
// =========================================================

const ASSET_SELECT = `
    SELECT
        a.id,
        a.ownerId,
        a.assetCode,
        a.assetType,
        a.name,
        a.description,
        a.location,
        a.latitude,
        a.longitude,
        a.registrationNumber,
        a.estimatedValue,
        a.currency,
        a.status,
        a.rejectionReason,
        a.approvedBy,
        a.approvedAt,
        a.reviewedBy,
        a.reviewedAt,
        a.reviewNotes,
        a.createdAt,
        a.updatedAt,

        u.firstName AS ownerFirstName,
        u.lastName AS ownerLastName,
        u.email AS ownerEmail,
        u.phone AS ownerPhone,
        u.kycStatus AS ownerKycStatus,

        (
            SELECT COUNT(*)
            FROM asset_reviews ar
            WHERE ar.assetId = a.id
        ) AS reviewCount,

        (
            SELECT ar.decision
            FROM asset_reviews ar
            WHERE ar.assetId = a.id
            ORDER BY ar.id DESC
            LIMIT 1
        ) AS latestReviewDecision,

        (
            SELECT ar.createdAt
            FROM asset_reviews ar
            WHERE ar.assetId = a.id
            ORDER BY ar.id DESC
            LIMIT 1
        ) AS latestReviewAt,

        (
            SELECT COUNT(*)
            FROM tokens t
            WHERE t.assetId = a.id
        ) AS tokenCount,

        (
            SELECT t.tokenCode
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS tokenCode,

        (
            SELECT t.tokenName
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS tokenName,

        (
            SELECT t.totalSupply
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS totalSupply,

        (
            SELECT t.availableSupply
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS availableSupply,

        (
            SELECT t.tokenPrice
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS tokenPrice,

        (
            SELECT t.currency
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS tokenCurrency,

        (
            SELECT t.status
            FROM tokens t
            WHERE t.assetId = a.id
            ORDER BY t.id DESC
            LIMIT 1
        ) AS tokenStatus

    FROM assets a
    INNER JOIN users u
        ON u.id = a.ownerId
`;


// =========================================================
// GET ASSETS
// =========================================================

/**
 * List assets for the admin dashboard.
 *
 * Supported query parameters:
 *
 * page
 * limit
 * search
 * status
 * assetType
 * ownerId
 * sort
 * order
 */
export async function listAssets(query = {}) {
    const {
        page,
        limit,
        offset,
    } = parsePagination(query);

    const {
        sortColumn,
        direction,
    } = getSort(query);

    const search =
        cleanString(query.search) ?? null;

    const status =
        normalizeStatus(query.status);

    const assetType =
        cleanString(query.assetType)?.toLowerCase() ?? null;

    const ownerId =
        toPositiveInt(query.ownerId);

    const conditions = [];
    const params = [];
    const countParams = [];

    if (search) {
        conditions.push(`
            (
                a.assetCode LIKE ?
                OR a.name LIKE ?
                OR a.registrationNumber LIKE ?
                OR CONCAT(
                    u.firstName,
                    ' ',
                    u.lastName
                ) LIKE ?
                OR u.email LIKE ?
            )
        `);

        const searchValue = `%${search}%`;

        params.push(
            searchValue,
            searchValue,
            searchValue,
            searchValue,
            searchValue,
        );

        countParams.push(
            searchValue,
            searchValue,
            searchValue,
            searchValue,
            searchValue,
        );
    }

    if (status) {
        if (!ASSET_STATUSES.includes(status)) {
            throw createServiceError(
                `Invalid asset status: ${status}.`,
            );
        }

        conditions.push("a.status = ?");
        params.push(status);
        countParams.push(status);
    }

    if (assetType) {
        conditions.push("a.assetType = ?");
        params.push(assetType);
        countParams.push(assetType);
    }

    if (ownerId) {
        conditions.push("a.ownerId = ?");
        params.push(ownerId);
        countParams.push(ownerId);
    }

    const whereClause =
        conditions.length > 0
            ? `WHERE ${conditions.join(" AND ")}`
            : "";

    const [countRows] = await pool.execute(
        `
            SELECT COUNT(*) AS total
            FROM assets a
            INNER JOIN users u
                ON u.id = a.ownerId
            ${whereClause}
        `,
        countParams,
    );

    const total =
        Number(countRows[0]?.total ?? 0);

    const [rows] = await pool.execute(
        `
            ${ASSET_SELECT}

            ${whereClause}

            ORDER BY ${sortColumn} ${direction}

            LIMIT ? OFFSET ?
        `,
        [
            ...params,
            limit,
            offset,
        ],
    );

    return {
        items: rows.map(serializeAsset),

        pagination: {
            page,
            limit,
            total,
            totalPages:
                Math.ceil(total / limit),
        },
    };
}


// =========================================================
// GET ASSET BY ID
// =========================================================

/**
 * Retrieve a complete asset record for administrative review.
 *
 * This includes:
 * - owner
 * - asset metadata
 * - photos
 * - documents
 * - valuations
 * - reviews
 * - status history
 * - token information
 */
export async function getAssetById(assetId) {
    const id = toPositiveInt(assetId);

    if (!id) {
        throw createServiceError(
            "A valid asset ID is required.",
        );
    }

    const [assetRows] = await pool.execute(
        `
            ${ASSET_SELECT}

            WHERE a.id = ?

            LIMIT 1
        `,
        [id],
    );

    if (assetRows.length === 0) {
        throw createServiceError(
            "Asset not found.",
            404,
        );
    }

    const asset = serializeAsset(
        assetRows[0],
    );

    const [
        photoRows,
        documentRows,
        valuationRows,
        reviewRows,
        statusHistoryRows,
        tokenRows,
    ] = await Promise.all([
        getAssetPhotos(id),
        getAssetDocuments(id),
        getAssetValuations(id),
        getAssetReviews(id),
        getAssetStatusHistory(id),
        getAssetTokens(id),
    ]);

    return {
        ...asset,

        photos: photoRows,
        documents: documentRows,
        valuations: valuationRows,
        reviews: reviewRows,
        statusHistory: statusHistoryRows,
        tokens: tokenRows,
    };
}


// =========================================================
// GET ASSET PHOTOS
// =========================================================

async function getAssetPhotos(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                id,
                assetId,
                photoUrl,
                isPrimary,
                displayOrder,
                createdAt
            FROM asset_photos
            WHERE assetId = ?
            ORDER BY
                isPrimary DESC,
                displayOrder ASC,
                id ASC
        `,
        [assetId],
    );

    return rows;
}


// =========================================================
// GET ASSET DOCUMENTS
// =========================================================

async function getAssetDocuments(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                id,
                assetId,
                documentType,
                documentName,
                documentUrl,
                documentHash,
                status,
                verifiedBy,
                verifiedAt,
                createdAt
            FROM asset_documents
            WHERE assetId = ?
            ORDER BY id ASC
        `,
        [assetId],
    );

    return rows;
}


// =========================================================
// GET ASSET VALUATIONS
// =========================================================

async function getAssetValuations(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                id,
                assetId,
                valuationAmount,
                currency,
                valuationMethod,
                valuerName,
                valuationDocumentId,
                notes,
                status,
                valuedAt,
                createdAt
            FROM asset_valuations
            WHERE assetId = ?
            ORDER BY id DESC
        `,
        [assetId],
    );

    return rows;
}


// =========================================================
// GET ASSET REVIEWS
// =========================================================

async function getAssetReviews(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                ar.id,
                ar.assetId,
                ar.adminId,
                ar.decision,
                ar.comments,
                ar.createdAt,

                u.firstName AS adminFirstName,
                u.lastName AS adminLastName,
                u.email AS adminEmail

            FROM asset_reviews ar

            LEFT JOIN users u
                ON u.id = ar.adminId

            WHERE ar.assetId = ?

            ORDER BY ar.id DESC
        `,
        [assetId],
    );

    return rows.map((row) => ({
        id: row.id,
        assetId: row.assetId,
        adminId: row.adminId,

        decision: row.decision,
        comments: row.comments,

        createdAt: row.createdAt,

        admin: {
            id: row.adminId,
            firstName: row.adminFirstName,
            lastName: row.adminLastName,
            email: row.adminEmail,
        },
    }));
}


// =========================================================
// GET ASSET STATUS HISTORY
// =========================================================

async function getAssetStatusHistory(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                ash.id,
                ash.assetId,
                ash.previousStatus,
                ash.newStatus,
                ash.changedBy,
                ash.changeReason,
                ash.createdAt,

                u.firstName AS changedByFirstName,
                u.lastName AS changedByLastName,
                u.email AS changedByEmail

            FROM asset_status_history ash

            LEFT JOIN users u
                ON u.id = ash.changedBy

            WHERE ash.assetId = ?

            ORDER BY ash.id DESC
        `,
        [assetId],
    );

    return rows.map((row) => ({
        id: row.id,
        assetId: row.assetId,

        previousStatus:
            row.previousStatus,

        newStatus:
            row.newStatus,

        changedBy:
            row.changedBy,

        changeReason:
            row.changeReason,

        createdAt:
            row.createdAt,

        administrator: row.changedBy
            ? {
                id: row.changedBy,
                firstName:
                    row.changedByFirstName,
                lastName:
                    row.changedByLastName,
                email:
                    row.changedByEmail,
            }
            : null,
    }));
}


// =========================================================
// GET ASSET TOKENS
// =========================================================

async function getAssetTokens(assetId) {
    const [rows] = await pool.execute(
        `
            SELECT
                id,
                assetId,
                tokenCode,
                tokenName,
                description,
                totalSupply,
                availableSupply,
                tokenPrice,
                currency,
                decimals,
                status,
                mintedAt,
                createdAt,
                updatedAt
            FROM tokens
            WHERE assetId = ?
            ORDER BY id DESC
        `,
        [assetId],
    );

    return rows;
}


// =========================================================
// LOCK ASSET
// =========================================================
//
// Used only inside an active transaction.
//
// =========================================================

async function lockAsset(connection, assetId) {
    const [rows] = await connection.execute(
        `
            SELECT
                id,
                ownerId,
                assetCode,
                assetType,
                name,
                description,
                location,
                latitude,
                longitude,
                registrationNumber,
                estimatedValue,
                currency,
                status,
                rejectionReason,
                approvedBy,
                approvedAt,
                reviewedBy,
                reviewedAt,
                reviewNotes,
                createdAt,
                updatedAt
            FROM assets
            WHERE id = ?
            LIMIT 1
            FOR UPDATE
        `,
        [assetId],
    );

    if (rows.length === 0) {
        throw createServiceError(
            "Asset not found.",
            404,
        );
    }

    return rows[0];
}


// =========================================================
// RECORD STATUS HISTORY
// =========================================================

async function recordStatusHistory({
    connection,
    assetId,
    previousStatus,
    newStatus,
    changedBy,
    changeReason,
}) {
    await connection.execute(
        `
            INSERT INTO asset_status_history (
                assetId,
                previousStatus,
                newStatus,
                changedBy,
                changeReason,
                createdAt
            )
            VALUES (?, ?, ?, ?, ?, NOW())
        `,
        [
            assetId,
            previousStatus,
            newStatus,
            changedBy,
            changeReason,
        ],
    );
}


// =========================================================
// RECORD REVIEW
// =========================================================

async function recordReview({
    connection,
    assetId,
    adminId,
    decision,
    comments,
}) {
    await connection.execute(
        `
            INSERT INTO asset_reviews (
                assetId,
                adminId,
                decision,
                comments,
                createdAt
            )
            VALUES (?, ?, ?, ?, NOW())
        `,
        [
            assetId,
            adminId,
            decision,
            comments,
        ],
    );
}


// =========================================================
// VALIDATE REVIEW DECISION
// =========================================================

function validateReviewDecision(decision) {
    if (!REVIEW_DECISIONS.includes(decision)) {
        throw createServiceError(
            `Invalid review decision: ${decision}.`,
        );
    }
}


// =========================================================
// REVIEW ASSET
// =========================================================

/**
 * Record an administrative asset review.
 *
 * Supported decisions:
 *
 * under_review
 * changes_required
 * approved
 * rejected
 *
 * This operation updates the normalized review table and
 * synchronizes the asset's current workflow status.
 */
export async function reviewAsset({
    assetId,
    decision,
    comments = null,
    adminContext = {},
}) {
    const id = toPositiveInt(assetId);

    if (!id) {
        throw createServiceError(
            "A valid asset ID is required.",
        );
    }

    const normalizedDecision =
        normalizeDecision(decision);

    validateReviewDecision(
        normalizedDecision,
    );

    const normalizedComments =
        cleanString(comments);

    const {
        adminId,
        ipAddress,
        userAgent,
    } = getRequestContext(adminContext);

    if (!adminId) {
        throw createServiceError(
            "Administrator identity is required.",
            401,
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const asset =
            await lockAsset(connection, id);

        const previousStatus =
            asset.status;

        // -----------------------------------------------------
        // Validate workflow
        // -----------------------------------------------------

        if (
            normalizedDecision === "under_review" &&
            ![
                "pending",
                "changes_required",
                "under_review",
            ].includes(asset.status)
        ) {
            throw createServiceError(
                `Asset cannot be moved to under_review from ${asset.status}.`,
            );
        }

        if (
            normalizedDecision === "changes_required" &&
            ![
                "under_review",
                "pending",
            ].includes(asset.status)
        ) {
            throw createServiceError(
                `Asset cannot be marked changes_required from ${asset.status}.`,
            );
        }

        if (
            normalizedDecision === "approved" &&
            ![
                "under_review",
                "pending",
                "changes_required",
            ].includes(asset.status)
        ) {
            throw createServiceError(
                `Asset cannot be approved from ${asset.status}.`,
            );
        }

        if (
            normalizedDecision === "rejected" &&
            ![
                "under_review",
                "pending",
                "changes_required",
            ].includes(asset.status)
        ) {
            throw createServiceError(
                `Asset cannot be rejected from ${asset.status}.`,
            );
        }

        // -----------------------------------------------------
        // Determine resulting asset status
        // -----------------------------------------------------

        const newStatus =
            normalizedDecision;

        // -----------------------------------------------------
        // Update asset
        // -----------------------------------------------------

        if (newStatus === "approved") {
            await connection.execute(
                `
                    UPDATE assets
                    SET
                        status = ?,
                        rejectionReason = NULL,
                        approvedBy = ?,
                        approvedAt = NOW(),
                        reviewedBy = ?,
                        reviewedAt = NOW(),
                        reviewNotes = ?,
                        updatedAt = NOW()
                    WHERE id = ?
                `,
                [
                    newStatus,
                    adminId,
                    adminId,
                    normalizedComments,
                    id,
                ],
            );
        } else if (newStatus === "rejected") {
            await connection.execute(
                `
                    UPDATE assets
                    SET
                        status = ?,
                        rejectionReason = ?,
                        approvedBy = NULL,
                        approvedAt = NULL,
                        reviewedBy = ?,
                        reviewedAt = NOW(),
                        reviewNotes = ?,
                        updatedAt = NOW()
                    WHERE id = ?
                `,
                [
                    newStatus,
                    normalizedComments,
                    adminId,
                    normalizedComments,
                    id,
                ],
            );
        } else {
            await connection.execute(
                `
                    UPDATE assets
                    SET
                        status = ?,
                        reviewedBy = ?,
                        reviewedAt = NOW(),
                        reviewNotes = ?,
                        updatedAt = NOW()
                    WHERE id = ?
                `,
                [
                    newStatus,
                    adminId,
                    normalizedComments,
                    id,
                ],
            );
        }

        // -----------------------------------------------------
        // Record normalized review
        // -----------------------------------------------------

        await recordReview({
            connection,
            assetId: id,
            adminId,
            decision: normalizedDecision,
            comments: normalizedComments,
        });

        // -----------------------------------------------------
        // Record status history
        // -----------------------------------------------------

        if (previousStatus !== newStatus) {
            await recordStatusHistory({
                connection,
                assetId: id,
                previousStatus,
                newStatus,
                changedBy: adminId,
                changeReason:
                    normalizedComments,
            });
        }

        // -----------------------------------------------------
        // Fetch new asset state
        // -----------------------------------------------------

        const [updatedRows] =
            await connection.execute(
                `
                    SELECT
                        id,
                        ownerId,
                        assetCode,
                        assetType,
                        name,
                        description,
                        location,
                        latitude,
                        longitude,
                        registrationNumber,
                        estimatedValue,
                        currency,
                        status,
                        rejectionReason,
                        approvedBy,
                        approvedAt,
                        reviewedBy,
                        reviewedAt,
                        reviewNotes,
                        createdAt,
                        updatedAt
                    FROM assets
                    WHERE id = ?
                    LIMIT 1
                `,
                [id],
            );

        const updatedAsset =
            updatedRows[0];

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: adminId,
            action: `asset.${normalizedDecision}`,
            module: "assets",
            entityType: "asset",
            entityId: id,
            oldValues: asset,
            newValues: updatedAsset,
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            asset: updatedAsset,
            review: {
                decision:
                    normalizedDecision,
                comments:
                    normalizedComments,
            },
        };
    } catch (error) {
        try {
            await connection.rollback();
        } catch (rollbackError) {
            console.error(
                "Admin asset review rollback failed:",
                rollbackError,
            );
        }

        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// CHANGE ASSET STATUS
// =========================================================

/**
 * Change an asset's administrative status.
 *
 * This endpoint is intended for status operations that are
 * separate from an asset review decision, especially:
 *
 * - suspension
 * - restoration to approved
 *
 * Review decisions should use reviewAsset().
 */
export async function changeAssetStatus({
    assetId,
    status,
    reason = null,
    adminContext = {},
}) {
    const id = toPositiveInt(assetId);

    if (!id) {
        throw createServiceError(
            "A valid asset ID is required.",
        );
    }

    const newStatus =
        normalizeStatus(status);

    if (!newStatus) {
        throw createServiceError(
            "Asset status is required.",
        );
    }

    if (!STATUS_CHANGEABLE.includes(newStatus)) {
        throw createServiceError(
            `Status '${newStatus}' must be handled through the asset review workflow.`,
        );
    }

    const normalizedReason =
        cleanString(reason);

    const {
        adminId,
        ipAddress,
        userAgent,
    } = getRequestContext(adminContext);

    if (!adminId) {
        throw createServiceError(
            "Administrator identity is required.",
            401,
        );
    }

    if (
        newStatus === "suspended" &&
        !normalizedReason
    ) {
        throw createServiceError(
            "A reason is required when suspending an asset.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const asset =
            await lockAsset(connection, id);

        const previousStatus =
            asset.status;

        // -----------------------------------------------------
        // Validate suspension
        // -----------------------------------------------------

        if (newStatus === "suspended") {
            if (
                ![
                    "approved",
                    "tokenized",
                ].includes(asset.status)
            ) {
                throw createServiceError(
                    `Asset cannot be suspended from ${asset.status}.`,
                );
            }
        }

        // -----------------------------------------------------
        // Validate restoration
        // -----------------------------------------------------

        if (newStatus === "approved") {
            if (asset.status !== "suspended") {
                throw createServiceError(
                    `Only suspended assets can be restored to approved. Current status: ${asset.status}.`,
                );
            }
        }

        // -----------------------------------------------------
        // Update asset
        // -----------------------------------------------------

        if (newStatus === "suspended") {
            await connection.execute(
                `
                    UPDATE assets
                    SET
                        status = ?,
                        rejectionReason = ?,
                        updatedAt = NOW()
                    WHERE id = ?
                `,
                [
                    newStatus,
                    normalizedReason,
                    id,
                ],
            );
        } else {
            await connection.execute(
                `
                    UPDATE assets
                    SET
                        status = ?,
                        rejectionReason = NULL,
                        updatedAt = NOW()
                    WHERE id = ?
                `,
                [
                    newStatus,
                    id,
                ],
            );
        }

        // -----------------------------------------------------
        // Record status history
        // -----------------------------------------------------

        await recordStatusHistory({
            connection,
            assetId: id,
            previousStatus,
            newStatus,
            changedBy: adminId,
            changeReason:
                normalizedReason,
        });

        // -----------------------------------------------------
        // Fetch updated state
        // -----------------------------------------------------

        const [updatedRows] =
            await connection.execute(
                `
                    SELECT
                        id,
                        ownerId,
                        assetCode,
                        assetType,
                        name,
                        description,
                        location,
                        latitude,
                        longitude,
                        registrationNumber,
                        estimatedValue,
                        currency,
                        status,
                        rejectionReason,
                        approvedBy,
                        approvedAt,
                        reviewedBy,
                        reviewedAt,
                        reviewNotes,
                        createdAt,
                        updatedAt
                    FROM assets
                    WHERE id = ?
                    LIMIT 1
                `,
                [id],
            );

        const updatedAsset =
            updatedRows[0];

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: adminId,
            action: `asset.status_${newStatus}`,
            module: "assets",
            entityType: "asset",
            entityId: id,
            oldValues: asset,
            newValues: updatedAsset,
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            asset: updatedAsset,
            previousStatus,
            newStatus,
            reason: normalizedReason,
        };
    } catch (error) {
        try {
            await connection.rollback();
        } catch (rollbackError) {
            console.error(
                "Admin asset status rollback failed:",
                rollbackError,
            );
        }

        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// GET ASSET REVIEW HISTORY
// =========================================================

export async function getAssetReviewHistory(
    assetId,
) {
    const id = toPositiveInt(assetId);

    if (!id) {
        throw createServiceError(
            "A valid asset ID is required.",
        );
    }

    const [rows] = await pool.execute(
        `
            SELECT
                ar.id,
                ar.assetId,
                ar.adminId,
                ar.decision,
                ar.comments,
                ar.createdAt,

                u.firstName AS adminFirstName,
                u.lastName AS adminLastName,
                u.email AS adminEmail

            FROM asset_reviews ar

            LEFT JOIN users u
                ON u.id = ar.adminId

            WHERE ar.assetId = ?

            ORDER BY ar.id DESC
        `,
        [id],
    );

    return rows;
}


// =========================================================
// GET ASSET STATUS HISTORY
// =========================================================

export async function getAssetStatusChangeHistory(
    assetId,
) {
    const id = toPositiveInt(assetId);

    if (!id) {
        throw createServiceError(
            "A valid asset ID is required.",
        );
    }

    const [rows] = await pool.execute(
        `
            SELECT
                ash.id,
                ash.assetId,
                ash.previousStatus,
                ash.newStatus,
                ash.changedBy,
                ash.changeReason,
                ash.createdAt,

                u.firstName AS changedByFirstName,
                u.lastName AS changedByLastName,
                u.email AS changedByEmail

            FROM asset_status_history ash

            LEFT JOIN users u
                ON u.id = ash.changedBy

            WHERE ash.assetId = ?

            ORDER BY ash.id DESC
        `,
        [id],
    );

    return rows;
}