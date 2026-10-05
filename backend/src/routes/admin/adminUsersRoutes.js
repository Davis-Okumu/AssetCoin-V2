import express from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getUsers,
    getUser,
    getUserActivityController,
    createAdminUser,
    updateAdminUser,
    updateAdminUserStatus,
} from "../../controllers/admin/adminUserController.js";

const router = express.Router();


// =========================================================
// ADMIN USER MANAGEMENT AUTHENTICATION
// =========================================================
//
// Every route in this router requires an authenticated
// administrator.
//
// Permission checks are applied individually below.
//
// =========================================================

router.use(authenticateAdmin);


// =========================================================
// GET ALL USERS
// =========================================================
//
// GET /api/admin/users
//
// Permission:
// users.view
//
// =========================================================

router.get(
    "/",
    requireAdminPermission("users.view"),
    getUsers,
);


// =========================================================
// CREATE ADMIN USER
// =========================================================
//
// POST /api/admin/users
//
// Permission:
// users.create
//
// =========================================================

router.post(
    "/",
    requireAdminPermission("users.create"),
    createAdminUser,
);


// =========================================================
// GET SINGLE USER
// =========================================================
//
// GET /api/admin/users/:id
//
// Permission:
// users.view
//
// =========================================================

router.get(
    "/:id",
    requireAdminPermission("users.view"),
    getUser,
);


// =========================================================
// GET USER ACTIVITY
// =========================================================
//
// GET /api/admin/users/:id/activity
//
// Permission:
// users.view
//
// =========================================================

router.get(
    "/:id/activity",
    requireAdminPermission("users.view"),
    getUserActivityController,
);


// =========================================================
// UPDATE USER
// =========================================================
//
// PATCH /api/admin/users/:id
//
// Permission:
// users.update
//
// =========================================================

router.patch(
    "/:id",
    requireAdminPermission("users.update"),
    updateAdminUser,
);


// =========================================================
// UPDATE USER ACCOUNT STATUS
// =========================================================
//
// PATCH /api/admin/users/:id/status
//
// Permissions depend on the requested status:
//
// active:
//   users.update
//
// suspended:
//   users.suspend
//
// deactivated:
//   users.deactivate
//
// =========================================================

router.patch(
    "/:id/status",
    updateAdminUserStatusPermission,
    updateAdminUserStatus,
);


// =========================================================
// USER STATUS PERMISSION RESOLVER
// =========================================================

function updateAdminUserStatusPermission(
    request,
    response,
    next,
) {
    const requestedStatus = String(
        request.body?.accountStatus ?? "",
    )
        .trim()
        .toLowerCase();

    // -------------------------------------------------------
    // Suspend
    // -------------------------------------------------------

    if (requestedStatus === "suspended") {
        return requireAdminPermission(
            "users.suspend",
        )(
            request,
            response,
            next,
        );
    }

    // -------------------------------------------------------
    // Deactivate
    // -------------------------------------------------------

    if (requestedStatus === "deactivated") {
        return requireAdminPermission(
            "users.deactivate",
        )(
            request,
            response,
            next,
        );
    }

    // -------------------------------------------------------
    // Reactivate
    // -------------------------------------------------------

    if (requestedStatus === "active") {
        return requireAdminPermission(
            "users.update",
        )(
            request,
            response,
            next,
        );
    }

    // -------------------------------------------------------
    // Invalid status
    // -------------------------------------------------------

    return response.status(400).json({
        success: false,
        message:
            "accountStatus must be active, suspended, or deactivated.",
    });
}


// =========================================================
// EXPORT ROUTER
// =========================================================

export default router;