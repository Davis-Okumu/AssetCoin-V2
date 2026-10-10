
import express from "express";

import {
    getLedgerOverviewController,
    getLedgerEntriesController,
    getLedgerEntryDetailsController,
    getLedgerHashInspectionController,
    getLedgerAuditOverviewController,
    getLedgerAuditLogsController,
    getLedgerAuditLogDetailsController,
} from "../../controllers/admin/adminLedgerController.js";

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
// LEDGER OVERVIEW
// GET /api/admin/ledger/overview
// ============================================================

router.get(
    "/overview",
    requireAdminPermission("ledger.view"),
    getLedgerOverviewController
);

// ============================================================
// LEDGER ENTRIES
// GET /api/admin/ledger/entries
// GET /api/admin/ledger/entries/:id
// GET /api/admin/ledger/entries/:id/hash-inspection
// ============================================================

router.get(
    "/entries",
    requireAdminPermission("ledger.view"),
    getLedgerEntriesController
);

router.get(
    "/entries/:id/hash-inspection",
    requireAdminPermission("ledger.view"),
    getLedgerHashInspectionController
);

router.get(
    "/entries/:id",
    requireAdminPermission("ledger.view"),
    getLedgerEntryDetailsController
);

// ============================================================
// AUDIT OVERVIEW
// GET /api/admin/ledger/audit/overview
// ============================================================

router.get(
    "/audit/overview",
    requireAdminPermission("audit.view"),
    getLedgerAuditOverviewController
);

// ============================================================
// AUDIT LOGS
// GET /api/admin/ledger/audit/logs
// GET /api/admin/ledger/audit/logs/:id
// ============================================================

router.get(
    "/audit/logs",
    requireAdminPermission("audit.view"),
    getLedgerAuditLogsController
);

router.get(
    "/audit/logs/:id",
    requireAdminPermission("audit.view"),
    getLedgerAuditLogDetailsController
);

export default router;
