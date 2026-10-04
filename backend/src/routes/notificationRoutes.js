
import express from "express";

import { authenticateToken } from "../middleware/authMiddleware.js";

import {
  getNotifications,
  getNotification,
  markNotificationRead,
  markAllNotificationsRead,
  getNotificationPreferences,
  updateNotificationPreferences,
} from "../controllers/notificationController.js";

const router = express.Router();

// =====================================================
// NOTIFICATION ROUTES
// =====================================================

router.use(authenticateToken);

// =====================================================
// NOTIFICATION PREFERENCES
// =====================================================

// Get notification preferences
router.get(
  "/preferences",
  getNotificationPreferences
);

// Update notification preferences
router.patch(
  "/preferences",
  updateNotificationPreferences
);

// =====================================================
// NOTIFICATION HISTORY
// =====================================================

// Get all notifications
router.get(
  "/",
  getNotifications
);

// Mark all notifications as viewed
router.patch(
  "/read-all",
  markAllNotificationsRead
);

// Get one notification
router.get(
  "/:id",
  getNotification
);

// Mark one notification as viewed
router.patch(
  "/:id/read",
  markNotificationRead
);

export default router;

