import 'package:flutter/material.dart';

class FinanceStatusBadge extends StatelessWidget {
  const FinanceStatusBadge({super.key, required this.status});

  final String status;

  Color _statusColor() {
    switch (status.toLowerCase().trim()) {
      case 'completed':
      case 'success':
      case 'successful':
      case 'approved':
      case 'active':
      case 'reconciled':
        return const Color(0xFF16834A);

      case 'pending':
      case 'pending_review':
      case 'processing':
      case 'under_review':
      case 'awaiting_approval':
        return const Color(0xFF996500);

      case 'failed':
      case 'rejected':
      case 'cancelled':
      case 'canceled':
      case 'suspended':
      case 'disputed':
        return const Color(0xFFCC3333);

      case 'refunded':
      case 'reversed':
      case 'changes_required':
        return const Color(0xFF7B4AB5);

      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatStatus() {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _formatStatus(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
