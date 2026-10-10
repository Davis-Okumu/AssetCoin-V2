import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_notification_model.dart';
import '../controllers/admin_notifications_controller.dart';
import '../widgets/notification_status_badge.dart';

class NotificationDetailsPage extends ConsumerWidget {
  const NotificationDetailsPage({super.key, required this.notification});

  final AdminNotificationModel notification;

  String _formatDate(DateTime? value) {
    if (value == null) return 'Not available';

    final date = value.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year at $hour:$minute $period';
  }

  String _formatType(String type) {
    if (type.isEmpty) return 'System';

    return type
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Future<void> _performAction({
    required BuildContext context,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    try {
      await action();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));

      Navigator.of(context).pop();
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
    final controller = ref.read(adminNotificationsControllerProvider.notifier);

    final canMutate = !notification.isGlobal && !notification.isArchived;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        actions: [
          if (canMutate)
            PopupMenuButton<String>(
              tooltip: 'Notification actions',
              onSelected: (value) {
                if (value == 'read') {
                  _performAction(
                    context: context,
                    action: () => controller.markAsRead(notification),
                    successMessage: 'Notification marked as read.',
                  );
                }

                if (value == 'archive') {
                  _performAction(
                    context: context,
                    action: () => controller.archive(notification),
                    successMessage: 'Notification archived.',
                  );
                }
              },
              itemBuilder: (context) => [
                if (notification.isNew)
                  const PopupMenuItem(
                    value: 'read',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.mark_email_read_outlined),
                      title: Text('Mark as read'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Archive notification'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMessageCard(),
                  const SizedBox(height: 20),
                  _buildInformationCard(),
                  if (notification.isGlobal) ...[
                    const SizedBox(height: 20),
                    _buildSharedNotice(),
                  ],
                  if (canMutate) ...[
                    const SizedBox(height: 24),
                    _buildActionButtons(context, controller),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Back to notifications'),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF1565C0),
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(_formatType(notification.type)),
                        avatar: const Icon(Icons.category_outlined, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      NotificationStatusBadge(status: notification.status),
                      if (notification.isGlobal)
                        const Chip(
                          label: Text('Shared notification'),
                          avatar: Icon(Icons.people_outline, size: 16),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return _DetailsCard(
      title: 'Notification message',
      icon: Icons.message_outlined,
      child: SelectableText(
        notification.message,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 15,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return _DetailsCard(
      title: 'Notification information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _InfoRow(label: 'Notification ID', value: notification.id.toString()),
          _InfoRow(label: 'Type', value: _formatType(notification.type)),
          _InfoRow(label: 'Status', value: _formatType(notification.status)),
          _InfoRow(
            label: 'Created at',
            value: _formatDate(notification.createdAt),
          ),
          _InfoRow(label: 'Read at', value: _formatDate(notification.readAt)),
          _InfoRow(
            label: 'Recipient',
            value: notification.staffId == null
                ? 'All administrative staff'
                : 'Staff ID ${notification.staffId}',
          ),
          _InfoRow(
            label: 'Reference type',
            value: notification.referenceType ?? 'None',
          ),
          _InfoRow(
            label: 'Reference ID',
            value: notification.referenceId?.toString() ?? 'None',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSharedNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        border: Border.all(color: const Color(0xFFFFD591)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFAD6800)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This notification is shared with administrative staff. '
              'Read and archive actions are disabled because the current '
              'database schema stores a shared status rather than '
              'individual read receipts.',
              style: TextStyle(color: Color(0xFF874D00), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AdminNotificationsController controller,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (notification.isNew)
          ElevatedButton.icon(
            onPressed: () {
              _performAction(
                context: context,
                action: () => controller.markAsRead(notification),
                successMessage: 'Notification marked as read.',
              );
            },
            icon: const Icon(Icons.mark_email_read_outlined),
            label: const Text('Mark as read'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            _performAction(
              context: context,
              action: () => controller.archive(notification),
              successMessage: 'Notification archived.',
            );
          },
          icon: const Icon(Icons.archive_outlined),
          label: const Text('Archive'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF344054),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1565C0)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFEAECF0)),
      ],
    );
  }
}
