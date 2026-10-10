import 'package:flutter/material.dart';

import '../../data/models/admin_notification_model.dart';
import 'notification_status_badge.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onMarkRead,
    required this.onArchive,
  });

  final AdminNotificationModel notification;
  final VoidCallback onMarkRead;
  final VoidCallback onArchive;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} • $hour:$minute $period';
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'security':
        return Icons.security_outlined;
      case 'workflow':
        return Icons.account_tree_outlined;
      case 'approval':
        return Icons.fact_check_outlined;
      case 'asset':
        return Icons.real_estate_agent_outlined;
      case 'kyc':
        return Icons.verified_user_outlined;
      case 'tokenization':
        return Icons.token_outlined;
      case 'trading':
        return Icons.swap_horiz;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      case 'support':
        return Icons.support_agent_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canMutate = !notification.isGlobal && !notification.isArchived;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: notification.isNew ? const Color(0xFFF8FBFF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F1FC),
              child: Icon(
                _typeIcon(notification.type),
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isNew
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF172033),
                        ),
                      ),
                      NotificationStatusBadge(status: notification.status),
                      if (notification.isGlobal)
                        const Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('Shared'),
                          avatar: Icon(Icons.people_outline, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      Text(
                        notification.type.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                        ),
                      ),
                      if (notification.referenceType != null)
                        Text(
                          'Reference: ${notification.referenceType}'
                          '${notification.referenceId == null ? '' : ' #${notification.referenceId}'}',
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (notification.isGlobal) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'This notification is shared. Individual '
                      'read/archive actions are unavailable.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (canMutate)
              PopupMenuButton<String>(
                tooltip: 'Notification actions',
                onSelected: (action) {
                  if (action == 'read') onMarkRead();
                  if (action == 'archive') onArchive();
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
                      title: Text('Archive'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
