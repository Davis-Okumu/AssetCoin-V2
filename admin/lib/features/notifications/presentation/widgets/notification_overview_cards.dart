import 'package:flutter/material.dart';

import '../../data/models/admin_notification_model.dart';

class NotificationOverviewCards extends StatelessWidget {
  const NotificationOverviewCards({super.key, required this.overview});

  final AdminNotificationOverview overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 950
            ? 4
            : constraints.maxWidth >= 540
            ? 2
            : 1;

        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final cards = <_OverviewItem>[
          _OverviewItem(
            title: 'Total notifications',
            value: overview.total,
            icon: Icons.notifications_outlined,
            color: const Color(0xFF1565C0),
          ),
          _OverviewItem(
            title: 'New',
            value: overview.newCount,
            icon: Icons.mark_email_unread_outlined,
            color: const Color(0xFFD32F2F),
          ),
          _OverviewItem(
            title: 'Read',
            value: overview.readCount,
            icon: Icons.drafts_outlined,
            color: const Color(0xFF2E7D32),
          ),
          _OverviewItem(
            title: 'Archived',
            value: overview.archivedCount,
            icon: Icons.archive_outlined,
            color: const Color(0xFF667085),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((item) {
            return SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE4E7EC)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.value.toString(),
                              style: const TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _OverviewItem {
  const _OverviewItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
}
