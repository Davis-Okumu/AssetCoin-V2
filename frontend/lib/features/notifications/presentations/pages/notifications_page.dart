import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/notification.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_tabs.dart';
import 'notification_detail_page.dart';

class NotificationsPage extends ConsumerWidget {
  final ValueChanged<AppNotification>? onNotificationTap;

  const NotificationsPage({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState =
        ref.watch(notificationControllerProvider);

    final controller =
        ref.read(notificationControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _markAllAsViewed(context, ref),
            child: const Text(
              'Mark all viewed',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: NotificationFilterTabs(
              selectedStatus: controller.selectedStatus,
              selectedType: controller.selectedType,
              onStatusChanged: (status) {
                controller.filterByStatus(status);
              },
              onTypeChanged: (type) {
                controller.filterByType(type);
              },
            ),
          ),
          Expanded(
            child: notificationState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stackTrace) {
                return _buildErrorState(ref);
              },
              data: (notifications) {
                return _buildNotificationList(
                  context,
                  ref,
                  notifications,
                  controller.selectedStatus != null ||
                      controller.selectedType != null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // NOTIFICATION LIST
  // =====================================================

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
    bool hasFilters,
  ) {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () {
          return ref
              .read(notificationControllerProvider.notifier)
              .refreshNotifications();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            NotificationEmptyState(
              title: hasFilters
                  ? 'No matching notifications'
                  : 'No notifications yet',
              message: hasFilters
                  ? 'There are no notifications matching your selected filters.'
                  : 'You are all caught up. We will notify you when something important happens.',
              onClearFilters: hasFilters
                  ? () {
                      ref
                          .read(notificationControllerProvider.notifier)
                          .clearFilters();
                    }
                  : null,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return ref
            .read(notificationControllerProvider.notifier)
            .refreshNotifications();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return NotificationCard(
            notification: notification,
onTap: () {
  if (onNotificationTap != null) {
    onNotificationTap!(notification);
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => NotificationDetailPage(
        notification: notification,
      ),
    ),
  );
},
          );
        },
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationControllerProvider.notifier)
                    .refreshNotifications();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MARK ALL AS VIEWED
  // =====================================================

  Future<void> _markAllAsViewed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final count = await ref
          .read(notificationControllerProvider.notifier)
          .markAllAsViewed();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'There are no new notifications.'
                : '$count notifications marked as viewed.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update notifications. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}