import express from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getAssets,
    getAsset,
    getAssetReviews,
    getAssetStatusHistory,
    reviewAdminAsset,
    updateAdminAssetStatus,
} from "../../controllers/admin/adminAssetsController.js";


const router = express.Router();


// =========================================================
// ADMIN AUTHENTICATION
// =========================================================
//
// Every admin asset endpoint requires:
// 1. A valid admin JWT.
// 2. A valid admin session.
//
// =========================================================

router.use(authenticateAdmin);


// =========================================================
// LIST ASSETS
// =========================================================
//
// GET /api/admin/assets
//
// Permission:
// assets.view
//
// =========================================================

router.get(
    "/",
    requireAdminPermission("assets.view"),
    getAssets,
);


// =========================================================
// GET ASSET DETAILS
// =========================================================
//
// GET /api/admin/assets/:id
//
// Permission:
// assets.view
//
// IMPORTANT:
// This route must remain ABOVE any future generic
// mutation routes only where necessary. Express will
// still correctly match /:id/reviews and /:id/status.
//
// =========================================================

router.get(
    "/:id",
    requireAdminPermission("assets.view"),
    getAsset,
);


// =========================================================
// GET ASSET REVIEW HISTORY
// =========================================================
//
// GET /api/admin/assets/:id/reviews
//
// Permission:
// assets.view
//
// =========================================================

router.get(
    "/:id/reviews",
    requireAdminPermission("assets.view"),
    getAssetReviews,
);


// =========================================================
// GET ASSET STATUS HISTORY
// =========================================================
//
// GET /api/admin/assets/:id/status-history
//
// Permission:
// assets.view
//
// =========================================================

router.get(
    "/:id/status-history",
    requireAdminPermission("assets.view"),
    getAssetStatusHistory,
);


// =========================================================
// REVIEW ASSET
// =========================================================
//
// PATCH /api/admin/assets/:id/review
//
// Decisions:
//
// under_review
// changes_required
// approved
// rejected
//
// Permission is selected according to the requested
// decision.
//
// =========================================================

function requireAssetReviewPermission(
    req,
    res,
    next,
) {
    const decision =
        String(
            req.body?.decision ?? "",
        )
            .trim()
            .toLowerCase();

    switch (decision) {
        case "under_review":
        case "changes_required":
            return requireAdminPermission(
                "assets.review",
            )(req, res, next);

        case "approved":
            return requireAdminPermission(
                "assets.approve",
            )(req, res, next);

        case "rejected":
            return requireAdminPermission(
                "assets.reject",
            )(req, res, next);

        default:
            return res.status(400).json({
                success: false,
                message:
                    "A valid asset review decision is required.",
            });
    }
}


router.patch(
    "/:id/review",
    requireAssetReviewPermission,
    reviewAdminAsset,
);


// =========================================================
// CHANGE ASSET STATUS
// =========================================================
//
// PATCH /api/admin/assets/:id/status
//
// Supported operations:
//
// suspended
// approved
//
// Suspension requires:
// assets.suspend
//
// Restoration to approved requires:
// assets.approve
//
// =========================================================

function requireAssetStatusPermission(
    req,
    res,
    next,
) {
    const status =
        String(
            req.body?.status ?? "",
        )
            .trim()
            .toLowerCase();

    switch (status) {
        case "suspended":
            return requireAdminPermission(
                "assets.suspend",
            )(req, res, next);

        case "approved":
            return requireAdminPermission(
                "assets.approve",
            )(req, res, next);

        default:
            return res.status(400).json({
                success: false,
                message:
                    "A valid administrative asset status is required.",
            });
    }
}


router.patch(
    "/:id/status",
    requireAssetStatusPermission,
    updateAdminAssetStatus,
);


export default router;