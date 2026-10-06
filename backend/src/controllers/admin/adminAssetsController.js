import {
    listAssets,
    getAssetById,
    reviewAsset,
    changeAssetStatus,
    getAssetReviewHistory,
    getAssetStatusChangeHistory,
} from "../../services/admin/adminAssetService.js";


// =========================================================
// REQUEST CONTEXT
// =========================================================
//
// Extracts administrator information and request metadata
// required by the audit service.
//
// =========================================================

function requestContext(req) {
    return {
        adminId:
            req.admin?.id ??
            req.adminId ??
            null,

        ipAddress:
            req.headers["x-forwarded-for"]
                ?.split(",")[0]
                ?.trim() ??
            req.socket?.remoteAddress ??
            null,

        userAgent:
            req.headers["user-agent"] ??
            null,
    };
}


// =========================================================
// ERROR RESPONSE
// =========================================================

function sendError(res, error) {
    const statusCode =
        Number(error?.statusCode) >= 400 &&
            Number(error?.statusCode) < 600
            ? Number(error.statusCode)
            : 500;

    if (statusCode >= 500) {
        console.error(
            "Admin asset controller error:",
            error,
        );
    }

    return res.status(statusCode).json({
        success: false,

        message:
            statusCode >= 500
                ? "An unexpected server error occurred."
                : error.message,
    });
}


// =========================================================
// GET ASSETS
// =========================================================
//
// GET /api/admin/assets
//
// Supports:
// - pagination
// - search
// - status
// - asset type
// - owner ID
// - sorting
//
// =========================================================

export async function getAssets(req, res) {
    try {
        const result =
            await listAssets(req.query);

        return res.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}


// =========================================================
// GET ASSET DETAILS
// =========================================================
//
// GET /api/admin/assets/:id
//
// Returns the complete administrative asset view.
//
// =========================================================

export async function getAsset(req, res) {
    try {
        const result =
            await getAssetById(req.params.id);

        return res.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}


// =========================================================
// GET ASSET REVIEW HISTORY
// =========================================================
//
// GET /api/admin/assets/:id/reviews
//
// =========================================================

export async function getAssetReviews(req, res) {
    try {
        const result =
            await getAssetReviewHistory(
                req.params.id,
            );

        return res.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}


// =========================================================
// GET ASSET STATUS HISTORY
// =========================================================
//
// GET /api/admin/assets/:id/status-history
//
// =========================================================

export async function getAssetStatusHistory(
    req,
    res,
) {
    try {
        const result =
            await getAssetStatusChangeHistory(
                req.params.id,
            );

        return res.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}


// =========================================================
// REVIEW ASSET
// =========================================================
//
// PATCH /api/admin/assets/:id/review
//
// Body:
// {
//   "decision": "under_review",
//   "comments": "Documents are being reviewed."
// }
//
// Supported decisions:
// - under_review
// - changes_required
// - approved
// - rejected
//
// =========================================================

export async function reviewAdminAsset(
    req,
    res,
) {
    try {
        const result =
            await reviewAsset({
                assetId: req.params.id,

                decision:
                    req.body?.decision,

                comments:
                    req.body?.comments,

                adminContext:
                    requestContext(req),
            });

        return res.status(200).json({
            success: true,

            message:
                "Asset review updated successfully.",

            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}


// =========================================================
// CHANGE ASSET STATUS
// =========================================================
//
// PATCH /api/admin/assets/:id/status
//
// Body:
// {
//   "status": "suspended",
//   "reason": "Supporting documentation requires
//              further verification."
// }
//
// Supported administrative status operations:
// - suspended
// - approved (restore from suspended)
//
// =========================================================

export async function updateAdminAssetStatus(
    req,
    res,
) {
    try {
        const result =
            await changeAssetStatus({
                assetId: req.params.id,

                status:
                    req.body?.status,

                reason:
                    req.body?.reason,

                adminContext:
                    requestContext(req),
            });

        return res.status(200).json({
            success: true,

            message:
                "Asset status updated successfully.",

            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}