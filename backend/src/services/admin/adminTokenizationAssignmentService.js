import pool from "../../config/database.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

// =========================================================
// CONSTANTS
// =========================================================

const ASSIGNMENT_MODULE = "tokenization";
const ENTITY_TYPE = "tokenization_proposal";

const ALLOWED_PRIORITIES = new Set([
    "low",
    "normal",
    "high",
    "urgent",
]);

const ALLOWED_ASSIGNMENT_STATUSES = new Set([
    "assigned",
    "in_progress",
    "completed",
    "cancelled",
]);

const ASSIGNABLE_ROLES = new Set([
    "tokenization_officer",
    "super_admin",
]);


// =========================================================
// HELPERS
// =========================================================

function normalizeId(value, fieldName) {
    const id = Number(value);

    if (!Number.isInteger(id) || id <= 0) {
        const error = new Error(
            `${fieldName} must be a positive integer.`,
        );

        error.statusCode = 400;
        error.code = "INVALID_ID";

        throw error;
    }

    return id;
}


function cleanString(value) {
    if (value === undefined || value === null) {
        return null;
    }

    const stringValue = String(value).trim();

    return stringValue.length > 0
        ? stringValue
        : null;
}


function normalizePriority(priority) {
    const value = cleanString(priority) ?? "normal";

    if (!ALLOWED_PRIORITIES.has(value)) {
        const error = new Error(
            "Invalid assignment priority.",
        );

        error.statusCode = 400;
        error.code = "INVALID_ASSIGNMENT_PRIORITY";

        throw error;
    }

    return value;
}


function generateAssignmentReference() {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();

    const random = Math.random()
        .toString(36)
        .slice(2, 8)
        .toUpperCase();

    return `TKA-${timestamp}-${random}`;
}


// =========================================================
// GET ASSIGNABLE TOKENIZATION OFFICERS
// =========================================================

export async function listAssignableTokenizationOfficers() {
    const [rows] = await pool.execute(`
    SELECT
      s.id,
      s.firstName,
      s.lastName,
      s.email,
      s.accountStatus,
      r.code AS roleCode,
      r.name AS roleName

    FROM admin_staff s

    INNER JOIN admin_roles r
      ON r.id = s.roleId

    WHERE
      s.accountStatus = 'active'
      AND r.code IN (
        'tokenization_officer',
        'super_admin'
      )

    ORDER BY
      s.firstName ASC,
      s.lastName ASC
  `);

    return rows;
}


// =========================================================
// GET ASSIGNABLE STAFF
// =========================================================

async function getAssignableStaff(
    connection,
    staffId,
) {
    const [rows] = await connection.execute(
        `
      SELECT
        s.id,
        s.firstName,
        s.lastName,
        s.email,
        s.accountStatus,
        r.code AS roleCode,
        r.name AS roleName

      FROM admin_staff s

      INNER JOIN admin_roles r
        ON r.id = s.roleId

      WHERE
        s.id = ?
        AND s.accountStatus = 'active'
        AND r.code IN (
          'tokenization_officer',
          'super_admin'
        )

      LIMIT 1
    `,
        [staffId],
    );

    if (rows.length === 0) {
        const error = new Error(
            "Selected administrator is not an active tokenization officer.",
        );

        error.statusCode = 400;
        error.code = "INVALID_TOKENIZATION_OFFICER";

        throw error;
    }

    return rows[0];
}


// =========================================================
// GET TOKENIZATION PROPOSAL
// =========================================================

async function getProposal(
    connection,
    proposalId,
) {
    const [rows] = await connection.execute(
        `
      SELECT
        id,
        proposalReference,
        assetId,
        status,
        proposedTokenName,
        proposedTokenCode

      FROM tokenization_proposals

      WHERE id = ?

      LIMIT 1
    `,
        [proposalId],
    );

    if (rows.length === 0) {
        const error = new Error(
            "Tokenization proposal not found.",
        );

        error.statusCode = 404;
        error.code = "TOKENIZATION_PROPOSAL_NOT_FOUND";

        throw error;
    }

    return rows[0];
}


// =========================================================
// GET ASSIGNMENT
// =========================================================

export async function getTokenizationAssignment(
    assignmentId,
) {
    const id = normalizeId(
        assignmentId,
        "assignmentId",
    );

    const [rows] = await pool.execute(
        `
      SELECT
        aa.id,
        aa.assignmentReference,
        aa.module,
        aa.entityType,
        aa.entityId,
        aa.assignedTo,
        aa.assignedBy,
        aa.status,
        aa.priority,
        aa.notes,
        aa.assignedAt,
        aa.startedAt,
        aa.completedAt,
        aa.createdAt,
        aa.updatedAt,

        assigned.firstName AS assignedToFirstName,
        assigned.lastName AS assignedToLastName,
        assigned.email AS assignedToEmail,

        assigner.firstName AS assignedByFirstName,
        assigner.lastName AS assignedByLastName,
        assigner.email AS assignedByEmail,

        tp.proposalReference,
        tp.status AS proposalStatus,
        tp.proposedTokenName,
        tp.proposedTokenCode,

        a.id AS assetId,
        a.assetCode,
        a.name AS assetName,
        a.assetType

      FROM admin_assignments aa

      INNER JOIN admin_staff assigned
        ON assigned.id = aa.assignedTo

      INNER JOIN admin_staff assigner
        ON assigner.id = aa.assignedBy

      INNER JOIN tokenization_proposals tp
        ON tp.id = aa.entityId

      INNER JOIN assets a
        ON a.id = tp.assetId

      WHERE
        aa.id = ?
        AND aa.module = 'tokenization'
        AND aa.entityType = 'tokenization_proposal'

      LIMIT 1
    `,
        [id],
    );

    return rows[0] ?? null;
}


// =========================================================
// LIST TOKENIZATION ASSIGNMENTS
// =========================================================

export async function listTokenizationAssignments({
    proposalId = null,
    assignedTo = null,
    status = null,
    mine = false,
    adminId = null,
    page = 1,
    limit = 20,
} = {}) {
    const safePage = Math.max(
        1,
        Number.parseInt(page, 10) || 1,
    );

    const safeLimit = Math.min(
        100,
        Math.max(
            1,
            Number.parseInt(limit, 10) || 20,
        ),
    );

    const offset =
        (safePage - 1) * safeLimit;

    const conditions = [
        "aa.module = 'tokenization'",
        "aa.entityType = 'tokenization_proposal'",
    ];

    const params = [];

    if (
        proposalId !== null &&
        proposalId !== ""
    ) {
        conditions.push("aa.entityId = ?");
        params.push(
            normalizeId(
                proposalId,
                "proposalId",
            ),
        );
    }

    if (
        assignedTo !== null &&
        assignedTo !== ""
    ) {
        conditions.push("aa.assignedTo = ?");
        params.push(
            normalizeId(
                assignedTo,
                "assignedTo",
            ),
        );
    }

    if (status) {
        if (!ALLOWED_ASSIGNMENT_STATUSES.has(status)) {
            const error = new Error(
                "Invalid assignment status.",
            );

            error.statusCode = 400;
            error.code = "INVALID_ASSIGNMENT_STATUS";

            throw error;
        }

        conditions.push("aa.status = ?");
        params.push(status);
    }

    if (mine) {
        if (
            adminId === null ||
            adminId === ""
        ) {
            const error = new Error(
                "adminId is required when requesting your assignments.",
            );

            error.statusCode = 400;
            error.code = "ADMIN_ID_REQUIRED";

            throw error;
        }

        conditions.push("aa.assignedTo = ?");

        params.push(
            normalizeId(
                adminId,
                "adminId",
            ),
        );
    }

    const whereClause =
        conditions.join(" AND ");

    const [rows] = await pool.execute(
        `
      SELECT
        aa.id,
        aa.assignmentReference,
        aa.module,
        aa.entityType,
        aa.entityId,
        aa.assignedTo,
        aa.assignedBy,
        aa.status,
        aa.priority,
        aa.notes,
        aa.assignedAt,
        aa.startedAt,
        aa.completedAt,
        aa.createdAt,
        aa.updatedAt,

        assigned.firstName AS assignedToFirstName,
        assigned.lastName AS assignedToLastName,
        assigned.email AS assignedToEmail,

        assigner.firstName AS assignedByFirstName,
        assigner.lastName AS assignedByLastName,
        assigner.email AS assignedByEmail,

        tp.proposalReference,
        tp.status AS proposalStatus,
        tp.proposedTokenName,
        tp.proposedTokenCode,

        a.id AS assetId,
        a.assetCode,
        a.name AS assetName,
        a.assetType

      FROM admin_assignments aa

      INNER JOIN admin_staff assigned
        ON assigned.id = aa.assignedTo

      INNER JOIN admin_staff assigner
        ON assigner.id = aa.assignedBy

      INNER JOIN tokenization_proposals tp
        ON tp.id = aa.entityId

      INNER JOIN assets a
        ON a.id = tp.assetId

      WHERE ${whereClause}

      ORDER BY
        CASE aa.priority
          WHEN 'urgent' THEN 1
          WHEN 'high' THEN 2
          WHEN 'normal' THEN 3
          WHEN 'low' THEN 4
          ELSE 5
        END,
        aa.assignedAt DESC

      LIMIT ${safeLimit}
      OFFSET ${offset}
    `,
        params,
    );

    const [countRows] = await pool.execute(
        `
      SELECT
        COUNT(*) AS total

      FROM admin_assignments aa

      WHERE ${whereClause}
    `,
        params,
    );

    const total =
        Number(countRows[0]?.total ?? 0);

    return {
        assignments: rows,

        pagination: {
            page: safePage,
            limit: safeLimit,
            total,
            totalPages: Math.ceil(
                total / safeLimit,
            ),
        },
    };
}


// =========================================================
// ASSIGN TOKENIZATION PROPOSAL
// =========================================================

export async function assignTokenizationProposal({
    proposalId,
    assignedTo,
    assignedBy,
    priority = "normal",
    notes = null,
    ipAddress = null,
    userAgent = null,
}) {
    const normalizedProposalId =
        normalizeId(
            proposalId,
            "proposalId",
        );

    const normalizedAssignedTo =
        normalizeId(
            assignedTo,
            "assignedTo",
        );

    const normalizedAssignedBy =
        normalizeId(
            assignedBy,
            "assignedBy",
        );

    const normalizedPriority =
        normalizePriority(priority);

    const cleanNotes =
        cleanString(notes);

    if (
        normalizedAssignedTo ===
        normalizedAssignedBy
    ) {
        const error = new Error(
            "An administrator cannot assign a tokenization task to themselves.",
        );

        error.statusCode = 400;
        error.code = "SELF_ASSIGNMENT_NOT_ALLOWED";

        throw error;
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const proposal =
            await getProposal(
                connection,
                normalizedProposalId,
            );

        if (
            ![
                "pending_review",
                "changes_required",
            ].includes(proposal.status)
        ) {
            const error = new Error(
                `Proposal cannot be assigned while it is ${proposal.status}.`,
            );

            error.statusCode = 409;
            error.code =
                "INVALID_PROPOSAL_ASSIGNMENT_STATUS";

            throw error;
        }

        const assignedStaff =
            await getAssignableStaff(
                connection,
                normalizedAssignedTo,
            );

        const [existing] =
            await connection.execute(
                `
          SELECT
            id,
            assignmentReference,
            assignedTo,
            status

          FROM admin_assignments

          WHERE
            module = 'tokenization'
            AND entityType = 'tokenization_proposal'
            AND entityId = ?
            AND status IN (
              'assigned',
              'in_progress'
            )

          LIMIT 1

          FOR UPDATE
        `,
                [normalizedProposalId],
            );

        if (existing.length > 0) {
            const error = new Error(
                "This proposal already has an active assignment.",
            );

            error.statusCode = 409;
            error.code =
                "TOKENIZATION_ALREADY_ASSIGNED";

            throw error;
        }

        const assignmentReference =
            generateAssignmentReference();

        const [result] =
            await connection.execute(
                `
          INSERT INTO admin_assignments (
            assignmentReference,
            module,
            entityType,
            entityId,
            assignedTo,
            assignedBy,
            status,
            priority,
            notes,
            assignedAt,
            createdAt,
            updatedAt
          )

          VALUES (
            ?,
            'tokenization',
            'tokenization_proposal',
            ?,
            ?,
            ?,
            'assigned',
            ?,
            ?,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
          )
        `,
                [
                    assignmentReference,
                    normalizedProposalId,
                    normalizedAssignedTo,
                    normalizedAssignedBy,
                    normalizedPriority,
                    cleanNotes,
                ],
            );

        await writeAdminAuditLog({
            connection,

            staffId:
                normalizedAssignedBy,

            action:
                "TOKENIZATION_ASSIGNED",

            module:
                ASSIGNMENT_MODULE,

            entityType:
                ENTITY_TYPE,

            entityId:
                normalizedProposalId,

            oldValues:
                null,

            newValues: {
                assignmentId:
                    result.insertId,

                assignmentReference,

                assignedTo:
                    normalizedAssignedTo,

                assignedToName:
                    `${assignedStaff.firstName} ${assignedStaff.lastName}`,

                priority:
                    normalizedPriority,

                notes:
                    cleanNotes,
            },

            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenizationAssignment(
            result.insertId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// START ASSIGNMENT
// =========================================================

export async function startTokenizationAssignment({
    assignmentId,
    adminId,
    ipAddress = null,
    userAgent = null,
}) {
    const normalizedAssignmentId =
        normalizeId(
            assignmentId,
            "assignmentId",
        );

    const normalizedAdminId =
        normalizeId(
            adminId,
            "adminId",
        );

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] =
            await connection.execute(
                `
          SELECT *
          FROM admin_assignments

          WHERE
            id = ?
            AND module = 'tokenization'
            AND entityType = 'tokenization_proposal'

          FOR UPDATE
        `,
                [normalizedAssignmentId],
            );

        if (rows.length === 0) {
            const error = new Error(
                "Tokenization assignment not found.",
            );

            error.statusCode = 404;
            error.code =
                "ASSIGNMENT_NOT_FOUND";

            throw error;
        }

        const assignment =
            rows[0];

        if (
            Number(assignment.assignedTo) !==
            normalizedAdminId
        ) {
            const error = new Error(
                "Only the assigned tokenization officer can start this assignment.",
            );

            error.statusCode = 403;
            error.code =
                "ASSIGNMENT_ACCESS_DENIED";

            throw error;
        }

        if (
            assignment.status !==
            "assigned"
        ) {
            const error = new Error(
                `Assignment cannot be started while it is ${assignment.status}.`,
            );

            error.statusCode = 409;
            error.code =
                "INVALID_ASSIGNMENT_STATUS";

            throw error;
        }

        await connection.execute(
            `
        UPDATE admin_assignments

        SET
          status = 'in_progress',
          startedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
            [normalizedAssignmentId],
        );

        await writeAdminAuditLog({
            connection,

            staffId:
                normalizedAdminId,

            action:
                "TOKENIZATION_ASSIGNMENT_STARTED",

            module:
                ASSIGNMENT_MODULE,

            entityType:
                ENTITY_TYPE,

            entityId:
                assignment.entityId,

            oldValues: {
                assignmentStatus:
                    "assigned",
            },

            newValues: {
                assignmentStatus:
                    "in_progress",

                assignmentId:
                    normalizedAssignmentId,
            },

            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenizationAssignment(
            normalizedAssignmentId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// COMPLETE ASSIGNMENT
// =========================================================

export async function completeTokenizationAssignment({
    assignmentId,
    adminId,
    notes = null,
    ipAddress = null,
    userAgent = null,
}) {
    const normalizedAssignmentId =
        normalizeId(
            assignmentId,
            "assignmentId",
        );

    const normalizedAdminId =
        normalizeId(
            adminId,
            "adminId",
        );

    const cleanNotes =
        cleanString(notes);

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] =
            await connection.execute(
                `
          SELECT *
          FROM admin_assignments

          WHERE
            id = ?
            AND module = 'tokenization'
            AND entityType = 'tokenization_proposal'

          FOR UPDATE
        `,
                [normalizedAssignmentId],
            );

        if (rows.length === 0) {
            const error = new Error(
                "Tokenization assignment not found.",
            );

            error.statusCode = 404;
            error.code =
                "ASSIGNMENT_NOT_FOUND";

            throw error;
        }

        const assignment =
            rows[0];

        if (
            Number(assignment.assignedTo) !==
            normalizedAdminId
        ) {
            const error = new Error(
                "Only the assigned tokenization officer can complete this assignment.",
            );

            error.statusCode = 403;
            error.code =
                "ASSIGNMENT_ACCESS_DENIED";

            throw error;
        }

        if (
            assignment.status !==
            "in_progress"
        ) {
            const error = new Error(
                `Assignment cannot be completed while it is ${assignment.status}.`,
            );

            error.statusCode = 409;
            error.code =
                "INVALID_ASSIGNMENT_STATUS";

            throw error;
        }

        await connection.execute(
            `
        UPDATE admin_assignments

        SET
          status = 'completed',
          completedAt = CURRENT_TIMESTAMP,
          notes = COALESCE(?, notes),
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
            [
                cleanNotes,
                normalizedAssignmentId,
            ],
        );

        await writeAdminAuditLog({
            connection,

            staffId:
                normalizedAdminId,

            action:
                "TOKENIZATION_ASSIGNMENT_COMPLETED",

            module:
                ASSIGNMENT_MODULE,

            entityType:
                ENTITY_TYPE,

            entityId:
                assignment.entityId,

            oldValues: {
                assignmentStatus:
                    "in_progress",

                notes:
                    assignment.notes,
            },

            newValues: {
                assignmentStatus:
                    "completed",

                assignmentId:
                    normalizedAssignmentId,

                notes:
                    cleanNotes ?? assignment.notes,
            },

            ipAddress,
            userAgent,
        });

        await connection.commit();

        return getTokenizationAssignment(
            normalizedAssignmentId,
        );
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}