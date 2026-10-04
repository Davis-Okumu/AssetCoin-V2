
import {
  getUserNotifications,
  getNotificationById,
  markNotificationAsViewed,
  markAllNotificationsAsViewed,
  NOTIFICATION_TYPES,
} from "../services/notificationService.js";

// =====================================================
// GET NOTIFICATIONS
// =====================================================

export async function getNotifications(req, res) {
  try {
    const userId = req.user.id;

    const {
      status,
      type,
      limit,
      offset,
    } = req.query;

    const notifications = await getUserNotifications(
      userId,
      {
        status,
        type,
        limit,
        offset,
      }
    );

    return res.status(200).json({
      success: true,
      data: notifications,
    });
  } catch (error) {
    console.error(
      "Get notifications error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve notifications.",
    });
  }
}

// =====================================================
// GET SINGLE NOTIFICATION
// =====================================================

export async function getNotification(req, res) {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;

    if (!/^\d+$/.test(notificationId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID.",
      });
    }

    const notification = await getNotificationById(
      userId,
      notificationId
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found.",
      });
    }

    return res.status(200).json({
      success: true,
      data: notification,
    });
  } catch (error) {
    console.error(
      "Get notification error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve notification.",
    });
  }
}

// =====================================================
// MARK ONE NOTIFICATION AS VIEWED
// =====================================================

export async function markNotificationRead(req, res) {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;

    if (!/^\d+$/.test(notificationId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID.",
      });
    }

    const updated = await markNotificationAsViewed(
      userId,
      notificationId
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Notification not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Notification marked as viewed.",
    });
  } catch (error) {
    console.error(
      "Mark notification viewed error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to update notification.",
    });
  }
}

// =====================================================
// MARK ALL NOTIFICATIONS AS VIEWED
// =====================================================

export async function markAllNotificationsRead(req, res) {
  try {
    const userId = req.user.id;

    const updatedCount = await markAllNotificationsAsViewed(
      userId
    );

    return res.status(200).json({
      success: true,
      message: "All notifications marked as viewed.",
      data: {
        updatedCount,
      },
    });
  } catch (error) {
    console.error(
      "Mark all notifications viewed error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to update notifications.",
    });
  }
}


// =====================================================
// GET NOTIFICATION PREFERENCES
// =====================================================

export async function getNotificationPreferences(req, res) {
  try {
    const userId = req.user.id;

    const preferences = await getUserNotificationPreferences(
      userId
    );

    return res.status(200).json({
      success: true,
      data: preferences,
    });
  } catch (error) {
    console.error(
      "Get notification preferences error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve notification preferences.",
    });
  }
}

// =====================================================
// UPDATE NOTIFICATION PREFERENCES
// =====================================================

export async function updateNotificationPreferences(req, res) {
  try {
    const userId = req.user.id;
    const { preferences } = req.body;

    if (
      !Array.isArray(preferences) ||
      preferences.length === 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Provide at least one notification preference.",
      });
    }

    if (preferences.length > NOTIFICATION_TYPES.length) {
      return res.status(400).json({
        success: false,
        message: "Too many notification preferences supplied.",
      });
    }

    const seenTypes = new Set();

    for (const preference of preferences) {
      if (
        !preference ||
        typeof preference !== "object" ||
        Array.isArray(preference)
      ) {
        return res.status(400).json({
          success: false,
          message: "Invalid notification preference.",
        });
      }

      const { notificationType } = preference;

      if (!NOTIFICATION_TYPES.includes(notificationType)) {
        return res.status(400).json({
          success: false,
          message: "Unsupported notification type.",
        });
      }

      if (seenTypes.has(notificationType)) {
        return res.status(400).json({
          success: false,
          message: "Duplicate notification types are not allowed.",
        });
      }

      seenTypes.add(notificationType);

      const booleanFields = [
        "inAppEnabled",
        "emailEnabled",
        "smsEnabled",
      ];

      const hasValidField = booleanFields.some(
        (field) => typeof preference[field] === "boolean"
      );

      if (!hasValidField) {
        return res.status(400).json({
          success: false,
          message: `Provide at least one valid delivery setting for ${notificationType}.`,
        });
      }

      for (const field of booleanFields) {
        if (
          preference[field] !== undefined &&
          typeof preference[field] !== "boolean"
        ) {
          return res.status(400).json({
            success: false,
            message: `${field} must be a boolean.`,
          });
        }
      }
    }

    const updatedPreferences =
      await updateUserNotificationPreferences(
        userId,
        preferences
      );

    return res.status(200).json({
      success: true,
      message: "Notification preferences updated successfully.",
      data: updatedPreferences,
    });
  } catch (error) {
    console.error(
      "Update notification preferences error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to update notification preferences.",
    });
  }
}

