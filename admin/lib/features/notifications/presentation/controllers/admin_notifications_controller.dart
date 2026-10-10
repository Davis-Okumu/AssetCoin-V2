import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_notification_model.dart';
import '../../data/repositories/admin_notifications_repository.dart';

final adminNotificationsControllerProvider =
    AsyncNotifierProvider<
      AdminNotificationsController,
      AdminNotificationsState
    >(AdminNotificationsController.new);

class AdminNotificationsState {
  const AdminNotificationsState({
    this.overview = const AdminNotificationOverview(),
    this.notifications = const <AdminNotificationModel>[],
    this.type = 'all',
    this.status = 'all',
    this.search = '',
  });

  final AdminNotificationOverview overview;
  final List<AdminNotificationModel> notifications;
  final String type;
  final String status;
  final String search;

  AdminNotificationsState copyWith({
    AdminNotificationOverview? overview,
    List<AdminNotificationModel>? notifications,
    String? type,
    String? status,
    String? search,
  }) {
    return AdminNotificationsState(
      overview: overview ?? this.overview,
      notifications: notifications ?? this.notifications,
      type: type ?? this.type,
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }
}

class AdminNotificationsController
    extends AsyncNotifier<AdminNotificationsState> {
  AdminNotificationsRepository get _repository =>
      ref.read(adminNotificationsRepositoryProvider);

  @override
  Future<AdminNotificationsState> build() async {
    return _load();
  }

  Future<AdminNotificationsState> _load({
    String type = 'all',
    String status = 'all',
    String search = '',
  }) async {
    final results = await Future.wait<dynamic>([
      _repository.getOverview(),
      _repository.getNotifications(type: type, status: status, search: search),
    ]);

    return AdminNotificationsState(
      overview: results[0] as AdminNotificationOverview,
      notifications: results[1] as List<AdminNotificationModel>,
      type: type,
      status: status,
      search: search,
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _load(
        type: current?.type ?? 'all',
        status: current?.status ?? 'all',
        search: current?.search ?? '',
      ),
    );
  }

  Future<void> applyFilters({
    String? type,
    String? status,
    String? search,
  }) async {
    final current = state.value;

    final nextType = type ?? current?.type ?? 'all';
    final nextStatus = status ?? current?.status ?? 'all';
    final nextSearch = search ?? current?.search ?? '';

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(type: nextType, status: nextStatus, search: nextSearch),
    );
  }

  Future<void> markAsRead(AdminNotificationModel notification) async {
    if (notification.isGlobal || notification.isArchived) return;

    await _repository.markAsRead(notification.id);
    await refresh();
  }

  Future<void> archive(AdminNotificationModel notification) async {
    if (notification.isGlobal || notification.isArchived) return;

    await _repository.archive(notification.id);
    await refresh();
  }
}
