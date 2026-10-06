import crypto from "crypto";
import pool from "../../config/database.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

// =========================================================
// CONSTANTS
// =========================================================

const PROPOSAL_STATUSES = [
    "draft",
    "pending_review",
    "changes_required",
    "pending_approval",
    "approved",
    "rejected",
    "cancelled",
    "activated",
];

const REVIEWABLE_STATUSES = [
    "pending_review",
    "changes_required",
];

const OFFERING_STATUSES = [
    "draft",
    "scheduled",
    "active",
    "paused",
    "completed",
    "cancelled",
    "suspended",
];

// =========================================================
// HELPERS
// =========================================================

function normalizeId(value, fieldName = "id") {
    const parsed = Number(value);

    if (!Number.isInteger(parsed) || parsed <= 0) {
        const error = new Error(`Invalid ${fieldName}.`);
        error.statusCode = 400;
        error.code = "INVALID_ID";
        throw error;
    }

    return parsed;
}

function normalizeOptionalId(value, fieldName) {
    if (value === undefined || value === null || value === "") {
        return null;
    }

    return normalizeId(value, fieldName);
}

function generateReference(prefix) {
    const timestamp = Date.now();
    const random = crypto.randomBytes(5).toString("hex").toUpperCase();

    return `${prefix}-${timestamp}-${random}`;
}

function requireText(value, fieldName) {
    if (typeof value !== "string" || !value.trim()) {
        const error = new Error(`${fieldName} is required.`);
        error.statusCode = 400;
        error.code = "VALIDATION_ERROR";
        throw error;
    }

    return value.trim();
}

function normalizeNullableText(value) {
    if (value === undefined || value === null || value === "") {
        return null;
    }

    return String(value).trim();
}

function normalizePositiveNumber(value, fieldName) {
    const number = Number(value);

    if (!Number.isFinite(number) || number <= 0) {
        const error = new Error(`${fieldName} must be greater than zero.`);
        error.statusCode = 400;
        error.code = "VALIDATION_ERROR";
        throw error;
    }

    return number;
}

function normalizeOptionalPositiveNumber(value, fieldName) {
    if (value === undefined || value === null || value === "") {
        return null;
    }

    return normalizePositiveNumber(value, fieldName);
}

function normalizeDate(value, fieldName) {
    if (!value) {
        return null;
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
        const error = new Error(`${fieldName} is invalid.`);
        error.statusCode = 400;
        error.code = "VALIDATION_ERROR";
        throw error;
    }

    return date;
}

function serializeJson(value) {
    if (value === undefined || value === null) {
        return null;
    }

    return JSON.stringify(value);
}

function parseJson(value) {
    if (value === null || value === undefined) {
        return null;
    }

    if (typeof value === "object") {
        return value;
    }

    try {
        return JSON.parse(value);
    } catch {
        return value;
    }
}

// =========================================================
// PROPOSAL QUERIES
// =========================================================

async function getProposalForUpdate(connection, proposalId) {
    const [rows] = await connection.execute(
        `
      SELECT
        tp.*,
        a.id AS assetId,
        a.name AS assetName,
        a.status AS assetStatus,
        a.ownerId AS assetOwnerId,
        av.id AS valuationId,
        av.valuationAmount,
        av.currency AS valuationCurrency,
        av.status AS valuationStatus
      FROM tokenization_proposals tp
      INNER JOIN assets a
        ON a.id = tp.assetId
      LEFT JOIN asset_valuations av
        ON av.id = tp.valuationId
      WHERE tp.id = ?
      LIMIT 1
      FOR UPDATE
    `,
        [proposalId],
    );

    return rows[0] ?? null;
}

async function getProposal(proposalId) {
    const [rows] = await pool.execute(
        `
      SELECT
        tp.*,

        a.name AS assetName,
        a.status AS assetStatus,
        a.ownerId AS assetOwnerId,

        av.valuationAmount,
        av.currency AS valuationCurrency,
        av.valuationMethod,
        av.status AS valuationStatus,

        CONCAT(
          creator.firstName,
          ' ',
          creator.lastName
        ) AS createdByName,

        CONCAT(
          approver.firstName,
          ' ',
          approver.lastName
        ) AS approvedByName

      FROM tokenization_proposals tp

      INNER JOIN assets a
        ON a.id = tp.assetId

      LEFT JOIN asset_valuations av
        ON av.id = tp.valuationId

      LEFT JOIN admin_staff creator
        ON creator.id = tp.createdBy

      LEFT JOIN admin_staff approver
        ON approver.id = tp.approvedBy

      WHERE tp.id = ?

      LIMIT 1
    `,
        [proposalId],
    );

    if (!rows[0]) {
        return null;
    }

    const proposal = {
        ...rows[0],
        economicRights: parseJson(rows[0].economicRights),
        distributionPolicy: parseJson(rows[0].distributionPolicy),
    };

    const [history] = await pool.execute(
        `
      SELECT
        h.*,
        CONCAT(
          s.firstName,
          ' ',
          s.lastName
        ) AS changedByName
      FROM tokenization_proposal_status_history h
      LEFT JOIN admin_staff s
        ON s.id = h.changedBy
      WHERE h.proposalId = ?
      ORDER BY h.id ASC
    `,
        [proposalId],
    );

    const [reviews] = await pool.execute(
        `
      SELECT
        r.*,
        CONCAT(
          s.firstName,
          ' ',
          s.lastName
        ) AS reviewerName
      FROM tokenization_reviews r
      INNER JOIN admin_staff s
        ON s.id = r.reviewerId
      WHERE r.proposalId = ?
      ORDER BY r.id ASC
    `,
        [proposalId],
    );

    const [approvalRows] = await pool.execute(
        `
      SELECT
        *
      FROM admin_action_approvals
      WHERE module = 'tokenization'
        AND entityType = 'tokenization_proposal'
        AND entityId = ?
      ORDER BY id DESC
    `,
        [proposalId],
    );

    const [assignments] = await pool.execute(
        `
      SELECT
        aa.*,
        CONCAT(
          assigned.firstName,
          ' ',
          assigned.lastName
        ) AS assignedToName,
        CONCAT(
          assigner.firstName,
          ' ',
          assigner.lastName
        ) AS assignedByName
      FROM admin_assignments aa
      LEFT JOIN admin_staff assigned
        ON assigned.id = aa.assignedTo
      LEFT JOIN admin_staff assigner
        ON assigner.id = aa.assignedBy
      WHERE aa.module = 'tokenization'
        AND aa.entityType = 'tokenization_proposal'
        AND aa.entityId = ?
      ORDER BY aa.id DESC
    `,
        [proposalId],
    );

    return {
        ...proposal,
        history,
        reviews,
        approvals: approvalRows,
        assignments,
    };
}

// =========================================================
// LIST PROPOSALS
// =========================================================

export async function listTokenizationProposals({
    status = null,
    search = null,
    page = 1,
    limit = 20,
} = {}) {
    const safePage = Math.max(Number(page) || 1, 1);
    const safeLimit = Math.min(
        Math.max(Number(limit) || 20, 1),
        100,
    );

    const offset = (safePage - 1) * safeLimit;

    const conditions = [];
    const params = [];

    if (status) {
        if (!PROPOSAL_STATUSES.includes(status)) {
            const error = new Error("Invalid tokenization proposal status.");
            error.statusCode = 400;
            error.code = "INVALID_STATUS";
            throw error;
        }

        conditions.push("tp.status = ?");
        params.push(status);
    }

    if (search) {
        conditions.push(`
      (
        tp.proposalReference LIKE ?
        OR tp.proposedTokenName LIKE ?
        OR tp.proposedTokenCode LIKE ?
        OR a.name LIKE ?
      )
    `);

        const searchValue = `%${search}%`;

        params.push(
            searchValue,
            searchValue,
            searchValue,
            searchValue,
        );
    }

    const whereClause = conditions.length
        ? `WHERE ${conditions.join(" AND ")}`
        : "";

    const [countRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM tokenization_proposals tp
      INNER JOIN assets a
        ON a.id = tp.assetId
      ${whereClause}
    `,
        params,
    );

    const total = Number(countRows[0]?.total ?? 0);

    const [rows] = await pool.execute(
        `
      SELECT
        tp.id,
        tp.proposalReference,
        tp.assetId,
        tp.valuationId,
        tp.createdBy,
        tp.status,
        tp.proposedTokenName,
        tp.proposedTokenCode,
        tp.totalSupply,
        tp.offeringSupply,
        tp.initialTokenPrice,
        tp.currency,
        tp.minimumPurchaseQuantity,
        tp.maximumPurchaseQuantity,
        tp.offeringStartAt,
        tp.offeringEndAt,
        tp.valuationAmountSnapshot,
        tp.valuationCurrencySnapshot,
        tp.submittedAt,
        tp.approvedAt,
        tp.activatedAt,
        tp.createdAt,
        tp.updatedAt,

        a.name AS assetName,
        a.status AS assetStatus,

        CONCAT(
          s.firstName,
          ' ',
          s.lastName
        ) AS createdByName

      FROM tokenization_proposals tp

      INNER JOIN assets a
        ON a.id = tp.assetId

      LEFT JOIN admin_staff s
        ON s.id = tp.createdBy

      ${whereClause}

      ORDER BY tp.createdAt DESC

      LIMIT ${safeLimit}
      OFFSET ${offset}
    `,
        params,
    );

    return {
        items: rows,
        pagination: {
            page: safePage,
            limit: safeLimit,
            total,
            totalPages: Math.ceil(total / safeLimit),
        },
    };
}

// =========================================================
// ELIGIBLE ASSETS
// =========================================================

export async function getEligibleTokenizationAssets({
    search = null,
    page = 1,
    limit = 20,
} = {}) {
    const safePage = Math.max(Number(page) || 1, 1);
    const safeLimit = Math.min(
        Math.max(Number(limit) || 20, 1),
        100,
    );

    const offset = (safePage - 1) * safeLimit;

    const conditions = [
        "a.status = 'approved'",
        `
      NOT EXISTS (
        SELECT 1
        FROM tokenization_proposals tp
        WHERE tp.assetId = a.id
          AND tp.status IN (
            'pending_review',
            'changes_required',
            'pending_approval',
            'approved',
            'activated'
          )
      )
    `,
        `
      NOT EXISTS (
        SELECT 1
        FROM tokens t
        WHERE t.assetId = a.id
          AND t.status NOT IN ('burned', 'suspended')
      )
    `,
    ];

    const params = [];

    if (search) {
        conditions.push(`
      (
        a.name LIKE ?
        OR CAST(a.id AS CHAR) LIKE ?
      )
    `);

        const searchValue = `%${search}%`;

        params.push(searchValue, searchValue);
    }

    const whereClause = `WHERE ${conditions.join(" AND ")}`;

    const [countRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM assets a
      ${whereClause}
    `,
        params,
    );

    const total = Number(countRows[0]?.total ?? 0);

    const [rows] = await pool.execute(
        `
      SELECT
        a.id,
        a.name,
        a.status,
        a.ownerId,
        a.assetType,
        a.description,
        a.createdAt,

        av.id AS valuationId,
        av.valuationAmount,
        av.currency AS valuationCurrency,
        av.valuationMethod,
        av.status AS valuationStatus,
        av.valuedAt

      FROM assets a

      LEFT JOIN asset_valuations av
        ON av.id = (
          SELECT av2.id
          FROM asset_valuations av2
          WHERE av2.assetId = a.id
            AND av2.status = 'verified'
          ORDER BY av2.valuedAt DESC, av2.id DESC
          LIMIT 1
        )

      ${whereClause}

      ORDER BY a.createdAt DESC

      LIMIT ${safeLimit}
      OFFSET ${offset}
    `,
        params,
    );

    return {
        items: rows,
        pagination: {
            page: safePage,
            limit: safeLimit,
            total,
            totalPages: Math.ceil(total / safeLimit),
        },
    };
}

// =========================================================
// CREATE PROPOSAL
// =========================================================

export async function createTokenizationProposal({
    adminId,
    assetId,
    valuationId = null,
    proposedTokenName,
    proposedTokenCode,
    totalSupply,
    offeringSupply,
    initialTokenPrice,
    currency = "KES",
    minimumPurchaseQuantity = null,
    maximumPurchaseQuantity = null,
    offeringStartAt = null,
    offeringEndAt = null,
    economicRights = null,
    distributionPolicy = null,
    termsAndConditions = null,
    description = null,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedAssetId = normalizeId(assetId, "assetId");

    const tokenName = requireText(
        proposedTokenName,
        "proposedTokenName",
    );

    const tokenCode = requireText(
        proposedTokenCode,
        "proposedTokenCode",
    ).toUpperCase();

    const supply = normalizePositiveNumber(
        totalSupply,
        "totalSupply",
    );

    const offerSupply = normalizePositiveNumber(
        offeringSupply,
        "offeringSupply",
    );

    const price = normalizePositiveNumber(
        initialTokenPrice,
        "initialTokenPrice",
    );

    if (offerSupply > supply) {
        const error = new Error(
            "offeringSupply cannot be greater than totalSupply.",
        );
        error.statusCode = 400;
        error.code = "INVALID_SUPPLY";
        throw error;
    }

    const minimum = normalizeOptionalPositiveNumber(
        minimumPurchaseQuantity,
        "minimumPurchaseQuantity",
    );

    const maximum = normalizeOptionalPositiveNumber(
        maximumPurchaseQuantity,
        "maximumPurchaseQuantity",
    );

    if (
        minimum !== null &&
        maximum !== null &&
        minimum > maximum
    ) {
        const error = new Error(
            "minimumPurchaseQuantity cannot be greater than maximumPurchaseQuantity.",
        );
        error.statusCode = 400;
        error.code = "INVALID_PURCHASE_LIMIT";
        throw error;
    }

    const startAt = normalizeDate(
        offeringStartAt,
        "offeringStartAt",
    );

    const endAt = normalizeDate(
        offeringEndAt,
        "offeringEndAt",
    );

    if (startAt && endAt && endAt <= startAt) {
        const error = new Error(
            "offeringEndAt must be later than offeringStartAt.",
        );
        error.statusCode = 400;
        error.code = "INVALID_OFFERING_DATES";
        throw error;
    }

    const normalizedValuationId = normalizeOptionalId(
        valuationId,
        "valuationId",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [assetRows] = await connection.execute(
            `
        SELECT
          id,
          name,
          status
        FROM assets
        WHERE id = ?
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedAssetId],
        );

        const asset = assetRows[0];

        if (!asset) {
            const error = new Error("Asset not found.");
            error.statusCode = 404;
            error.code = "ASSET_NOT_FOUND";
            throw error;
        }

        if (asset.status !== "approved") {
            const error = new Error(
                "Only approved assets can be tokenized.",
            );
            error.statusCode = 400;
            error.code = "ASSET_NOT_ELIGIBLE";
            throw error;
        }

        const [existingTokenRows] = await connection.execute(
            `
        SELECT id
        FROM tokens
        WHERE assetId = ?
          AND status NOT IN ('burned', 'suspended')
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedAssetId],
        );

        if (existingTokenRows.length > 0) {
            const error = new Error(
                "This asset already has an active token record.",
            );
            error.statusCode = 409;
            error.code = "ASSET_ALREADY_TOKENIZED";
            throw error;
        }

        const [existingProposalRows] = await connection.execute(
            `
        SELECT id, status
        FROM tokenization_proposals
        WHERE assetId = ?
          AND status IN (
            'pending_review',
            'changes_required',
            'pending_approval',
            'approved',
            'activated'
          )
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedAssetId],
        );

        if (existingProposalRows.length > 0) {
            const error = new Error(
                "This asset already has an active tokenization proposal.",
            );
            error.statusCode = 409;
            error.code = "ACTIVE_PROPOSAL_EXISTS";
            throw error;
        }

        let valuation = null;

        if (normalizedValuationId) {
            const [valuationRows] = await connection.execute(
                `
          SELECT
            id,
            assetId,
            valuationAmount,
            currency,
            status
          FROM asset_valuations
          WHERE id = ?
          LIMIT 1
          FOR UPDATE
        `,
                [normalizedValuationId],
            );

            valuation = valuationRows[0];

            if (!valuation) {
                const error = new Error("Valuation not found.");
                error.statusCode = 404;
                error.code = "VALUATION_NOT_FOUND";
                throw error;
            }

            if (Number(valuation.assetId) !== normalizedAssetId) {
                const error = new Error(
                    "The selected valuation does not belong to this asset.",
                );
                error.statusCode = 400;
                error.code = "VALUATION_ASSET_MISMATCH";
                throw error;
            }

            if (valuation.status !== "verified") {
                const error = new Error(
                    "Only verified valuations can be used for tokenization.",
                );
                error.statusCode = 400;
                error.code = "VALUATION_NOT_VERIFIED";
                throw error;
            }
        }

        const proposalReference =
            generateReference("TCP");

        const valuationSnapshot =
            valuation?.valuationAmount ?? null;

        const valuationCurrencySnapshot =
            valuation?.currency ?? null;

        const [result] = await connection.execute(
            `
        INSERT INTO tokenization_proposals (
          proposalReference,
          assetId,
          valuationId,
          createdBy,
          status,
          proposedTokenName,
          proposedTokenCode,
          totalSupply,
          offeringSupply,
          initialTokenPrice,
          currency,
          minimumPurchaseQuantity,
          maximumPurchaseQuantity,
          offeringStartAt,
          offeringEndAt,
          valuationAmountSnapshot,
          valuationCurrencySnapshot,
          economicRights,
          distributionPolicy,
          termsAndConditions,
          description
        )
        VALUES (
          ?, ?, ?, ?, 'draft', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
          ?, ?, ?, ?, ?, ?
        )
      `,
            [
                proposalReference,
                normalizedAssetId,
                normalizedValuationId,
                staffId,
                tokenName,
                tokenCode,
                supply,
                offerSupply,
                price,
                currency,
                minimum,
                maximum,
                startAt,
                endAt,
                valuationSnapshot,
                valuationCurrencySnapshot,
                serializeJson(economicRights),
                serializeJson(distributionPolicy),
                normalizeNullableText(termsAndConditions),
                normalizeNullableText(description),
            ],
        );

        const proposalId = result.insertId;

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, NULL, 'draft', ?, ?)
      `,
            [
                proposalId,
                staffId,
                "Tokenization proposal created.",
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: "TOKENIZATION_PROPOSAL_CREATED",
            module: "tokenization",
            entityType: "tokenization_proposal",
            entityId: proposalId,
            oldValues: null,
            newValues: {
                proposalReference,
                assetId: normalizedAssetId,
                valuationId: normalizedValuationId,
                proposedTokenName: tokenName,
                proposedTokenCode: tokenCode,
                totalSupply: supply,
                offeringSupply: offerSupply,
                initialTokenPrice: price,
                currency,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getProposal(proposalId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// SUBMIT PROPOSAL
// =========================================================

export async function submitTokenizationProposal({
    adminId,
    proposalId,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedProposalId = normalizeId(
        proposalId,
        "proposalId",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const proposal = await getProposalForUpdate(
            connection,
            normalizedProposalId,
        );

        if (!proposal) {
            const error = new Error(
                "Tokenization proposal not found.",
            );
            error.statusCode = 404;
            error.code = "PROPOSAL_NOT_FOUND";
            throw error;
        }

        if (
            !["draft", "changes_required"].includes(
                proposal.status,
            )
        ) {
            const error = new Error(
                `Proposal cannot be submitted from status '${proposal.status}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_PROPOSAL_STATUS";
            throw error;
        }

        if (proposal.createdBy !== staffId) {
            // An administrator can submit a proposal only when it
            // was created by the same administrator. This keeps the
            // maker/checker trail explicit.
            const error = new Error(
                "Only the proposal creator can submit this proposal.",
            );
            error.statusCode = 403;
            error.code = "PROPOSAL_CREATOR_REQUIRED";
            throw error;
        }

        if (proposal.assetStatus !== "approved") {
            const error = new Error(
                "The asset must remain approved before submission.",
            );
            error.statusCode = 400;
            error.code = "ASSET_NOT_APPROVED";
            throw error;
        }

        if (!proposal.totalSupply || !proposal.offeringSupply) {
            const error = new Error(
                "Token supply configuration is incomplete.",
            );
            error.statusCode = 400;
            error.code = "INCOMPLETE_TOKEN_CONFIGURATION";
            throw error;
        }

        if (!proposal.initialTokenPrice) {
            const error = new Error(
                "Initial token price is required.",
            );
            error.statusCode = 400;
            error.code = "TOKEN_PRICE_REQUIRED";
            throw error;
        }

        const previousStatus = proposal.status;

        await connection.execute(
            `
        UPDATE tokenization_proposals
        SET
          status = 'pending_review',
          submittedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [normalizedProposalId],
        );

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, ?, 'pending_review', ?, ?)
      `,
            [
                normalizedProposalId,
                previousStatus,
                staffId,
                "Tokenization proposal submitted for review.",
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: "TOKENIZATION_PROPOSAL_SUBMITTED",
            module: "tokenization",
            entityType: "tokenization_proposal",
            entityId: normalizedProposalId,
            oldValues: {
                status: previousStatus,
            },
            newValues: {
                status: "pending_review",
                submittedAt: new Date().toISOString(),
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getProposal(normalizedProposalId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// REVIEW PROPOSAL
// =========================================================

export async function reviewTokenizationProposal({
    adminId,
    proposalId,
    decision,
    comments = null,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedProposalId = normalizeId(
        proposalId,
        "proposalId",
    );

    const normalizedDecision = requireText(
        decision,
        "decision",
    );

    const allowedDecisions = [
        "under_review",
        "changes_required",
        "approved",
        "rejected",
    ];

    if (!allowedDecisions.includes(normalizedDecision)) {
        const error = new Error(
            "Invalid tokenization review decision.",
        );
        error.statusCode = 400;
        error.code = "INVALID_REVIEW_DECISION";
        throw error;
    }

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const proposal = await getProposalForUpdate(
            connection,
            normalizedProposalId,
        );

        if (!proposal) {
            const error = new Error(
                "Tokenization proposal not found.",
            );
            error.statusCode = 404;
            error.code = "PROPOSAL_NOT_FOUND";
            throw error;
        }

        if (!REVIEWABLE_STATUSES.includes(proposal.status)) {
            const error = new Error(
                `Proposal cannot be reviewed from status '${proposal.status}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_PROPOSAL_STATUS";
            throw error;
        }

        if (proposal.createdBy === staffId) {
            const error = new Error(
                "The proposal creator cannot review their own proposal.",
            );
            error.statusCode = 403;
            error.code = "MAKER_CHECKER_VIOLATION";
            throw error;
        }

        const commentsText =
            normalizeNullableText(comments);

        let nextStatus = proposal.status;

        if (normalizedDecision === "under_review") {
            nextStatus = "pending_review";
        }

        if (normalizedDecision === "changes_required") {
            nextStatus = "changes_required";
        }

        if (normalizedDecision === "approved") {
            nextStatus = "pending_approval";
        }

        if (normalizedDecision === "rejected") {
            nextStatus = "rejected";
        }

        if (
            ["changes_required", "rejected"].includes(
                normalizedDecision,
            ) &&
            !commentsText
        ) {
            const error = new Error(
                "Comments are required for this review decision.",
            );
            error.statusCode = 400;
            error.code = "REVIEW_COMMENTS_REQUIRED";
            throw error;
        }

        await connection.execute(
            `
        INSERT INTO tokenization_reviews (
          proposalId,
          reviewerId,
          reviewType,
          decision,
          comments
        )
        VALUES (?, ?, ?, ?, ?)
      `,
            [
                normalizedProposalId,
                staffId,
                normalizedDecision === "changes_required"
                    ? "change_request"
                    : normalizedDecision === "approved"
                        ? "approval"
                        : normalizedDecision === "rejected"
                            ? "rejection"
                            : "review",
                normalizedDecision,
                commentsText,
            ],
        );

        await connection.execute(
            `
        UPDATE tokenization_proposals
        SET
          status = ?,
          reviewNotes = ?,
          rejectionReason = ?,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                nextStatus,
                commentsText,
                normalizedDecision === "rejected"
                    ? commentsText
                    : null,
                normalizedProposalId,
            ],
        );

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, ?, ?, ?, ?)
      `,
            [
                normalizedProposalId,
                proposal.status,
                nextStatus,
                staffId,
                commentsText ||
                `Tokenization proposal reviewed with decision '${normalizedDecision}'.`,
            ],
        );

        // =====================================================
        // CREATE MAKER-CHECKER APPROVAL REQUEST
        // =====================================================

        if (normalizedDecision === "approved") {
            const actionReference =
                generateReference("TCA");

            const [existingApprovalRows] =
                await connection.execute(
                    `
            SELECT id
            FROM admin_action_approvals
            WHERE module = 'tokenization'
              AND actionType = 'TOKENIZATION_APPROVAL'
              AND entityType = 'tokenization_proposal'
              AND entityId = ?
              AND status = 'pending'
            LIMIT 1
            FOR UPDATE
          `,
                    [normalizedProposalId],
                );

            if (existingApprovalRows.length === 0) {
                await connection.execute(
                    `
            INSERT INTO admin_action_approvals (
              actionReference,
              module,
              actionType,
              entityType,
              entityId,
              requestedBy,
              status,
              requestData
            )
            VALUES (
              ?,
              'tokenization',
              'TOKENIZATION_APPROVAL',
              'tokenization_proposal',
              ?,
              ?,
              'pending',
              ?
            )
          `,
                    [
                        actionReference,
                        normalizedProposalId,
                        staffId,
                        JSON.stringify({
                            proposalId: normalizedProposalId,
                            proposalReference:
                                proposal.proposalReference,
                            assetId: proposal.assetId,
                            totalSupply: proposal.totalSupply,
                            offeringSupply:
                                proposal.offeringSupply,
                            initialTokenPrice:
                                proposal.initialTokenPrice,
                            currency: proposal.currency,
                        }),
                    ],
                );
            }
        }

        await writeAdminAuditLog({
            connection,
            staffId,
            action:
                normalizedDecision === "approved"
                    ? "TOKENIZATION_REVIEW_APPROVED"
                    : normalizedDecision === "rejected"
                        ? "TOKENIZATION_REVIEW_REJECTED"
                        : normalizedDecision === "changes_required"
                            ? "TOKENIZATION_CHANGES_REQUESTED"
                            : "TOKENIZATION_REVIEW_STARTED",
            module: "tokenization",
            entityType: "tokenization_proposal",
            entityId: normalizedProposalId,
            oldValues: {
                status: proposal.status,
            },
            newValues: {
                status: nextStatus,
                decision: normalizedDecision,
                comments: commentsText,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getProposal(normalizedProposalId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// APPROVE PROPOSAL
// =========================================================

export async function approveTokenizationProposal({
    adminId,
    proposalId,
    comments = null,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedProposalId = normalizeId(
        proposalId,
        "proposalId",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const proposal = await getProposalForUpdate(
            connection,
            normalizedProposalId,
        );

        if (!proposal) {
            const error = new Error(
                "Tokenization proposal not found.",
            );
            error.statusCode = 404;
            error.code = "PROPOSAL_NOT_FOUND";
            throw error;
        }

        if (proposal.status !== "pending_approval") {
            const error = new Error(
                `Proposal cannot be approved from status '${proposal.status}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_PROPOSAL_STATUS";
            throw error;
        }

        if (proposal.createdBy === staffId) {
            const error = new Error(
                "The proposal creator cannot approve their own proposal.",
            );
            error.statusCode = 403;
            error.code = "MAKER_CHECKER_VIOLATION";
            throw error;
        }

        const [approvalRows] = await connection.execute(
            `
        SELECT *
        FROM admin_action_approvals
        WHERE module = 'tokenization'
          AND actionType = 'TOKENIZATION_APPROVAL'
          AND entityType = 'tokenization_proposal'
          AND entityId = ?
          AND status = 'pending'
        ORDER BY id DESC
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedProposalId],
        );

        const approval = approvalRows[0];

        if (!approval) {
            const error = new Error(
                "No pending approval request exists for this proposal.",
            );
            error.statusCode = 400;
            error.code = "APPROVAL_REQUEST_NOT_FOUND";
            throw error;
        }

        if (Number(approval.requestedBy) === staffId) {
            const error = new Error(
                "The administrator who requested approval cannot approve the same action.",
            );
            error.statusCode = 403;
            error.code = "MAKER_CHECKER_VIOLATION";
            throw error;
        }

        if (proposal.assetStatus !== "approved") {
            const error = new Error(
                "The asset is no longer approved for tokenization.",
            );
            error.statusCode = 400;
            error.code = "ASSET_NOT_APPROVED";
            throw error;
        }

        // =====================================================
        // RECHECK TOKEN UNIQUENESS
        // =====================================================

        const [existingTokenRows] = await connection.execute(
            `
        SELECT id, tokenCode, status
        FROM tokens
        WHERE assetId = ?
          AND status NOT IN ('burned', 'suspended')
        LIMIT 1
        FOR UPDATE
      `,
            [proposal.assetId],
        );

        if (existingTokenRows.length > 0) {
            const error = new Error(
                "This asset already has a token record.",
            );
            error.statusCode = 409;
            error.code = "TOKEN_ALREADY_EXISTS";
            throw error;
        }

        const tokenCode = proposal.proposedTokenCode;

        const [duplicateCodeRows] = await connection.execute(
            `
        SELECT id
        FROM tokens
        WHERE tokenCode = ?
        LIMIT 1
        FOR UPDATE
      `,
            [tokenCode],
        );

        if (duplicateCodeRows.length > 0) {
            const error = new Error(
                `Token code '${tokenCode}' already exists.`,
            );
            error.statusCode = 409;
            error.code = "TOKEN_CODE_EXISTS";
            throw error;
        }

        // =====================================================
        // CREATE ACTUAL TOKEN
        // =====================================================

        const [tokenResult] = await connection.execute(
            `
        INSERT INTO tokens (
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
          mintedAt
        )
        VALUES (
          ?, ?, ?, ?, ?, ?, ?, ?, 8, 'pending', CURRENT_TIMESTAMP
        )
      `,
            [
                proposal.assetId,
                tokenCode,
                proposal.proposedTokenName,
                proposal.description,
                proposal.totalSupply,
                proposal.totalSupply,
                proposal.initialTokenPrice,
                proposal.currency,
            ],
        );

        const tokenId = tokenResult.insertId;

        // =====================================================
        // CREATE CUSTOMER-FACING OFFERING
        // =====================================================

        const offeringReference =
            generateReference("TCO");

        await connection.execute(
            `
        INSERT INTO token_offerings (
          offeringReference,
          proposalId,
          tokenId,
          createdBy,
          status,
          offeringSupply,
          pricePerToken,
          currency,
          minimumPurchaseQuantity,
          maximumPurchaseQuantity,
          offeringStartAt,
          offeringEndAt
        )
        VALUES (
          ?, ?, ?, ?, 'draft', ?, ?, ?, ?, ?, ?, ?
        )
      `,
            [
                offeringReference,
                normalizedProposalId,
                tokenId,
                staffId,
                proposal.offeringSupply,
                proposal.initialTokenPrice,
                proposal.currency,
                proposal.minimumPurchaseQuantity,
                proposal.maximumPurchaseQuantity,
                proposal.offeringStartAt,
                proposal.offeringEndAt,
            ],
        );

        // =====================================================
        // COMPLETE APPROVAL RECORD
        // =====================================================

        await connection.execute(
            `
        UPDATE admin_action_approvals
        SET
          status = 'approved',
          reviewedBy = ?,
          reviewComments = ?,
          reviewedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                staffId,
                normalizeNullableText(comments),
                approval.id,
            ],
        );

        // =====================================================
        // UPDATE PROPOSAL
        // =====================================================

        await connection.execute(
            `
        UPDATE tokenization_proposals
        SET
          status = 'approved',
          approvedBy = ?,
          approvedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                staffId,
                normalizedProposalId,
            ],
        );

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, 'pending_approval', 'approved', ?, ?)
      `,
            [
                normalizedProposalId,
                staffId,
                normalizeNullableText(comments) ||
                "Tokenization proposal approved and token created.",
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: "TOKENIZATION_APPROVED",
            module: "tokenization",
            entityType: "tokenization_proposal",
            entityId: normalizedProposalId,
            oldValues: {
                status: "pending_approval",
            },
            newValues: {
                status: "approved",
                tokenId,
                tokenCode,
                offeringReference,
                approvedBy: staffId,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getProposal(normalizedProposalId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// REJECT PROPOSAL
// =========================================================

export async function rejectTokenizationProposal({
    adminId,
    proposalId,
    reason,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedProposalId = normalizeId(
        proposalId,
        "proposalId",
    );

    const rejectionReason = requireText(
        reason,
        "reason",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const proposal = await getProposalForUpdate(
            connection,
            normalizedProposalId,
        );

        if (!proposal) {
            const error = new Error(
                "Tokenization proposal not found.",
            );
            error.statusCode = 404;
            error.code = "PROPOSAL_NOT_FOUND";
            throw error;
        }

        if (
            ![
                "pending_review",
                "changes_required",
                "pending_approval",
            ].includes(proposal.status)
        ) {
            const error = new Error(
                `Proposal cannot be rejected from status '${proposal.status}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_PROPOSAL_STATUS";
            throw error;
        }

        if (proposal.createdBy === staffId) {
            const error = new Error(
                "The proposal creator cannot reject their own proposal.",
            );
            error.statusCode = 403;
            error.code = "MAKER_CHECKER_VIOLATION";
            throw error;
        }

        await connection.execute(
            `
        INSERT INTO tokenization_reviews (
          proposalId,
          reviewerId,
          reviewType,
          decision,
          comments
        )
        VALUES (?, ?, 'rejection', 'rejected', ?)
      `,
            [
                normalizedProposalId,
                staffId,
                rejectionReason,
            ],
        );

        await connection.execute(
            `
        UPDATE tokenization_proposals
        SET
          status = 'rejected',
          rejectionReason = ?,
          reviewNotes = ?,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                rejectionReason,
                rejectionReason,
                normalizedProposalId,
            ],
        );

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, ?, 'rejected', ?, ?)
      `,
            [
                normalizedProposalId,
                proposal.status,
                staffId,
                rejectionReason,
            ],
        );

        // Cancel any pending maker-checker approval.
        await connection.execute(
            `
        UPDATE admin_action_approvals
        SET
          status = 'cancelled',
          reviewedBy = ?,
          reviewComments = ?,
          reviewedAt = CURRENT_TIMESTAMP
        WHERE module = 'tokenization'
          AND entityType = 'tokenization_proposal'
          AND entityId = ?
          AND status = 'pending'
      `,
            [
                staffId,
                rejectionReason,
                normalizedProposalId,
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: "TOKENIZATION_REJECTED",
            module: "tokenization",
            entityType: "tokenization_proposal",
            entityId: normalizedProposalId,
            oldValues: {
                status: proposal.status,
            },
            newValues: {
                status: "rejected",
                rejectionReason,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getProposal(normalizedProposalId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// OFFERINGS
// =========================================================

export async function listTokenOfferings({
    status = null,
    search = null,
    page = 1,
    limit = 20,
} = {}) {
    const safePage = Math.max(Number(page) || 1, 1);
    const safeLimit = Math.min(
        Math.max(Number(limit) || 20, 1),
        100,
    );

    const offset = (safePage - 1) * safeLimit;

    const conditions = [];
    const params = [];

    if (status) {
        if (!OFFERING_STATUSES.includes(status)) {
            const error = new Error(
                "Invalid token offering status.",
            );
            error.statusCode = 400;
            error.code = "INVALID_STATUS";
            throw error;
        }

        conditions.push("toff.status = ?");
        params.push(status);
    }

    if (search) {
        conditions.push(`
      (
        toff.offeringReference LIKE ?
        OR t.tokenCode LIKE ?
        OR t.tokenName LIKE ?
      )
    `);

        const searchValue = `%${search}%`;

        params.push(
            searchValue,
            searchValue,
            searchValue,
        );
    }

    const whereClause = conditions.length
        ? `WHERE ${conditions.join(" AND ")}`
        : "";

    const [countRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM token_offerings toff
      INNER JOIN tokens t
        ON t.id = toff.tokenId
      ${whereClause}
    `,
        params,
    );

    const total = Number(countRows[0]?.total ?? 0);

    const [rows] = await pool.execute(
        `
      SELECT
        toff.*,

        t.tokenCode,
        t.tokenName,
        t.status AS tokenStatus,
        t.assetId,

        a.name AS assetName

      FROM token_offerings toff

      INNER JOIN tokens t
        ON t.id = toff.tokenId

      INNER JOIN assets a
        ON a.id = t.assetId

      ${whereClause}

      ORDER BY toff.createdAt DESC

      LIMIT ${safeLimit}
      OFFSET ${offset}
    `,
        params,
    );

    return {
        items: rows,
        pagination: {
            page: safePage,
            limit: safeLimit,
            total,
            totalPages: Math.ceil(total / safeLimit),
        },
    };
}

export async function getTokenOffering(offeringId) {
    const normalizedOfferingId = normalizeId(
        offeringId,
        "offeringId",
    );

    const [rows] = await pool.execute(
        `
      SELECT
        toff.*,

        t.tokenCode,
        t.tokenName,
        t.description AS tokenDescription,
        t.totalSupply AS tokenTotalSupply,
        t.availableSupply AS tokenAvailableSupply,
        t.tokenPrice,
        t.currency AS tokenCurrency,
        t.status AS tokenStatus,
        t.decimals,

        a.id AS assetId,
        a.name AS assetName,
        a.status AS assetStatus

      FROM token_offerings toff

      INNER JOIN tokens t
        ON t.id = toff.tokenId

      INNER JOIN assets a
        ON a.id = t.assetId

      WHERE toff.id = ?

      LIMIT 1
    `,
        [normalizedOfferingId],
    );

    return rows[0] ?? null;
}

// =========================================================
// ACTIVATE OFFERING
// =========================================================

export async function activateTokenOffering({
    adminId,
    offeringId,
    ipAddress = null,
    userAgent = null,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedOfferingId = normalizeId(
        offeringId,
        "offeringId",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [offeringRows] = await connection.execute(
            `
        SELECT
          toff.*,
          t.assetId,
          t.status AS tokenStatus,
          a.status AS assetStatus
        FROM token_offerings toff
        INNER JOIN tokens t
          ON t.id = toff.tokenId
        INNER JOIN assets a
          ON a.id = t.assetId
        WHERE toff.id = ?
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedOfferingId],
        );

        const offering = offeringRows[0];

        if (!offering) {
            const error = new Error(
                "Token offering not found.",
            );
            error.statusCode = 404;
            error.code = "OFFERING_NOT_FOUND";
            throw error;
        }

        if (!["draft", "scheduled"].includes(offering.status)) {
            const error = new Error(
                `Offering cannot be activated from status '${offering.status}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_OFFERING_STATUS";
            throw error;
        }

        if (
            !["pending", "active"].includes(
                offering.tokenStatus,
            )
        ) {
            const error = new Error(
                "The token is not in an activatable state.",
            );
            error.statusCode = 400;
            error.code = "TOKEN_NOT_ACTIVATABLE";
            throw error;
        }

        if (offering.assetStatus !== "approved") {
            const error = new Error(
                "The underlying asset is no longer approved.",
            );
            error.statusCode = 400;
            error.code = "ASSET_NOT_APPROVED";
            throw error;
        }

        if (
            offering.offeringStartAt &&
            new Date(offering.offeringStartAt) > new Date()
        ) {
            const error = new Error(
                "The offering start time has not been reached.",
            );
            error.statusCode = 400;
            error.code = "OFFERING_NOT_STARTED";
            throw error;
        }

        await connection.execute(
            `
        UPDATE tokens
        SET
          status = 'active',
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [offering.tokenId],
        );

        await connection.execute(
            `
        UPDATE token_offerings
        SET
          status = 'active',
          activatedBy = ?,
          activatedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                staffId,
                normalizedOfferingId,
            ],
        );

        await connection.execute(
            `
        UPDATE assets
        SET
          status = 'tokenized'
        WHERE id = ?
      `,
            [offering.assetId],
        );

        await connection.execute(
            `
        UPDATE tokenization_proposals
        SET
          status = 'activated',
          activatedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [offering.proposalId],
        );

        await connection.execute(
            `
        INSERT INTO token_offering_status_history (
          offeringId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, ?, 'active', ?, ?)
      `,
            [
                normalizedOfferingId,
                offering.status,
                staffId,
                "Token offering activated.",
            ],
        );

        await connection.execute(
            `
        INSERT INTO tokenization_proposal_status_history (
          proposalId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, 'approved', 'activated', ?, ?)
      `,
            [
                offering.proposalId,
                staffId,
                "Token offering activated.",
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: "TOKEN_OFFERING_ACTIVATED",
            module: "tokenization",
            entityType: "token_offering",
            entityId: normalizedOfferingId,
            oldValues: {
                status: offering.status,
                tokenStatus: offering.tokenStatus,
                assetStatus: offering.assetStatus,
            },
            newValues: {
                status: "active",
                tokenStatus: "active",
                assetStatus: "tokenized",
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenOffering(
            normalizedOfferingId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// PAUSE OFFERING
// =========================================================

export async function pauseTokenOffering({
    adminId,
    offeringId,
    reason,
    ipAddress = null,
    userAgent = null,
}) {
    return updateTokenOfferingStatus({
        adminId,
        offeringId,
        nextStatus: "paused",
        reason,
        auditAction: "TOKEN_OFFERING_PAUSED",
        ipAddress,
        userAgent,
    });
}

// =========================================================
// SUSPEND OFFERING
// =========================================================

export async function suspendTokenOffering({
    adminId,
    offeringId,
    reason,
    ipAddress = null,
    userAgent = null,
}) {
    return updateTokenOfferingStatus({
        adminId,
        offeringId,
        nextStatus: "suspended",
        reason,
        auditAction: "TOKEN_OFFERING_SUSPENDED",
        ipAddress,
        userAgent,
    });
}




// =========================================================
// OFFERING STATUS HELPER
// =========================================================

async function updateTokenOfferingStatus({
    adminId,
    offeringId,
    nextStatus,
    reason,
    auditAction,
    ipAddress,
    userAgent,
}) {
    const staffId = normalizeId(adminId, "adminId");
    const normalizedOfferingId = normalizeId(
        offeringId,
        "offeringId",
    );

    const statusReason = requireText(
        reason,
        "reason",
    );

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.execute(
            `
        SELECT
          toff.*,
          t.status AS tokenStatus
        FROM token_offerings toff
        INNER JOIN tokens t
          ON t.id = toff.tokenId
        WHERE toff.id = ?
        LIMIT 1
        FOR UPDATE
      `,
            [normalizedOfferingId],
        );

        const offering = rows[0];

        if (!offering) {
            const error = new Error(
                "Token offering not found.",
            );
            error.statusCode = 404;
            error.code = "OFFERING_NOT_FOUND";
            throw error;
        }

        const allowedTransitions = {
            paused: ["active"],
            suspended: [
                "active",
                "paused",
                "scheduled",
            ],
        };

        if (
            !allowedTransitions[nextStatus]?.includes(
                offering.status,
            )
        ) {
            const error = new Error(
                `Offering cannot transition from '${offering.status}' to '${nextStatus}'.`,
            );
            error.statusCode = 400;
            error.code = "INVALID_OFFERING_TRANSITION";
            throw error;
        }

        await connection.execute(
            `
        UPDATE token_offerings
        SET
          status = ?,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                nextStatus,
                normalizedOfferingId,
            ],
        );

        if (nextStatus === "suspended") {
            await connection.execute(
                `
          UPDATE tokens
          SET
            status = 'suspended',
            updatedAt = CURRENT_TIMESTAMP
          WHERE id = ?
        `,
                [offering.tokenId],
            );
        }

        if (nextStatus === "paused") {
            await connection.execute(
                `
          UPDATE tokens
          SET
            status = 'paused',
            updatedAt = CURRENT_TIMESTAMP
          WHERE id = ?
            AND status = 'active'
        `,
                [offering.tokenId],
            );
        }

        await connection.execute(
            `
        INSERT INTO token_offering_status_history (
          offeringId,
          previousStatus,
          newStatus,
          changedBy,
          reason
        )
        VALUES (?, ?, ?, ?, ?)
      `,
            [
                normalizedOfferingId,
                offering.status,
                nextStatus,
                staffId,
                statusReason,
            ],
        );

        await writeAdminAuditLog({
            connection,
            staffId,
            action: auditAction,
            module: "tokenization",
            entityType: "token_offering",
            entityId: normalizedOfferingId,
            oldValues: {
                status: offering.status,
                tokenStatus: offering.tokenStatus,
            },
            newValues: {
                status: nextStatus,
                reason: statusReason,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenOffering(
            normalizedOfferingId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// =========================================================
// TOKENIZATION OVERVIEW
// =========================================================

export async function getTokenizationOverview() {
    const [proposalStats] = await pool.execute(
        `
      SELECT
        COUNT(*) AS totalProposals,

        SUM(
          status = 'draft'
        ) AS drafts,

        SUM(
          status = 'pending_review'
        ) AS pendingReview,

        SUM(
          status = 'changes_required'
        ) AS changesRequired,

        SUM(
          status = 'pending_approval'
        ) AS pendingApproval,

        SUM(
          status = 'approved'
        ) AS approved,

        SUM(
          status = 'rejected'
        ) AS rejected,

        SUM(
          status = 'activated'
        ) AS activated

      FROM tokenization_proposals
    `,
    );

    const [offeringStats] = await pool.execute(
        `
      SELECT
        COUNT(*) AS totalOfferings,

        SUM(
          status = 'draft'
        ) AS drafts,

        SUM(
          status = 'scheduled'
        ) AS scheduled,

        SUM(
          status = 'active'
        ) AS active,

        SUM(
          status = 'paused'
        ) AS paused,

        SUM(
          status = 'completed'
        ) AS completed,

        SUM(
          status = 'suspended'
        ) AS suspended

      FROM token_offerings
    `,
    );

    const [tokenStats] = await pool.execute(
        `
      SELECT
        COUNT(*) AS totalTokens,

        SUM(
          status = 'pending'
        ) AS pending,

        SUM(
          status = 'active'
        ) AS active,

        SUM(
          status = 'paused'
        ) AS paused,

        SUM(
          status = 'fully_sold'
        ) AS fullySold,

        SUM(
          status = 'suspended'
        ) AS suspended

      FROM tokens
    `,
    );

    const [pendingApprovalRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM admin_action_approvals
      WHERE module = 'tokenization'
        AND status = 'pending'
    `,
    );

    const [eligibleRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM assets a
      WHERE a.status = 'approved'
        AND NOT EXISTS (
          SELECT 1
          FROM tokenization_proposals tp
          WHERE tp.assetId = a.id
            AND tp.status IN (
              'pending_review',
              'changes_required',
              'pending_approval',
              'approved',
              'activated'
            )
        )
        AND NOT EXISTS (
          SELECT 1
          FROM tokens t
          WHERE t.assetId = a.id
            AND t.status NOT IN (
              'burned',
              'suspended'
            )
        )
    `,
    );

    return {
        proposals: {
            total: Number(
                proposalStats[0]?.totalProposals ?? 0,
            ),
            drafts: Number(
                proposalStats[0]?.drafts ?? 0,
            ),
            pendingReview: Number(
                proposalStats[0]?.pendingReview ?? 0,
            ),
            changesRequired: Number(
                proposalStats[0]?.changesRequired ?? 0,
            ),
            pendingApproval: Number(
                proposalStats[0]?.pendingApproval ?? 0,
            ),
            approved: Number(
                proposalStats[0]?.approved ?? 0,
            ),
            rejected: Number(
                proposalStats[0]?.rejected ?? 0,
            ),
            activated: Number(
                proposalStats[0]?.activated ?? 0,
            ),
        },

        offerings: {
            total: Number(
                offeringStats[0]?.totalOfferings ?? 0,
            ),
            drafts: Number(
                offeringStats[0]?.drafts ?? 0,
            ),
            scheduled: Number(
                offeringStats[0]?.scheduled ?? 0,
            ),
            active: Number(
                offeringStats[0]?.active ?? 0,
            ),
            paused: Number(
                offeringStats[0]?.paused ?? 0,
            ),
            completed: Number(
                offeringStats[0]?.completed ?? 0,
            ),
            suspended: Number(
                offeringStats[0]?.suspended ?? 0,
            ),
        },

        tokens: {
            total: Number(
                tokenStats[0]?.totalTokens ?? 0,
            ),
            pending: Number(
                tokenStats[0]?.pending ?? 0,
            ),
            active: Number(
                tokenStats[0]?.active ?? 0,
            ),
            paused: Number(
                tokenStats[0]?.paused ?? 0,
            ),
            fullySold: Number(
                tokenStats[0]?.fullySold ?? 0,
            ),
            suspended: Number(
                tokenStats[0]?.suspended ?? 0,
            ),
        },

        pendingApprovals: Number(
            pendingApprovalRows[0]?.total ?? 0,
        ),

        eligibleAssets: Number(
            eligibleRows[0]?.total ?? 0,
        ),
    };
}

// =========================================================
// GET SINGLE PROPOSAL
// =========================================================

export async function getTokenizationProposal(
    proposalId,
) {
    const normalizedProposalId = normalizeId(
        proposalId,
        "proposalId",
    );

    return getProposal(normalizedProposalId);
}

// =========================================================
// RESUME TOKEN OFFERING
// =========================================================

export async function resumeTokenOffering({
    offeringId,
    adminId,
    ipAddress = null,
    userAgent = null,
}) {
    const normalizedOfferingId =
        normalizeId(offeringId, "offeringId");

    const normalizedAdminId =
        normalizeId(adminId, "adminId");

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.execute(
            `
        SELECT
          o.*,
          t.status AS tokenStatus,
          t.tokenCode,
          t.tokenName
        FROM token_offerings o
        INNER JOIN tokens t
          ON t.id = o.tokenId
        WHERE o.id = ?
        FOR UPDATE
      `,
            [normalizedOfferingId],
        );

        if (rows.length === 0) {
            const error = new Error(
                "Token offering not found.",
            );

            error.statusCode = 404;
            error.code = "TOKEN_OFFERING_NOT_FOUND";

            throw error;
        }

        const offering = rows[0];

        // =======================================================
        // VALIDATE OFFERING STATUS
        // =======================================================

        if (
            !["paused", "suspended"].includes(
                offering.status,
            )
        ) {
            const error = new Error(
                `Offering cannot be resumed while it is ${offering.status}.`,
            );

            error.statusCode = 409;
            error.code =
                "INVALID_OFFERING_RESUME_STATUS";

            throw error;
        }

        // =======================================================
        // VALIDATE UNDERLYING TOKEN STATUS
        // =======================================================

        if (
            [
                "fully_sold",
                "burned",
                "suspended",
            ].includes(
                offering.tokenStatus,
            )
        ) {
            const error = new Error(
                "The underlying token cannot be resumed.",
            );

            error.statusCode = 409;
            error.code = "TOKEN_CANNOT_BE_RESUMED";

            throw error;
        }

        // =======================================================
        // VALIDATE OFFERING START TIME
        // =======================================================

        const now = new Date();

        if (
            offering.offeringStartAt &&
            new Date(
                offering.offeringStartAt,
            ) > now
        ) {
            const error = new Error(
                "This offering has not reached its scheduled start time.",
            );

            error.statusCode = 409;
            error.code = "OFFERING_NOT_STARTED";

            throw error;
        }

        // =======================================================
        // VALIDATE OFFERING END TIME
        // =======================================================

        if (
            offering.offeringEndAt &&
            new Date(
                offering.offeringEndAt,
            ) <= now
        ) {
            const error = new Error(
                "This offering has already reached its end time.",
            );

            error.statusCode = 409;
            error.code = "OFFERING_ALREADY_ENDED";

            throw error;
        }

        const previousStatus =
            offering.status;

        const previousTokenStatus =
            offering.tokenStatus;

        // =======================================================
        // RESUME TOKEN OFFERING
        // =======================================================

        await connection.execute(
            `
        UPDATE token_offerings
        SET
          status = 'active',
          activatedBy = ?,
          activatedAt = COALESCE(
            activatedAt,
            CURRENT_TIMESTAMP
          ),
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                normalizedAdminId,
                normalizedOfferingId,
            ],
        );

        // =======================================================
        // REACTIVATE UNDERLYING TOKEN
        // =======================================================

        await connection.execute(
            `
        UPDATE tokens
        SET
          status = 'active',
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [offering.tokenId],
        );

        // =======================================================
        // STATUS HISTORY
        // =======================================================

        await connection.execute(
            `
        INSERT INTO token_offering_status_history (
          offeringId,
          previousStatus,
          newStatus,
          changedBy,
          reason,
          createdAt
        )
        VALUES (
          ?,
          ?,
          'active',
          ?,
          ?,
          CURRENT_TIMESTAMP
        )
      `,
            [
                normalizedOfferingId,
                previousStatus,
                normalizedAdminId,
                "Token offering resumed.",
            ],
        );

        // =======================================================
        // AUDIT LOG
        // =======================================================

        await writeAdminAuditLog({
            connection,

            staffId:
                normalizedAdminId,

            action:
                "TOKEN_OFFERING_RESUMED",

            module:
                "tokenization",

            entityType:
                "token_offering",

            entityId:
                normalizedOfferingId,

            oldValues: {
                offeringStatus:
                    previousStatus,

                tokenStatus:
                    previousTokenStatus,
            },

            newValues: {
                offeringStatus:
                    "active",

                tokenStatus:
                    "active",
            },

            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenOffering(
            normalizedOfferingId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}