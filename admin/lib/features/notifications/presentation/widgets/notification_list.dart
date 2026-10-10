import 'package:flutter/material.dart';

import '../../data/models/admin_notification_model.dart';
import 'notification_tile.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({
    super.key,
    required this.items,
    required this.onMarkRead,
    required this.onArchive,
  });

  final List<AdminNotificationModel> items;
  final ValueChanged<AdminNotificationModel> onMarkRead;
  final ValueChanged<AdminNotificationModel> onArchive;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 46,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 12),
            Text(
              'No notifications found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try changing the filters or check again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF667085)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          NotificationTile(
            notification: items[i],
            onMarkRead: () => onMarkRead(items[i]),
            onArchive: () => onArchive(items[i]),
          ),
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
