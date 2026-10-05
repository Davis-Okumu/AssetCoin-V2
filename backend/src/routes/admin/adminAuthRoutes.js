import express from "express";

import {
    adminLogin,
    adminMe,
    adminLogout,
} from "../../controllers/admin/adminAuthController.js";

import {
    adminForgotPassword,
    adminResetPassword,
} from "../../controllers/admin/adminPasswordResetController.js";

import {
    authenticateAdmin,
} from "../../middleware/adminAuthMiddleware.js";

const router = express.Router();

// =========================================================
// PUBLIC ADMIN AUTHENTICATION
// =========================================================

router.post(
    "/login",
    adminLogin,
);

// =========================================================
// PUBLIC ADMIN PASSWORD RESET
// =========================================================

router.post(
    "/forgot-password",
    adminForgotPassword,
);

router.post(
    "/reset-password",
    adminResetPassword,
);

// =========================================================
// AUTHENTICATED ADMIN SESSION
// =========================================================

router.get(
    "/me",
    authenticateAdmin,
    adminMe,
);

router.post(
    "/logout",
    authenticateAdmin,
    adminLogout,
);

export default router;