
import { Router } from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getAdminNotificationsOverviewController,
    getAdminNotificationsController,
    markAdminNotificationAsReadController,
    archiveAdminNotificationController,
} from "../../controllers/admin/adminNotificationsController.js";

const router = Router();

router.use(authenticateAdmin);
router.use(requireAdminPermission("notifications.view"));

router.get(
    "/overview",
    getAdminNotificationsOverviewController,
);

router.get(
    "/",
    getAdminNotificationsController,
);

router.patch(
    "/:id/read",
    markAdminNotificationAsReadController,
);

router.patch(
    "/:id/archive",
    archiveAdminNotificationController,
);

export default router;
