import 'package:flutter/material.dart';

class TokenizationStatusBadge extends StatelessWidget {
  const TokenizationStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final label = normalized
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');

    final color = _statusColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'active':
      case 'completed':
        return Colors.green;

      case 'pending_review':
      case 'pending_approval':
      case 'in_progress':
      case 'scheduled':
        return Colors.orange;

      case 'changes_required':
      case 'paused':
        return Colors.blue;

      case 'rejected':
      case 'suspended':
      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
