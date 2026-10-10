import 'package:flutter/material.dart';

class NotificationStatusBadge extends StatelessWidget {
  const NotificationStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color color;
    final Color background;
    final String label;

    switch (normalized) {
      case 'new':
        color = const Color(0xFF1565C0);
        background = const Color(0xFFE8F1FC);
        label = 'New';
        break;
      case 'read':
        color = const Color(0xFF2E7D32);
        background = const Color(0xFFE8F5E9);
        label = 'Read';
        break;
      case 'archived':
        color = const Color(0xFF667085);
        background = const Color(0xFFF0F2F5);
        label = 'Archived';
        break;
      default:
        color = const Color(0xFF667085);
        background = const Color(0xFFF0F2F5);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
