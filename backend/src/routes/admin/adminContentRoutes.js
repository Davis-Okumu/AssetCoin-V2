import { Router } from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";
import {
    getContentOverviewController,
    listContentController,
    getContentDetailsController,
    createContentController,
    updateContentController,
    publishContentController,
    archiveContentController,
    deleteContentController,
} from "../../controllers/admin/adminContentController.js";
const router = Router();
/**
- ============================================================
- ADMIN CONTENT ROUTES
- Base path: /api/admin/content
- ============================================================
  */
router.use(authenticateAdmin);
// Overview must be declared before the dynamic content-type route.
router.get(
    "/overview",
    requireAdminPermission("content.view"),
    getContentOverviewController,
);
// List announcements, news, or publications.
router.get(
    "/:type",
    requireAdminPermission("content.view"),
    listContentController,
);
// Create a draft.
router.post(
    "/:type",
    requireAdminPermission("content.create"),
    createContentController,
);
// View a single content item.
router.get(
    "/:type/:id",
    requireAdminPermission("content.view"),
    getContentDetailsController,
);
// Edit content.
router.patch(
    "/:type/:id",
    requireAdminPermission("content.update"),
    updateContentController,
);
// Publish content.
router.post(
    "/:type/:id/publish",
    requireAdminPermission("content.publish"),
    publishContentController,
);
// Archive content.
router.post(
    "/:type/:id/archive",
    requireAdminPermission("content.update"),
    archiveContentController,
);
// Delete only eligible non-published content.
router.delete(
    "/:type/:id",
    requireAdminPermission("content.update"),
    deleteContentController,
);
export default router;