import 'notification.dart';
import 'notification_preference.dart';

abstract class NotificationRepository {
  // Retrieve notifications with optional filters.
  Future<List<AppNotification>> getNotifications({
    String? status,
    String? type,
    int limit = 30,
    int offset = 0,
  });

  // Retrieve one notification by ID.
  Future<AppNotification> getNotification(int id);

  // Mark one notification as viewed.
  Future<void> markNotificationAsViewed(int id);

  // Mark all new notifications as viewed.
  Future<int> markAllNotificationsAsViewed();

    // =====================================================
  // NOTIFICATION PREFERENCES
  // =====================================================

  Future<List<NotificationPreference>>
      getNotificationPreferences();

  Future<List<NotificationPreference>>
      updateNotificationPreferences(
    List<NotificationPreference> preferences,
  );

  
}

