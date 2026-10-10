import 'package:flutter/material.dart';

class StaffStatusBadge extends StatelessWidget {
  const StaffStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    final Color foreground;
    final Color background;
    final String label;
    final IconData icon;

    switch (normalizedStatus) {
      case 'active':
        foreground = const Color(0xFF16794B);
        background = const Color(0xFFE6F5EC);
        label = 'Active';
        icon = Icons.check_circle_outline;
        break;

      case 'suspended':
        foreground = const Color(0xFFB45309);
        background = const Color(0xFFFEF3C7);
        label = 'Suspended';
        icon = Icons.pause_circle_outline;
        break;

      case 'inactive':
      case 'deactivated':
        foreground = const Color(0xFF64748B);
        background = const Color(0xFFF1F5F9);
        label = normalizedStatus == 'inactive' ? 'Inactive' : 'Deactivated';
        icon = Icons.remove_circle_outline;
        break;

      case 'locked':
        foreground = const Color(0xFFB91C1C);
        background = const Color(0xFFFEE2E2);
        label = 'Locked';
        icon = Icons.lock_outline;
        break;

      case 'pending':
      case 'pending_verification':
        foreground = const Color(0xFF1D4ED8);
        background = const Color(0xFFDBEAFE);
        label = normalizedStatus == 'pending'
            ? 'Pending'
            : 'Pending verification';
        icon = Icons.hourglass_empty;
        break;

      default:
        foreground = const Color(0xFF475569);
        background = const Color(0xFFF1F5F9);
        label = status.trim().isEmpty ? 'Unknown' : _formatStatus(status);
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String value) {
    return value
        .trim()
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
