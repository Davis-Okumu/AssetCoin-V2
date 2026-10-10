
import express from "express";

import {
    getFinanceOverviewController,
    getFinanceWalletsController,
    getFinanceWalletDetailsController,
    getFinanceWalletTransactionsController,
    getFinanceTransactionsController,
    getFinanceDepositsController,
    getFinanceWithdrawalsController,
    getFinanceReconciliationController,
} from "../../controllers/admin/adminFinanceController.js";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

const router = express.Router();

// ============================================================
// ADMIN AUTHENTICATION
// ============================================================

router.use(authenticateAdmin);

// ============================================================
// FINANCE OVERVIEW
// GET /api/admin/finance/overview
// ============================================================

router.get(
    "/overview",
    requireAdminPermission("finance.view"),
    getFinanceOverviewController
);

// ============================================================
// WALLETS
// GET /api/admin/finance/wallets
// GET /api/admin/finance/wallets/:id
// GET /api/admin/finance/wallets/:id/transactions
// ============================================================

router.get(
    "/wallets",
    requireAdminPermission("wallets.view"),
    getFinanceWalletsController
);

router.get(
    "/wallets/:id/transactions",
    requireAdminPermission("wallets.view"),
    getFinanceWalletTransactionsController
);

router.get(
    "/wallets/:id",
    requireAdminPermission("wallets.view"),
    getFinanceWalletDetailsController
);

// ============================================================
// WALLET TRANSACTIONS
// GET /api/admin/finance/transactions
// ============================================================

router.get(
    "/transactions",
    requireAdminPermission("finance.view"),
    getFinanceTransactionsController
);

// ============================================================
// DEPOSITS
// GET /api/admin/finance/deposits
// ============================================================

router.get(
    "/deposits",
    requireAdminPermission("finance.view"),
    getFinanceDepositsController
);

// ============================================================
// WITHDRAWALS
// GET /api/admin/finance/withdrawals
// ============================================================

router.get(
    "/withdrawals",
    requireAdminPermission("finance.view"),
    getFinanceWithdrawalsController
);

// ============================================================
// READ-ONLY RECONCILIATION
// GET /api/admin/finance/reconciliation
// ============================================================

router.get(
    "/reconciliation",
    requireAdminPermission("finance.view"),
    getFinanceReconciliationController
);

export default router;
