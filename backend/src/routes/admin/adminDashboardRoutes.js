import { Router } from "express";

import {
  getDashboard,
} from "../../controllers/admin/adminDashboardController.js";

import {
  authenticateAdmin,
  requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

const router = Router();

// =========================================================
// ADMIN DASHBOARD
// =========================================================

router.get(
  "/",
  authenticateAdmin,
  requireAdminPermission("dashboard.view"),
  getDashboard,
);

export default router;