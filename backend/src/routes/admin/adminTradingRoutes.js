import express from "express";

import {
    getTradingOverviewController,
    getListingsController,
    getListingController,
    suspendListingController,
    reactivateListingController,
    getOrdersController,
    getOrderController,
    getTradesController,
    getTradeController,
    getDisputesController,
    getDisputeController,
    createDisputeController,
    assignDisputeController,
    updateDisputeController,
} from "../../controllers/admin/adminTradingController.js";

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
// TRADING OVERVIEW
// ============================================================

router.get(
    "/overview",
    requireAdminPermission("trading.view"),
    getTradingOverviewController
);


// ============================================================
// LISTINGS
// ============================================================

// All marketplace listings.
router.get(
    "/listings",
    requireAdminPermission("trading.view"),
    getListingsController
);

// Listing details.
router.get(
    "/listings/:id",
    requireAdminPermission("trading.view"),
    getListingController
);


// ============================================================
// SUSPENDED LISTINGS
// ============================================================

// Suspend a marketplace listing.
router.patch(
    "/listings/:id/suspend",
    requireAdminPermission("trading.manage"),
    suspendListingController
);

// Reactivate a suspended listing.
router.patch(
    "/listings/:id/reactivate",
    requireAdminPermission("trading.manage"),
    reactivateListingController
);


// ============================================================
// ORDERS
// ============================================================

// All customer orders.
router.get(
    "/orders",
    requireAdminPermission("trading.view"),
    getOrdersController
);

// Order details.
router.get(
    "/orders/:id",
    requireAdminPermission("trading.view"),
    getOrderController
);


// ============================================================
// COMPLETED TRADES
// ============================================================

// Trading transactions.
// Default controller filter is status=completed.
router.get(
    "/trades",
    requireAdminPermission("trading.view"),
    getTradesController
);

// Trade / transaction details.
router.get(
    "/trades/:id",
    requireAdminPermission("trading.view"),
    getTradeController
);


// ============================================================
// DISPUTES
// ============================================================

// Trading disputes.
router.get(
    "/disputes",
    requireAdminPermission("trading.view"),
    getDisputesController
);

// Dispute details.
router.get(
    "/disputes/:id",
    requireAdminPermission("trading.view"),
    getDisputeController
);

// Create a dispute.
router.post(
    "/disputes",
    requireAdminPermission("trading.manage"),
    createDisputeController
);

// Assign dispute to an administrator.
router.patch(
    "/disputes/:id/assign",
    requireAdminPermission("trading.manage"),
    assignDisputeController
);

// Update dispute status/priority/resolution.
router.patch(
    "/disputes/:id",
    requireAdminPermission("trading.manage"),
    updateDisputeController
);


export default router;