import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_notification_model.dart';
import '../controllers/admin_notifications_controller.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_list.dart';
import '../widgets/notification_overview_cards.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(adminNotificationsControllerProvider);

    final controller = ref.read(adminNotificationsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFC62828),
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172033),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Monitor administrative alerts, workflow '
                            'updates, approvals, and operational events.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: controller.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                NotificationOverviewCards(overview: data.overview),
                const SizedBox(height: 24),
                const Text(
                  'Notification inbox',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 12),
                NotificationFilterBar(
                  type: data.type,
                  status: data.status,
                  search: data.search,
                  onTypeChanged: (value) {
                    controller.applyFilters(type: value);
                  },
                  onStatusChanged: (value) {
                    controller.applyFilters(status: value);
                  },
                  onSearch: (value) {
                    controller.applyFilters(search: value);
                  },
                  onClear: () {
                    controller.applyFilters(
                      type: 'all',
                      status: 'all',
                      search: '',
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${data.notifications.length} notification'
                        '${data.notifications.length == 1 ? '' : 's'} '
                        'shown',
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (data.notifications.any((item) => item.isNew))
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Select an individual notification to '
                                'mark it as read.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.mark_email_read_outlined),
                        label: const Text('Manage unread'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                NotificationList(
                  items: data.notifications,
                  onMarkRead: (AdminNotificationModel notification) {
                    _runAction(
                      context,
                      () => controller.markAsRead(notification),
                      'Notification marked as read.',
                    );
                  },
                  onArchive: (AdminNotificationModel notification) {
                    _runAction(
                      context,
                      () => controller.archive(notification),
                      'Notification archived.',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
