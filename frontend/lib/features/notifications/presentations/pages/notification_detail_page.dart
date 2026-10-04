import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/notification.dart';
import '../controllers/notification_controller.dart';

class NotificationDetailPage extends ConsumerStatefulWidget {
  final AppNotification notification;

  const NotificationDetailPage({
    super.key,
    required this.notification,
  });

  @override
  ConsumerState<NotificationDetailPage> createState() =>
      _NotificationDetailPageState();
}

class _NotificationDetailPageState
    extends ConsumerState<NotificationDetailPage> {
  late Future<AppNotification> _notificationFuture;

  @override
  void initState() {
    super.initState();

    _notificationFuture = _loadNotification();
  }

  // =====================================================
  // LOAD NOTIFICATION AND MARK AS VIEWED
  // =====================================================

  Future<AppNotification> _loadNotification() async {
    final controller =
        ref.read(notificationControllerProvider.notifier);

    if (widget.notification.isNew) {
      await controller.markAsViewed(widget.notification.id);
    }

    return controller.getNotification(widget.notification.id);
  }

  // =====================================================
  // ICON
  // =====================================================

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trading':
        return Icons.show_chart_rounded;

      case 'wallet':
        return Icons.account_balance_wallet_outlined;

      case 'kyc':
        return Icons.verified_user_outlined;

      case 'asset':
        return Icons.real_estate_agent_outlined;

      case 'security':
        return Icons.security_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  // =====================================================
  // CATEGORY COLOR
  // =====================================================

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trading':
        return AppColors.info;

      case 'wallet':
        return AppColors.success;

      case 'kyc':
        return AppColors.info;

      case 'asset':
        return AppColors.warning;

      case 'security':
        return AppColors.error;

      default:
        return AppColors.primary;
    }
  }

  // =====================================================
  // FORMAT CATEGORY
  // =====================================================

  String _formatType(String type) {
    if (type.isEmpty) return 'General';

    return '${type[0].toUpperCase()}${type.substring(1)}';
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/${date.year} at '
        '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
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
          'Notification Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<AppNotification>(
        future: _notificationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          return _buildDetails(snapshot.data!);
        },
      ),
    );
  }

  // =====================================================
  // NOTIFICATION DETAILS
  // =====================================================

  Widget _buildDetails(AppNotification notification) {
    final categoryColor =
        _getNotificationColor(notification.type);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: categoryColor,
                size: 42,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatType(notification.type),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            notification.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              _formatDate(notification.createdAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 22,
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Notification viewed',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  notification.status == 'viewed'
                      ? 'Viewed'
                      : 'New',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load notification',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

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
                setState(() {
                  _notificationFuture = _loadNotification();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}