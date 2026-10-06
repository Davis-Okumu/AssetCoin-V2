import pool from "../../config/database.js";

import {
    writeAdminAuditLog,
} from "./adminAuditService.js";

// =========================================================
// ADMIN KYC SERVICE
// =========================================================
//
// Responsibilities:
//
// - Retrieve KYC applications for administrators.
// - Retrieve KYC statistics.
// - Retrieve complete KYC application details.
// - Assign KYC applications to administrators.
// - Start KYC reviews.
// - Request additional information.
// - Approve KYC applications.
// - Reject KYC applications.
// - Maintain KYC review history.
// - Maintain administrator audit logs.
// - Execute KYC mutations inside database transactions.
//
// IMPORTANT:
//
// Customers submit KYC through the AssetCoin mobile
// application.
//
// Administrators DO NOT upload KYC documents here.
//
// This service is strictly responsible for the
// administrator-side review and verification workflow.
//
// =========================================================


// =========================================================
// CONSTANTS
// =========================================================

const KYC_STATUSES = [
    "pending",
    "under_review",
    "changes_required",
    "verified",
    "rejected",
];

const REVIEWABLE_STATUSES = [
    "pending",
    "changes_required",
];


// =========================================================
// VALIDATE KYC ID
// =========================================================

function normalizeKycId(kycId) {
    const id = Number(kycId);

    if (!Number.isInteger(id) || id <= 0) {
        throw new Error("Invalid KYC application ID.");
    }

    return id;
}


// =========================================================
// GET KYC APPLICATION
// =========================================================

async function getKycRecordForUpdate(
    connection,
    kycId,
) {
    const [rows] = await connection.execute(
        `
      SELECT
        id,
        userId,
        nationalId,
        idDocumentUrl,
        selfieUrl,
        verificationMethod,
        status,
        rejectionReason,
        verifiedBy,
        verifiedAt,
        submittedAt,
        createdAt,
        updatedAt
      FROM kyc_records
      WHERE id = ?
      LIMIT 1
      FOR UPDATE
    `,
        [kycId],
    );

    return rows[0] ?? null;
}


// =========================================================
// GET ADMIN KYC APPLICATIONS
// =========================================================

export async function getAdminKycApplications({
    status = null,
    search = null,
    assignedTo = null,
    page = 1,
    limit = 20,
} = {}) {
    const conditions = [];
    const values = [];

    // -------------------------------------------------------
    // Status filter
    // -------------------------------------------------------

    if (
        status &&
        KYC_STATUSES.includes(status)
    ) {
        conditions.push("k.status = ?");
        values.push(status);
    }

    // -------------------------------------------------------
    // Assignment filter
    // -------------------------------------------------------

    if (assignedTo !== null && assignedTo !== undefined) {
        const adminId = Number(assignedTo);

        if (
            Number.isInteger(adminId) &&
            adminId > 0
        ) {
            conditions.push(
                `
          EXISTS (
            SELECT 1
            FROM admin_assignments aa_filter
            WHERE aa_filter.entityType = 'kyc'
              AND aa_filter.entityId = k.id
              AND aa_filter.module = 'kyc'
              AND aa_filter.assignedTo = ?
              AND aa_filter.status IN (
                'assigned',
                'in_progress'
              )
          )
        `,
            );

            values.push(adminId);
        }
    }

    // -------------------------------------------------------
    // Search
    // -------------------------------------------------------

    if (
        typeof search === "string" &&
        search.trim()
    ) {
        const searchTerm = `%${search.trim()}%`;

        conditions.push(
            `
        (
          CONCAT(u.firstName, ' ', u.lastName) LIKE ?
          OR u.email LIKE ?
          OR u.phone LIKE ?
          OR k.nationalId LIKE ?
        )
      `,
        );

        values.push(
            searchTerm,
            searchTerm,
            searchTerm,
            searchTerm,
        );
    }

    // -------------------------------------------------------
    // Pagination
    // -------------------------------------------------------

    const safePage = Math.max(
        Number(page) || 1,
        1,
    );

    const safeLimit = Math.min(
        Math.max(Number(limit) || 20, 1),
        100,
    );

    const offset =
        (safePage - 1) * safeLimit;

    const whereClause =
        conditions.length > 0
            ? `WHERE ${conditions.join(" AND ")}`
            : "";

    // -------------------------------------------------------
    // Get total
    // -------------------------------------------------------

    const [countRows] = await pool.execute(
        `
      SELECT COUNT(*) AS total
      FROM kyc_records k
      INNER JOIN users u
        ON u.id = k.userId
      ${whereClause}
    `,
        values,
    );

    const total = Number(
        countRows[0]?.total ?? 0,
    );

    // -------------------------------------------------------
    // Get applications
    // -------------------------------------------------------

    const [rows] = await pool.execute(
        `
      SELECT
        k.id,
        k.userId,
        k.nationalId,
        k.verificationMethod,
        k.status,
        k.rejectionReason,
        k.verifiedBy,
        k.verifiedAt,
        k.submittedAt,
        k.createdAt,
        k.updatedAt,

        u.firstName,
        u.lastName,
        u.email,
        u.phone,
        u.profilePhotoUrl,

        CONCAT(u.firstName, ' ', u.lastName)
          AS applicantName,

        assigned.id AS assignmentId,
        assigned.assignedTo,
        assigned.status AS assignmentStatus,
        assigned.priority AS assignmentPriority,
        assigned.assignedAt

      FROM kyc_records k

      INNER JOIN users u
        ON u.id = k.userId

      LEFT JOIN admin_assignments assigned
        ON assigned.id = (
          SELECT aa.id
          FROM admin_assignments aa
          WHERE aa.module = 'kyc'
            AND aa.entityType = 'kyc'
            AND aa.entityId = k.id
            AND aa.status IN (
              'assigned',
              'in_progress'
            )
          ORDER BY aa.id DESC
          LIMIT 1
        )

      ${whereClause}

      ORDER BY
        CASE k.status
          WHEN 'pending' THEN 1
          WHEN 'changes_required' THEN 2
          WHEN 'under_review' THEN 3
          WHEN 'rejected' THEN 4
          WHEN 'verified' THEN 5
          ELSE 6
        END,
        k.submittedAt ASC

      LIMIT ? OFFSET ?
    `,
        [
            ...values,
            safeLimit,
            offset,
        ],
    );

    return {
        applications: rows,
        pagination: {
            page: safePage,
            limit: safeLimit,
            total,
            totalPages:
                total === 0
                    ? 0
                    : Math.ceil(
                        total / safeLimit,
                    ),
        },
    };
}


// =========================================================
// GET KYC STATISTICS
// =========================================================

export async function getAdminKycStats() {
    const [rows] = await pool.execute(
        `
      SELECT
        COUNT(*) AS total,

        SUM(
          CASE
            WHEN status = 'pending'
            THEN 1
            ELSE 0
          END
        ) AS pending,

        SUM(
          CASE
            WHEN status = 'under_review'
            THEN 1
            ELSE 0
          END
        ) AS underReview,

        SUM(
          CASE
            WHEN status = 'changes_required'
            THEN 1
            ELSE 0
          END
        ) AS changesRequired,

        SUM(
          CASE
            WHEN status = 'verified'
            THEN 1
            ELSE 0
          END
        ) AS verified,

        SUM(
          CASE
            WHEN status = 'rejected'
            THEN 1
            ELSE 0
          END
        ) AS rejected

      FROM kyc_records
    `,
    );

    const row = rows[0] ?? {};

    return {
        total: Number(row.total ?? 0),
        pending: Number(row.pending ?? 0),
        underReview: Number(row.underReview ?? 0),
        changesRequired: Number(
            row.changesRequired ?? 0,
        ),
        verified: Number(row.verified ?? 0),
        rejected: Number(row.rejected ?? 0),
    };
}


// =========================================================
// GET KYC APPLICATION DETAILS
// =========================================================

export async function getAdminKycApplication(
    kycId,
) {
    const id = normalizeKycId(kycId);

    // -------------------------------------------------------
    // Application + applicant
    // -------------------------------------------------------

    const [applicationRows] =
        await pool.execute(
            `
        SELECT
          k.id,
          k.userId,
          k.nationalId,
          k.idDocumentUrl,
          k.selfieUrl,
          k.verificationMethod,
          k.status,
          k.rejectionReason,
          k.verifiedBy,
          k.verifiedAt,
          k.submittedAt,
          k.createdAt,
          k.updatedAt,

          u.firstName,
          u.lastName,
          u.email,
          u.phone,
          u.profilePhotoUrl,

          CONCAT(
            u.firstName,
            ' ',
            u.lastName
          ) AS applicantName

        FROM kyc_records k

        INNER JOIN users u
          ON u.id = k.userId

        WHERE k.id = ?

        LIMIT 1
      `,
            [id],
        );

    if (applicationRows.length === 0) {
        return null;
    }

    const application =
        applicationRows[0];

    // -------------------------------------------------------
    // Assignment
    // -------------------------------------------------------

    const [assignmentRows] =
        await pool.execute(
            `
        SELECT
          aa.id,
          aa.assignmentReference,
          aa.assignedTo,
          aa.assignedBy,
          aa.status,
          aa.priority,
          aa.notes,
          aa.assignedAt,
          aa.startedAt,
          aa.completedAt,

          CONCAT(
            assignee.firstName,
            ' ',
            assignee.lastName
          ) AS assignedToName,

          CONCAT(
            assigner.firstName,
            ' ',
            assigner.lastName
          ) AS assignedByName

        FROM admin_assignments aa

        LEFT JOIN admin_staff assignee
          ON assignee.id = aa.assignedTo

        LEFT JOIN admin_staff assigner
          ON assigner.id = aa.assignedBy

        WHERE aa.module = 'kyc'
          AND aa.entityType = 'kyc'
          AND aa.entityId = ?

        ORDER BY aa.id DESC

        LIMIT 1
      `,
            [id],
        );

    // -------------------------------------------------------
    // Review history
    // -------------------------------------------------------

    const [reviewRows] =
        await pool.execute(
            `
        SELECT
          kr.id,
          kr.adminId,
          kr.previousStatus,
          kr.newStatus,
          kr.comments,
          kr.rejectionReason,
          kr.createdAt,

          CONCAT(
            s.firstName,
            ' ',
            s.lastName
          ) AS adminName,

          s.email AS adminEmail

        FROM kyc_reviews kr

        INNER JOIN admin_staff s
          ON s.id = kr.adminId

        WHERE kr.kycId = ?

        ORDER BY kr.createdAt DESC, kr.id DESC
      `,
            [id],
        );

    return {
        application,
        assignment:
            assignmentRows[0] ?? null,
        reviewHistory: reviewRows,
    };
}


// =========================================================
// ASSIGN KYC APPLICATION
// =========================================================

export async function assignKycApplication({
    kycId,
    assignedTo,
    assignedBy,
    priority = "normal",
    notes = null,
    ipAddress = null,
    userAgent = null,
}) {
    const id = normalizeKycId(kycId);

    const assigneeId = Number(
        assignedTo,
    );

    const assignerId = Number(
        assignedBy,
    );

    if (
        !Number.isInteger(assigneeId) ||
        assigneeId <= 0
    ) {
        throw new Error(
            "A valid KYC reviewer is required.",
        );
    }

    if (
        !Number.isInteger(assignerId) ||
        assignerId <= 0
    ) {
        throw new Error(
            "A valid assigning administrator is required.",
        );
    }

    const allowedPriorities = [
        "low",
        "normal",
        "high",
        "urgent",
    ];

    if (!allowedPriorities.includes(priority)) {
        throw new Error(
            "Invalid assignment priority.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        // -----------------------------------------------------
        // Lock KYC record
        // -----------------------------------------------------

        const kyc =
            await getKycRecordForUpdate(
                connection,
                id,
            );

        if (!kyc) {
            throw new Error(
                "KYC application not found.",
            );
        }

        if (
            !REVIEWABLE_STATUSES.includes(
                kyc.status,
            ) &&
            kyc.status !== "under_review"
        ) {
            throw new Error(
                `KYC application cannot be assigned while it is ${kyc.status}.`,
            );
        }

        // -----------------------------------------------------
        // Verify assignee
        // -----------------------------------------------------

        const [staffRows] =
            await connection.execute(
                `
          SELECT
            id,
            firstName,
            lastName,
            email,
            accountStatus
          FROM admin_staff
          WHERE id = ?
          LIMIT 1
        `,
                [assigneeId],
            );

        if (staffRows.length === 0) {
            throw new Error(
                "Assigned administrator was not found.",
            );
        }

        if (
            staffRows[0].accountStatus !==
            "active"
        ) {
            throw new Error(
                "KYC can only be assigned to an active administrator.",
            );
        }

        // -----------------------------------------------------
        // Cancel previous active assignments
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE admin_assignments
        SET
          status = 'cancelled',
          updatedAt = CURRENT_TIMESTAMP
        WHERE module = 'kyc'
          AND entityType = 'kyc'
          AND entityId = ?
          AND status IN (
            'assigned',
            'in_progress'
          )
      `,
            [id],
        );

        // -----------------------------------------------------
        // Generate assignment reference
        // -----------------------------------------------------

        const assignmentReference =
            `KYC-${id}-${Date.now()}`;

        // -----------------------------------------------------
        // Create assignment
        // -----------------------------------------------------

        const [assignmentResult] =
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
            ?, ?, ?, ?, ?, ?, 'assigned',
            ?, ?, CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
          )
        `,
                [
                    assignmentReference,
                    "kyc",
                    "kyc",
                    id,
                    assigneeId,
                    assignerId,
                    priority,
                    notes,
                ],
            );

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: assignerId,
            action: "KYC_ASSIGNED",
            module: "kyc",
            entityType: "kyc",
            entityId: id,
            oldValues: {
                assignedTo: null,
            },
            newValues: {
                assignedTo: assigneeId,
                assignmentId:
                    assignmentResult.insertId,
                priority,
                notes,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            id,
            assignmentId:
                assignmentResult.insertId,
            assignmentReference,
            assignedTo: assigneeId,
            priority,
            status: "assigned",
        };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// START KYC REVIEW
// =========================================================

export async function startKycReview({
    kycId,
    adminId,
    ipAddress = null,
    userAgent = null,
}) {
    const id = normalizeKycId(kycId);

    const reviewerId = Number(adminId);

    if (
        !Number.isInteger(reviewerId) ||
        reviewerId <= 0
    ) {
        throw new Error(
            "Invalid administrator ID.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const kyc =
            await getKycRecordForUpdate(
                connection,
                id,
            );

        if (!kyc) {
            throw new Error(
                "KYC application not found.",
            );
        }

        if (
            !REVIEWABLE_STATUSES.includes(
                kyc.status,
            )
        ) {
            if (kyc.status === "under_review") {
                throw new Error(
                    "This KYC application is already under review.",
                );
            }

            throw new Error(
                `KYC application cannot enter review from ${kyc.status}.`,
            );
        }

        // -----------------------------------------------------
        // Update KYC status
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE kyc_records
        SET
          status = 'under_review',
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [id],
        );

        // -----------------------------------------------------
        // Update active assignment
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE admin_assignments
        SET
          status = 'in_progress',
          startedAt = COALESCE(
            startedAt,
            CURRENT_TIMESTAMP
          ),
          updatedAt = CURRENT_TIMESTAMP
        WHERE module = 'kyc'
          AND entityType = 'kyc'
          AND entityId = ?
          AND assignedTo = ?
          AND status = 'assigned'
      `,
            [id, reviewerId],
        );

        // -----------------------------------------------------
        // Review history
        // -----------------------------------------------------

        await connection.execute(
            `
        INSERT INTO kyc_reviews (
          kycId,
          adminId,
          previousStatus,
          newStatus,
          comments
        )
        VALUES (?, ?, ?, 'under_review', ?)
      `,
            [
                id,
                reviewerId,
                kyc.status,
                "KYC review started.",
            ],
        );

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: reviewerId,
            action: "KYC_REVIEW_STARTED",
            module: "kyc",
            entityType: "kyc",
            entityId: id,
            oldValues: {
                status: kyc.status,
            },
            newValues: {
                status: "under_review",
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            id,
            previousStatus: kyc.status,
            status: "under_review",
        };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// REQUEST ADDITIONAL INFORMATION
// =========================================================

export async function requestKycInformation({
    kycId,
    adminId,
    comments,
    ipAddress = null,
    userAgent = null,
}) {
    const id = normalizeKycId(kycId);

    const reviewerId = Number(adminId);

    if (
        !Number.isInteger(reviewerId) ||
        reviewerId <= 0
    ) {
        throw new Error(
            "Invalid administrator ID.",
        );
    }

    if (
        typeof comments !== "string" ||
        !comments.trim()
    ) {
        throw new Error(
            "Comments are required when requesting additional information.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const kyc =
            await getKycRecordForUpdate(
                connection,
                id,
            );

        if (!kyc) {
            throw new Error(
                "KYC application not found.",
            );
        }

        if (
            ![
                "pending",
                "under_review",
            ].includes(kyc.status)
        ) {
            throw new Error(
                `Additional information cannot be requested while KYC is ${kyc.status}.`,
            );
        }

        // -----------------------------------------------------
        // Update status
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE kyc_records
        SET
          status = 'changes_required',
          rejectionReason = NULL,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [id],
        );

        // -----------------------------------------------------
        // Review history
        // -----------------------------------------------------

        await connection.execute(
            `
        INSERT INTO kyc_reviews (
          kycId,
          adminId,
          previousStatus,
          newStatus,
          comments,
          rejectionReason
        )
        VALUES (?, ?, ?, 'changes_required', ?, NULL)
      `,
            [
                id,
                reviewerId,
                kyc.status,
                comments.trim(),
            ],
        );

        // -----------------------------------------------------
        // Complete active assignment
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE admin_assignments
        SET
          status = 'completed',
          completedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE module = 'kyc'
          AND entityType = 'kyc'
          AND entityId = ?
          AND assignedTo = ?
          AND status IN (
            'assigned',
            'in_progress'
          )
      `,
            [id, reviewerId],
        );

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: reviewerId,
            action: "KYC_INFORMATION_REQUESTED",
            module: "kyc",
            entityType: "kyc",
            entityId: id,
            oldValues: {
                status: kyc.status,
            },
            newValues: {
                status: "changes_required",
                comments: comments.trim(),
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            id,
            previousStatus: kyc.status,
            status: "changes_required",
            comments: comments.trim(),
        };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// APPROVE KYC
// =========================================================

export async function approveKyc({
    kycId,
    adminId,
    comments = null,
    ipAddress = null,
    userAgent = null,
}) {
    const id = normalizeKycId(kycId);

    const reviewerId = Number(adminId);

    if (
        !Number.isInteger(reviewerId) ||
        reviewerId <= 0
    ) {
        throw new Error(
            "Invalid administrator ID.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const kyc =
            await getKycRecordForUpdate(
                connection,
                id,
            );

        if (!kyc) {
            throw new Error(
                "KYC application not found.",
            );
        }

        // -----------------------------------------------------
        // Only active reviews can be approved
        // -----------------------------------------------------

        if (
            ![
                "under_review",
            ].includes(kyc.status)
        ) {
            throw new Error(
                `KYC application cannot be approved while it is ${kyc.status}.`,
            );
        }

        // -----------------------------------------------------
        // Update KYC
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE kyc_records
        SET
          status = 'verified',
          verifiedBy = ?,
          verifiedAt = CURRENT_TIMESTAMP,
          rejectionReason = NULL,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                reviewerId,
                id,
            ],
        );

        // -----------------------------------------------------
        // Review history
        // -----------------------------------------------------

        await connection.execute(
            `
        INSERT INTO kyc_reviews (
          kycId,
          adminId,
          previousStatus,
          newStatus,
          comments,
          rejectionReason
        )
        VALUES (?, ?, ?, 'verified', ?, NULL)
      `,
            [
                id,
                reviewerId,
                kyc.status,
                comments,
            ],
        );

        // -----------------------------------------------------
        // Complete active assignment
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE admin_assignments
        SET
          status = 'completed',
          completedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE module = 'kyc'
          AND entityType = 'kyc'
          AND entityId = ?
          AND status IN (
            'assigned',
            'in_progress'
          )
      `,
            [id],
        );

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: reviewerId,
            action: "KYC_APPROVED",
            module: "kyc",
            entityType: "kyc",
            entityId: id,
            oldValues: {
                status: kyc.status,
                verifiedBy: kyc.verifiedBy,
                verifiedAt: kyc.verifiedAt,
            },
            newValues: {
                status: "verified",
                verifiedBy: reviewerId,
                comments,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            id,
            previousStatus: kyc.status,
            status: "verified",
            verifiedBy: reviewerId,
        };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


// =========================================================
// REJECT KYC
// =========================================================

export async function rejectKyc({
    kycId,
    adminId,
    rejectionReason,
    comments = null,
    ipAddress = null,
    userAgent = null,
}) {
    const id = normalizeKycId(kycId);

    const reviewerId = Number(adminId);

    if (
        !Number.isInteger(reviewerId) ||
        reviewerId <= 0
    ) {
        throw new Error(
            "Invalid administrator ID.",
        );
    }

    if (
        typeof rejectionReason !== "string" ||
        !rejectionReason.trim()
    ) {
        throw new Error(
            "A rejection reason is required.",
        );
    }

    const connection =
        await pool.getConnection();

    try {
        await connection.beginTransaction();

        const kyc =
            await getKycRecordForUpdate(
                connection,
                id,
            );

        if (!kyc) {
            throw new Error(
                "KYC application not found.",
            );
        }

        // -----------------------------------------------------
        // Only active reviews can be rejected
        // -----------------------------------------------------

        if (
            kyc.status !== "under_review"
        ) {
            throw new Error(
                `KYC application cannot be rejected while it is ${kyc.status}.`,
            );
        }

        // -----------------------------------------------------
        // Update KYC
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE kyc_records
        SET
          status = 'rejected',
          rejectionReason = ?,
          verifiedBy = ?,
          verifiedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [
                rejectionReason.trim(),
                reviewerId,
                id,
            ],
        );

        // -----------------------------------------------------
        // Review history
        // -----------------------------------------------------

        await connection.execute(
            `
        INSERT INTO kyc_reviews (
          kycId,
          adminId,
          previousStatus,
          newStatus,
          comments,
          rejectionReason
        )
        VALUES (?, ?, ?, 'rejected', ?, ?)
      `,
            [
                id,
                reviewerId,
                kyc.status,
                comments,
                rejectionReason.trim(),
            ],
        );

        // -----------------------------------------------------
        // Complete active assignment
        // -----------------------------------------------------

        await connection.execute(
            `
        UPDATE admin_assignments
        SET
          status = 'completed',
          completedAt = CURRENT_TIMESTAMP,
          updatedAt = CURRENT_TIMESTAMP
        WHERE module = 'kyc'
          AND entityType = 'kyc'
          AND entityId = ?
          AND status IN (
            'assigned',
            'in_progress'
          )
      `,
            [id],
        );

        // -----------------------------------------------------
        // Audit
        // -----------------------------------------------------

        await writeAdminAuditLog({
            connection,
            staffId: reviewerId,
            action: "KYC_REJECTED",
            module: "kyc",
            entityType: "kyc",
            entityId: id,
            oldValues: {
                status: kyc.status,
            },
            newValues: {
                status: "rejected",
                rejectionReason:
                    rejectionReason.trim(),
                comments,
            },
            ipAddress,
            userAgent,
        });

        await connection.commit();

        return {
            id,
            previousStatus: kyc.status,
            status: "rejected",
            rejectionReason:
                rejectionReason.trim(),
            verifiedBy: reviewerId,
        };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}