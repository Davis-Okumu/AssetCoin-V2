
import pool from "../../config/database.js";

function normalizeNumber(value) {
    const number = Number(value ?? 0);
    return Number.isFinite(number) ? number : 0;
}

function normalizePagination(options = {}) {
    const pageValue = normalizeNumber(options.page);
    const limitValue = normalizeNumber(options.limit);

    const page = Math.max(1, Math.floor(pageValue || 1));
    const limit = Math.min(100, Math.max(1, Math.floor(limitValue || 20)));

    return {
        page,
        limit,
        offset: (page - 1) * limit,
    };
}

function buildLedgerFilters(filters = {}) {
    const conditions = [];
    const values = [];

    if (filters.entryType) {
        conditions.push("le.entryType = ?");
        values.push(filters.entryType);
    }

    if (filters.assetType) {
        conditions.push("le.assetType = ?");
        values.push(filters.assetType);
    }

    if (filters.userId) {
        conditions.push("le.userId = ?");
        values.push(Number(filters.userId));
    }

    if (filters.walletId) {
        conditions.push("le.walletId = ?");
        values.push(Number(filters.walletId));
    }

    if (filters.tokenId) {
        conditions.push("le.tokenId = ?");
        values.push(Number(filters.tokenId));
    }

    if (filters.transactionId) {
        conditions.push("le.transactionId = ?");
        values.push(Number(filters.transactionId));
    }

    if (filters.currency) {
        conditions.push("le.currency = ?");
        values.push(String(filters.currency).trim().toUpperCase());
    }

    if (filters.startDate) {
        conditions.push("le.createdAt >= ?");
        values.push(filters.startDate);
    }

    if (filters.endDate) {
        conditions.push("le.createdAt < DATE_ADD(?, INTERVAL 1 DAY)");
        values.push(filters.endDate);
    }

    if (filters.search) {
        const search = `%${String(filters.search).trim()}%`;

        conditions.push(`(
            CAST(le.id AS CHAR) LIKE ?
            OR le.entryReference LIKE ?
            OR le.description LIKE ?
            OR le.currency LIKE ?
            OR u.firstName LIKE ?
            OR u.lastName LIKE ?
            OR u.email LIKE ?
            OR u.phone LIKE ?
            OR w.walletAddress LIKE ?
            OR CAST(le.transactionId AS CHAR) LIKE ?
        )`);

        values.push(
            search,
            search,
            search,
            search,
            search,
            search,
            search,
            search,
            search,
            search
        );
    }

    return {
        where: conditions.length
            ? `WHERE ${conditions.join(" AND ")}`
            : "",
        values,
    };
}

function buildAuditFilters(filters = {}) {
    const conditions = [];
    const values = [];

    if (filters.entityType) {
        conditions.push("al.entityType = ?");
        values.push(String(filters.entityType).trim());
    }

    if (filters.action) {
        conditions.push("al.action = ?");
        values.push(String(filters.action).trim());
    }

    if (filters.userId) {
        conditions.push("al.userId = ?");
        values.push(Number(filters.userId));
    }

    if (filters.startDate) {
        conditions.push("al.createdAt >= ?");
        values.push(filters.startDate);
    }

    if (filters.endDate) {
        conditions.push("al.createdAt < DATE_ADD(?, INTERVAL 1 DAY)");
        values.push(filters.endDate);
    }

    if (filters.search) {
        const search = `%${String(filters.search).trim()}%`;

        conditions.push(`(
            CAST(al.id AS CHAR) LIKE ?
            OR al.action LIKE ?
            OR al.entityType LIKE ?
            OR CAST(al.entityId AS CHAR) LIKE ?
            OR u.firstName LIKE ?
            OR u.lastName LIKE ?
            OR u.email LIKE ?
        )`);

        values.push(
            search,
            search,
            search,
            search,
            search,
            search,
            search
        );
    }

    return {
        where: conditions.length
            ? `WHERE ${conditions.join(" AND ")}`
            : "",
        values,
    };
}

/**
 * ============================================================
 * LEDGER OVERVIEW
 * ============================================================
 *
 * Read-only reporting from ledger_entries.
 * Debit and credit totals are reported separately by asset type.
 * Stored hash fields are displayed but are not verified here.
 */
export async function getLedgerOverview() {
    const connection = await pool.getConnection();

    try {
        const [
            [summaryRows],
            [assetRows],
            [recentEntries],
        ] = await Promise.all([
            connection.query(`
                SELECT
                    COUNT(*) AS totalEntries,
                    COALESCE(SUM(entryType = 'debit'), 0) AS debitEntries,
                    COALESCE(SUM(entryType = 'credit'), 0) AS creditEntries,
                    COALESCE(SUM(assetType = 'fiat'), 0) AS fiatEntries,
                    COALESCE(SUM(assetType = 'token'), 0) AS tokenEntries,
                    COALESCE(SUM(previousHash IS NULL OR previousHash = ''), 0)
                        AS entriesWithoutPreviousHash,
                    COALESCE(SUM(entryHash IS NULL OR entryHash = ''), 0)
                        AS entriesWithoutHash,
                    MIN(createdAt) AS firstEntryAt,
                    MAX(createdAt) AS latestEntryAt
                FROM ledger_entries
            `),

            connection.query(`
                SELECT
                    assetType,
                    entryType,
                    currency,
                    COUNT(*) AS entryCount,
                    COALESCE(SUM(amount), 0) AS totalAmount
                FROM ledger_entries
                GROUP BY assetType, entryType, currency
                ORDER BY assetType, entryType, currency
            `),

            connection.query(`
                SELECT
                    le.id,
                    le.entryReference,
                    le.userId,
                    le.walletId,
                    le.tokenId,
                    le.transactionId,
                    le.entryType,
                    le.assetType,
                    le.amount,
                    le.currency,
                    le.balanceBefore,
                    le.balanceAfter,
                    le.description,
                    le.previousHash,
                    le.entryHash,
                    le.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    w.walletAddress
                FROM ledger_entries le
                LEFT JOIN users u ON u.id = le.userId
                LEFT JOIN wallets w ON w.id = le.walletId
                ORDER BY le.createdAt DESC, le.id DESC
                LIMIT 10
            `),
        ]);

        const summary = summaryRows[0] ?? {};

        return {
            readOnly: true,
            summary: {
                totalEntries: normalizeNumber(summary.totalEntries),
                debitEntries: normalizeNumber(summary.debitEntries),
                creditEntries: normalizeNumber(summary.creditEntries),
                fiatEntries: normalizeNumber(summary.fiatEntries),
                tokenEntries: normalizeNumber(summary.tokenEntries),
                entriesWithoutPreviousHash: normalizeNumber(
                    summary.entriesWithoutPreviousHash
                ),
                entriesWithoutHash: normalizeNumber(summary.entriesWithoutHash),
                firstEntryAt: summary.firstEntryAt ?? null,
                latestEntryAt: summary.latestEntryAt ?? null,
            },
            totalsByAssetAndType: assetRows.map((row) => ({
                assetType: row.assetType,
                entryType: row.entryType,
                currency: row.currency,
                entryCount: normalizeNumber(row.entryCount),
                totalAmount: row.totalAmount,
            })),
            recentEntries,
            note: "Hash fields are reported as stored. Missing hash fields are indicators for investigation, not proof of tampering.",
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * PAGINATED LEDGER ENTRIES
 * ============================================================
 */
export async function getLedgerEntries(filters = {}) {
    const connection = await pool.getConnection();

    try {
        const { page, limit, offset } = normalizePagination(filters);
        const { where, values } = buildLedgerFilters(filters);

        const [countRows] = await connection.query(
            `
                SELECT COUNT(*) AS total
                FROM ledger_entries le
                LEFT JOIN users u ON u.id = le.userId
                LEFT JOIN wallets w ON w.id = le.walletId
                ${where}
            `,
            values
        );

        const [items] = await connection.query(
            `
                SELECT
                    le.id,
                    le.entryReference,
                    le.userId,
                    le.walletId,
                    le.tokenId,
                    le.transactionId,
                    le.entryType,
                    le.assetType,
                    le.amount,
                    le.currency,
                    le.balanceBefore,
                    le.balanceAfter,
                    le.description,
                    le.previousHash,
                    le.entryHash,
                    le.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.phone,
                    w.walletAddress
                FROM ledger_entries le
                LEFT JOIN users u ON u.id = le.userId
                LEFT JOIN wallets w ON w.id = le.walletId
                ${where}
                ORDER BY le.createdAt DESC, le.id DESC
                LIMIT ? OFFSET ?
            `,
            [...values, limit, offset]
        );

        const total = normalizeNumber(countRows[0]?.total);

        return {
            items,
            entries: items,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
            total,
            page,
            limit,
            readOnly: true,
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * LEDGER ENTRY DETAILS
 * ============================================================
 */
export async function getLedgerEntryById(entryId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
                SELECT
                    le.id,
                    le.entryReference,
                    le.userId,
                    le.walletId,
                    le.tokenId,
                    le.transactionId,
                    le.entryType,
                    le.assetType,
                    le.amount,
                    le.currency,
                    le.balanceBefore,
                    le.balanceAfter,
                    le.description,
                    le.previousHash,
                    le.entryHash,
                    le.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.phone,
                    w.walletAddress,
                    t.transactionReference AS marketplaceTransactionReference,
                    t.status AS marketplaceTransactionStatus,
                    t.quantity AS marketplaceTransactionQuantity,
                    t.pricePerToken AS marketplacePricePerToken,
                    t.totalAmount AS marketplaceTotalAmount,
                    t.feeAmount AS marketplaceFeeAmount
                FROM ledger_entries le
                LEFT JOIN users u ON u.id = le.userId
                LEFT JOIN wallets w ON w.id = le.walletId
                LEFT JOIN transactions t ON t.id = le.transactionId
                WHERE le.id = ?
                LIMIT 1
            `,
            [entryId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * READ-ONLY LEDGER HASH INSPECTION
 * ============================================================
 *
 * This returns the stored hash values and adjacent entries in ID
 * order for investigation. It deliberately does not claim that the
 * hashes are valid or that this order represents the real chain.
 */
export async function getLedgerHashInspection(entryId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
                SELECT
                    id,
                    entryReference,
                    previousHash,
                    entryHash,
                    createdAt
                FROM ledger_entries
                WHERE id = ?
                LIMIT 1
            `,
            [entryId]
        );

        const entry = rows[0] ?? null;

        if (!entry) {
            return null;
        }

        const [previousRows] = await connection.query(
            `
                SELECT id, entryReference, entryHash, createdAt
                FROM ledger_entries
                WHERE id < ?
                ORDER BY id DESC
                LIMIT 1
            `,
            [entryId]
        );

        const [nextRows] = await connection.query(
            `
                SELECT id, entryReference, previousHash, createdAt
                FROM ledger_entries
                WHERE id > ?
                ORDER BY id ASC
                LIMIT 1
            `,
            [entryId]
        );

        return {
            entry,
            previousEntryById: previousRows[0] ?? null,
            nextEntryById: nextRows[0] ?? null,
            verified: false,
            verificationAvailable: false,
            note: "This is a stored-hash inspection only. Cryptographic verification requires the actual hash-generation algorithm, canonical field order, and chain ordering rules.",
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * AUDIT LOG OVERVIEW
 * ============================================================
 *
 * Audit logs are kept separate from financial ledger entries.
 */
export async function getLedgerAuditOverview() {
    const connection = await pool.getConnection();

    try {
        const [
            [summaryRows],
            [actionRows],
        ] = await Promise.all([
            connection.query(`
                SELECT
                    COUNT(*) AS totalLogs,
                    COALESCE(SUM(previousHash IS NULL OR previousHash = ''), 0)
                        AS logsWithoutPreviousHash,
                    COALESCE(SUM(logHash IS NULL OR logHash = ''), 0)
                        AS logsWithoutHash,
                    MIN(createdAt) AS firstLogAt,
                    MAX(createdAt) AS latestLogAt
                FROM audit_logs
            `),

            connection.query(`
                SELECT
                    action,
                    entityType,
                    COUNT(*) AS eventCount,
                    MAX(createdAt) AS latestEventAt
                FROM audit_logs
                GROUP BY action, entityType
                ORDER BY latestEventAt DESC
                LIMIT 20
            `),
        ]);

        const summary = summaryRows[0] ?? {};

        return {
            readOnly: true,
            summary: {
                totalLogs: normalizeNumber(summary.totalLogs),
                logsWithoutPreviousHash: normalizeNumber(
                    summary.logsWithoutPreviousHash
                ),
                logsWithoutHash: normalizeNumber(summary.logsWithoutHash),
                firstLogAt: summary.firstLogAt ?? null,
                latestLogAt: summary.latestLogAt ?? null,
            },
            recentActionTypes: actionRows.map((row) => ({
                action: row.action,
                entityType: row.entityType,
                eventCount: normalizeNumber(row.eventCount),
                latestEventAt: row.latestEventAt,
            })),
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * PAGINATED AUDIT LOGS
 * ============================================================
 */
export async function getLedgerAuditLogs(filters = {}) {
    const connection = await pool.getConnection();

    try {
        const { page, limit, offset } = normalizePagination(filters);
        const { where, values } = buildAuditFilters(filters);

        const [countRows] = await connection.query(
            `
                SELECT COUNT(*) AS total
                FROM audit_logs al
                LEFT JOIN users u ON u.id = al.userId
                ${where}
            `,
            values
        );

        const [items] = await connection.query(
            `
                SELECT
                    al.id,
                    al.userId,
                    al.action,
                    al.entityType,
                    al.entityId,
                    al.oldValues,
                    al.newValues,
                    al.ipAddress,
                    al.userAgent,
                    al.previousHash,
                    al.logHash,
                    al.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email
                FROM audit_logs al
                LEFT JOIN users u ON u.id = al.userId
                ${where}
                ORDER BY al.createdAt DESC, al.id DESC
                LIMIT ? OFFSET ?
            `,
            [...values, limit, offset]
        );

        const total = normalizeNumber(countRows[0]?.total);

        return {
            items,
            logs: items,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
            total,
            page,
            limit,
            readOnly: true,
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * AUDIT LOG DETAILS
 * ============================================================
 */
export async function getLedgerAuditLogById(logId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
                SELECT
                    al.id,
                    al.userId,
                    al.action,
                    al.entityType,
                    al.entityId,
                    al.oldValues,
                    al.newValues,
                    al.ipAddress,
                    al.userAgent,
                    al.previousHash,
                    al.logHash,
                    al.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email
                FROM audit_logs al
                LEFT JOIN users u ON u.id = al.userId
                WHERE al.id = ?
                LIMIT 1
            `,
            [logId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}
