
import {
    getFinanceOverview,
    getFinanceWallets,
    getFinanceWalletById,
    getFinanceWalletTransactions,
    getFinanceTransactions,
    getFinanceDeposits,
    getFinanceWithdrawals,
    getFinanceReconciliation,
} from "../../services/admin/adminFinanceService.js";

function getFilters(req) {
    const {
        page,
        limit,
        search,
        status,
        transactionType,
        walletId,
        userId,
        startDate,
        endDate,
    } = req.query;

    return {
        page,
        limit,
        search,
        status,
        transactionType,
        walletId,
        userId,
        startDate,
        endDate,
    };
}

function parsePositiveId(value) {
    const id = Number(value);

    return Number.isSafeInteger(id) && id > 0
        ? id
        : null;
}

function sendError(res, error, logMessage, publicMessage) {
    console.error(`${logMessage}:`, error);

    return res.status(500).json({
        success: false,
        message: publicMessage,
    });
}

/**
 * ============================================================
 * FINANCE OVERVIEW
 * ============================================================
 */
export async function getFinanceOverviewController(req, res) {
    try {
        const data = await getFinanceOverview();

        return res.status(200).json({
            success: true,
            message: "Admin finance overview retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin finance overview error",
            "Unable to retrieve the finance overview."
        );
    }
}

/**
 * ============================================================
 * WALLET LIST
 * ============================================================
 */
export async function getFinanceWalletsController(req, res) {
    try {
        const data = await getFinanceWallets(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Finance wallets retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance wallets error",
            "Unable to retrieve wallets."
        );
    }
}

/**
 * ============================================================
 * WALLET DETAILS
 * ============================================================
 */
export async function getFinanceWalletDetailsController(req, res) {
    const walletId = parsePositiveId(req.params.id);

    if (!walletId) {
        return res.status(400).json({
            success: false,
            message: "A valid wallet ID is required.",
        });
    }

    try {
        const wallet = await getFinanceWalletById(walletId);

        if (!wallet) {
            return res.status(404).json({
                success: false,
                message: "Wallet not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message: "Wallet details retrieved successfully.",
            data: wallet,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance wallet details error",
            "Unable to retrieve wallet details."
        );
    }
}

/**
 * ============================================================
 * TRANSACTIONS FOR A SPECIFIC WALLET
 * ============================================================
 */
export async function getFinanceWalletTransactionsController(req, res) {
    const walletId = parsePositiveId(req.params.id);

    if (!walletId) {
        return res.status(400).json({
            success: false,
            message: "A valid wallet ID is required.",
        });
    }

    try {
        const wallet = await getFinanceWalletById(walletId);

        if (!wallet) {
            return res.status(404).json({
                success: false,
                message: "Wallet not found.",
            });
        }

        const data = await getFinanceWalletTransactions(
            walletId,
            getFilters(req)
        );

        return res.status(200).json({
            success: true,
            message: "Wallet transactions retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance wallet transactions error",
            "Unable to retrieve wallet transactions."
        );
    }
}

/**
 * ============================================================
 * ALL WALLET TRANSACTIONS
 * ============================================================
 */
export async function getFinanceTransactionsController(req, res) {
    try {
        const data = await getFinanceTransactions(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Finance transactions retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance transactions error",
            "Unable to retrieve transactions."
        );
    }
}

/**
 * ============================================================
 * DEPOSITS
 * ============================================================
 */
export async function getFinanceDepositsController(req, res) {
    try {
        const data = await getFinanceDeposits(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Finance deposits retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance deposits error",
            "Unable to retrieve deposits."
        );
    }
}

/**
 * ============================================================
 * WITHDRAWALS
 * ============================================================
 */
export async function getFinanceWithdrawalsController(req, res) {
    try {
        const data = await getFinanceWithdrawals(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Finance withdrawals retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance withdrawals error",
            "Unable to retrieve withdrawals."
        );
    }
}

/**
 * ============================================================
 * READ-ONLY RECONCILIATION REPORT
 * ============================================================
 */
export async function getFinanceReconciliationController(req, res) {
    try {
        const data = await getFinanceReconciliation();

        return res.status(200).json({
            success: true,
            message: "Finance reconciliation checks retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get finance reconciliation error",
            "Unable to retrieve the reconciliation report."
        );
    }
}
