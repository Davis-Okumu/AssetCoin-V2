import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notification.dart';
import '../providers/notification_providers.dart';

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController,
        List<AppNotification>>(
  NotificationController.new,
);

class NotificationController
    extends AsyncNotifier<List<AppNotification>> {
  late final _repository =
      ref.read(notificationRepositoryProvider);

  String? _selectedStatus;
  String? _selectedType;

  String? get selectedStatus => _selectedStatus;

  String? get selectedType => _selectedType;

  @override
  Future<List<AppNotification>> build() async {
    return _fetchNotifications();
  }

  // =====================================================
  // FETCH NOTIFICATIONS
  // =====================================================

  Future<List<AppNotification>> _fetchNotifications() {
    return _repository.getNotifications(
      status: _selectedStatus,
      type: _selectedType,
    );
  }

  // =====================================================
  // FILTER BY STATUS
  // =====================================================

  Future<void> filterByStatus(String? status) async {
    _selectedStatus = status;
    await _reloadNotifications();
  }

  // =====================================================
  // FILTER BY TYPE
  // =====================================================

  Future<void> filterByType(String? type) async {
    _selectedType = type;
    await _reloadNotifications();
  }

  // =====================================================
  // REFRESH NOTIFICATIONS
  // =====================================================

  Future<void> refreshNotifications() async {
    await _reloadNotifications();
  }

  // =====================================================
  // RELOAD NOTIFICATIONS
  // =====================================================

  Future<void> _reloadNotifications() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _fetchNotifications,
    );
  }

  // =====================================================
  // GET SINGLE NOTIFICATION
  // =====================================================

  Future<AppNotification> getNotification(int id) {
    return _repository.getNotification(id);
  }

  // =====================================================
  // MARK ONE NOTIFICATION AS VIEWED
  // =====================================================

  Future<void> markAsViewed(int id) async {
    await _repository.markNotificationAsViewed(id);

    await _reloadNotifications();
  }

  // =====================================================
  // MARK ALL NOTIFICATIONS AS VIEWED
  // =====================================================

  Future<int> markAllAsViewed() async {
    final updatedCount =
        await _repository.markAllNotificationsAsViewed();

    await _reloadNotifications();

    return updatedCount;
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> clearFilters() async {
    _selectedStatus = null;
    _selectedType = null;

    await _reloadNotifications();
  }
}
