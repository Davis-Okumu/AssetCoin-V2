
import pool from "../../config/database.js";

function normalizeNumber(value) {
    const number = Number(value ?? 0);
    return Number.isFinite(number) ? number : 0;
}

function normalizePagination(options = {}) {
    const page = Math.max(1, normalizeNumber(options.page) || 1);
    const limit = Math.min(
        100,
        Math.max(1, normalizeNumber(options.limit) || 20)
    );

    return {
        page,
        limit,
        offset: (page - 1) * limit,
    };
}

function buildTransactionFilters(filters = {}, fixedType = null) {
    const conditions = [];
    const values = [];

    if (fixedType) {
        conditions.push("wt.transactionType = ?");
        values.push(fixedType);
    } else if (filters.transactionType) {
        conditions.push("wt.transactionType = ?");
        values.push(filters.transactionType);
    }

    if (filters.status) {
        conditions.push("wt.status = ?");
        values.push(filters.status);
    }

    if (filters.walletId) {
        conditions.push("wt.walletId = ?");
        values.push(Number(filters.walletId));
    }

    if (filters.userId) {
        conditions.push("wt.userId = ?");
        values.push(Number(filters.userId));
    }

    if (filters.startDate) {
        conditions.push("wt.createdAt >= ?");
        values.push(filters.startDate);
    }

    if (filters.endDate) {
        conditions.push("wt.createdAt < DATE_ADD(?, INTERVAL 1 DAY)");
        values.push(filters.endDate);
    }

    if (filters.search) {
        const search = `%${String(filters.search).trim()}%`;

        conditions.push(`(
            wt.transactionReference LIKE ?
            OR wt.description LIKE ?
            OR u.firstName LIKE ?
            OR u.lastName LIKE ?
            OR u.email LIKE ?
            OR u.phone LIKE ?
            OR w.walletAddress LIKE ?
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

async function getTransactionsPage(
    connection,
    filters = {},
    fixedType = null
) {
    const { page, limit, offset } = normalizePagination(filters);
    const { where, values } = buildTransactionFilters(
        filters,
        fixedType
    );

    const [countRows] = await connection.query(
        `
            SELECT COUNT(*) AS total
            FROM wallet_transactions wt
            LEFT JOIN users u ON u.id = wt.userId
            LEFT JOIN wallets w ON w.id = wt.walletId
            ${where}
        `,
        values
    );

    const [items] = await connection.query(
        `
            SELECT
                wt.id,
                wt.walletId,
                wt.userId,
                wt.transactionReference,
                wt.transactionType,
                wt.amount,
                wt.currency,
                wt.balanceBefore,
                wt.balanceAfter,
                wt.status,
                wt.description,
                wt.previousHash,
                wt.transactionHash,
                wt.createdAt,
                u.firstName,
                u.lastName,
                u.email,
                u.phone,
                w.walletAddress
            FROM wallet_transactions wt
            LEFT JOIN users u ON u.id = wt.userId
            LEFT JOIN wallets w ON w.id = wt.walletId
            ${where}
            ORDER BY wt.createdAt DESC, wt.id DESC
            LIMIT ? OFFSET ?
        `,
        [...values, limit, offset]
    );

    const total = normalizeNumber(countRows[0]?.total);

    return {
        items,
        transactions: items,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
        total,
        page,
        limit,
    };
}

/**
 * ============================================================
 * ADMIN FINANCE OVERVIEW
 * ============================================================
 *
 * Read-only financial reporting.
 *
 * Deposits and withdrawals are sourced from wallet_transactions.
 * Marketplace trades remain in the separate transactions table.
 * This service never changes wallet balances or financial records.
 */
export async function getFinanceOverview() {
    const connection = await pool.getConnection();

    try {
        const [
            [walletRows],
            [depositRows],
            [withdrawalRows],
            [transactionRows],
            [recentTransactions],
        ] = await Promise.all([
            connection.query(`
                SELECT
                    COUNT(*) AS totalWallets,
                    COALESCE(SUM(status = 'active'), 0) AS activeWallets,
                    COALESCE(SUM(status = 'frozen'), 0) AS frozenWallets,
                    COALESCE(SUM(status = 'closed'), 0) AS closedWallets,
                    COALESCE(SUM(fiatBalance), 0) AS totalWalletBalance,
                    COALESCE(SUM(lockedFiatBalance), 0) AS totalLockedBalance
                FROM wallets
            `),

            connection.query(`
                SELECT
                    COUNT(*) AS totalDeposits,
                    COALESCE(SUM(amount), 0) AS depositVolume
                FROM wallet_transactions
                WHERE transactionType = 'deposit'
                  AND status = 'completed'
            `),

            connection.query(`
                SELECT
                    COUNT(*) AS totalWithdrawals,
                    COALESCE(SUM(amount), 0) AS withdrawalVolume
                FROM wallet_transactions
                WHERE transactionType = 'withdrawal'
                  AND status = 'completed'
            `),

            connection.query(`
                SELECT
                    COUNT(*) AS totalTransactions,
                    COALESCE(SUM(status = 'pending'), 0) AS pendingTransactions,
                    COALESCE(SUM(status = 'completed'), 0) AS completedTransactions,
                    COALESCE(SUM(status = 'failed'), 0) AS failedTransactions,
                    COALESCE(SUM(status = 'reversed'), 0) AS reversedTransactions
                FROM wallet_transactions
            `),

            connection.query(`
                SELECT
                    wt.id,
                    wt.walletId,
                    wt.userId,
                    wt.transactionReference,
                    wt.transactionType,
                    wt.amount,
                    wt.currency,
                    wt.balanceBefore,
                    wt.balanceAfter,
                    wt.status,
                    wt.description,
                    wt.createdAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.phone,
                    w.walletAddress
                FROM wallet_transactions wt
                LEFT JOIN users u ON u.id = wt.userId
                LEFT JOIN wallets w ON w.id = wt.walletId
                ORDER BY wt.createdAt DESC, wt.id DESC
                LIMIT 10
            `),
        ]);

        const wallets = {
            total: normalizeNumber(walletRows[0]?.totalWallets),
            active: normalizeNumber(walletRows[0]?.activeWallets),
            frozen: normalizeNumber(walletRows[0]?.frozenWallets),
            closed: normalizeNumber(walletRows[0]?.closedWallets),
            inactive: normalizeNumber(walletRows[0]?.frozenWallets)
                + normalizeNumber(walletRows[0]?.closedWallets),
            totalBalance: walletRows[0]?.totalWalletBalance ?? "0.00",
            totalLockedBalance: walletRows[0]?.totalLockedBalance ?? "0.00",
        };

        const deposits = {
            completedCount: normalizeNumber(depositRows[0]?.totalDeposits),
            completedVolume: depositRows[0]?.depositVolume ?? "0.00",
        };

        const withdrawals = {
            completedCount: normalizeNumber(
                withdrawalRows[0]?.totalWithdrawals
            ),
            completedVolume: withdrawalRows[0]?.withdrawalVolume ?? "0.00",
        };

        const transactions = {
            total: normalizeNumber(transactionRows[0]?.totalTransactions),
            pending: normalizeNumber(
                transactionRows[0]?.pendingTransactions
            ),
            completed: normalizeNumber(
                transactionRows[0]?.completedTransactions
            ),
            failed: normalizeNumber(transactionRows[0]?.failedTransactions),
            reversed: normalizeNumber(
                transactionRows[0]?.reversedTransactions
            ),
        };

        return {
            // Flat values expected by the finance overview frontend.
            totalWallets: wallets.total,
            totalWalletBalance: wallets.totalBalance,
            totalDeposits: deposits.completedVolume,
            totalWithdrawals: withdrawals.completedVolume,
            totalTransactions: transactions.total,

            // Detailed report data.
            wallets,
            deposits,
            withdrawals,
            transactions,
            recentTransactions,
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * WALLET LIST
 * ============================================================
 */
export async function getFinanceWallets(filters = {}) {
    const connection = await pool.getConnection();

    try {
        const { page, limit, offset } = normalizePagination(filters);
        const conditions = [];
        const values = [];

        if (filters.status) {
            conditions.push("w.status = ?");
            values.push(filters.status);
        }

        if (filters.search) {
            const search = `%${String(filters.search).trim()}%`;

            conditions.push(`(
                w.walletAddress LIKE ?
                OR u.firstName LIKE ?
                OR u.lastName LIKE ?
                OR u.email LIKE ?
                OR u.phone LIKE ?
            )`);

            values.push(search, search, search, search, search);
        }

        const where = conditions.length
            ? `WHERE ${conditions.join(" AND ")}`
            : "";

        const [countRows] = await connection.query(
            `
                SELECT COUNT(*) AS total
                FROM wallets w
                LEFT JOIN users u ON u.id = w.userId
                ${where}
            `,
            values
        );

        const [wallets] = await connection.query(
            `
                SELECT
                    w.id,
                    w.userId,
                    w.walletAddress,
                    w.fiatBalance,
                    w.lockedFiatBalance,
                    w.currency,
                    w.status,
                    w.createdAt,
                    w.updatedAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.phone
                FROM wallets w
                LEFT JOIN users u ON u.id = w.userId
                ${where}
                ORDER BY w.createdAt DESC, w.id DESC
                LIMIT ? OFFSET ?
            `,
            [...values, limit, offset]
        );

        const total = normalizeNumber(countRows[0]?.total);

        return {
            items: wallets,
            wallets,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
            total,
            page,
            limit,
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * WALLET DETAILS
 * ============================================================
 */
export async function getFinanceWalletById(walletId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
                SELECT
                    w.id,
                    w.userId,
                    w.walletAddress,
                    w.fiatBalance,
                    w.lockedFiatBalance,
                    w.currency,
                    w.status,
                    w.createdAt,
                    w.updatedAt,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.phone
                FROM wallets w
                LEFT JOIN users u ON u.id = w.userId
                WHERE w.id = ?
                LIMIT 1
            `,
            [walletId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * WALLET TRANSACTIONS
 * ============================================================
 */
export async function getFinanceWalletTransactions(
    walletId,
    filters = {}
) {
    return getFinanceTransactions({
        ...filters,
        walletId,
    });
}

/**
 * ============================================================
 * ALL WALLET TRANSACTIONS
 * ============================================================
 */
export async function getFinanceTransactions(filters = {}) {
    const connection = await pool.getConnection();

    try {
        return await getTransactionsPage(connection, filters);
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * DEPOSITS
 * ============================================================
 *
 * Includes all deposit statuses, not only completed deposits.
 */
export async function getFinanceDeposits(filters = {}) {
    const connection = await pool.getConnection();

    try {
        return await getTransactionsPage(
            connection,
            filters,
            "deposit"
        );
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * WITHDRAWALS
 * ============================================================
 *
 * Includes all withdrawal statuses, not only completed withdrawals.
 */
export async function getFinanceWithdrawals(filters = {}) {
    const connection = await pool.getConnection();

    try {
        return await getTransactionsPage(
            connection,
            filters,
            "withdrawal"
        );
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * READ-ONLY FINANCIAL RECONCILIATION
 * ============================================================
 *
 * These checks inspect existing records. No reconciliation history
 * is saved, and no wallet or transaction is modified.
 */
export async function getFinanceReconciliation() {
    const connection = await pool.getConnection();

    try {
        const [
            [walletChecks],
            [transactionChecks],
            [statusRows],
        ] = await Promise.all([
            connection.query(`
                SELECT
                    COUNT(*) AS totalWallets,
                    COALESCE(
                        SUM(fiatBalance < 0),
                        0
                    ) AS negativeBalanceWallets,
                    COALESCE(
                        SUM(lockedFiatBalance < 0),
                        0
                    ) AS negativeLockedBalanceWallets,
                    COALESCE(
                        SUM(lockedFiatBalance > fiatBalance),
                        0
                    ) AS lockedBalanceExceedsBalance
                FROM wallets
            `),

            connection.query(`
                SELECT
                    COUNT(*) AS totalTransactions,
                    COALESCE(
                        SUM(
                            status = 'completed'
                            AND (
                                balanceBefore IS NULL
                                OR balanceAfter IS NULL
                            )
                        ),
                        0
                    ) AS completedMissingBalanceSnapshots,
                    COALESCE(
                        SUM(
                            transactionReference IS NULL
                            OR transactionReference = ''
                        ),
                        0
                    ) AS missingTransactionReferences,
                    COALESCE(
                        SUM(amount <= 0),
                        0
                    ) AS nonPositiveAmounts
                FROM wallet_transactions
            `),

            connection.query(`
                SELECT
                    status,
                    COUNT(*) AS count
                FROM wallet_transactions
                GROUP BY status
                ORDER BY status
            `),
        ]);

        const checks = [
            {
                key: "negative_wallet_balances",
                label: "Wallets with negative balances",
                count: normalizeNumber(
                    walletChecks[0]?.negativeBalanceWallets
                ),
            },
            {
                key: "negative_locked_balances",
                label: "Wallets with negative locked balances",
                count: normalizeNumber(
                    walletChecks[0]?.negativeLockedBalanceWallets
                ),
            },
            {
                key: "locked_balance_exceeds_balance",
                label: "Locked balances exceeding wallet balances",
                count: normalizeNumber(
                    walletChecks[0]?.lockedBalanceExceedsBalance
                ),
            },
            {
                key: "missing_balance_snapshots",
                label: "Completed transactions missing balance snapshots",
                count: normalizeNumber(
                    transactionChecks[0]?.completedMissingBalanceSnapshots
                ),
            },
            {
                key: "missing_transaction_references",
                label: "Transactions missing references",
                count: normalizeNumber(
                    transactionChecks[0]?.missingTransactionReferences
                ),
            },
            {
                key: "non_positive_amounts",
                label: "Transactions with zero or negative amounts",
                count: normalizeNumber(
                    transactionChecks[0]?.nonPositiveAmounts
                ),
            },
        ].map((check) => ({
            ...check,
            status: check.count === 0 ? "passed" : "attention_required",
        }));

        const issueCount = checks.reduce(
            (total, check) => total + check.count,
            0
        );

        return {
            generatedAt: new Date().toISOString(),
            readOnly: true,
            summary: {
                totalWallets: normalizeNumber(
                    walletChecks[0]?.totalWallets
                ),
                totalTransactions: normalizeNumber(
                    transactionChecks[0]?.totalTransactions
                ),
                checksPassed: checks.filter(
                    (check) => check.status === "passed"
                ).length,
                checksRequiringAttention: checks.filter(
                    (check) => check.status === "attention_required"
                ).length,
                totalIssues: issueCount,
                status: issueCount === 0
                    ? "passed"
                    : "attention_required",
            },
            checks,
            transactionStatuses: statusRows.map((row) => ({
                status: row.status,
                count: normalizeNumber(row.count),
            })),
            note: "These are live checks against existing database records. No reconciliation history is stored.",
        };
    } finally {
        connection.release();
    }
}
