import 'package:flutter/material.dart';

class TradingStatusBadge extends StatelessWidget {
  const TradingStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.compact = false,
  });

  final String status;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final configuration = _configuration(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: configuration.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: configuration.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            configuration.icon,
            size: compact ? 12 : 14,
            color: configuration.foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            label ?? _formatStatus(status),
            style: TextStyle(
              color: configuration.foregroundColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfiguration _configuration(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'active':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF166534),
          backgroundColor: Color(0xFFDCFCE7),
          borderColor: Color(0xFF86EFAC),
          icon: Icons.check_circle_outline,
        );

      case 'partially_filled':
      case 'partially-filled':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF0369A1),
          backgroundColor: Color(0xFFE0F2FE),
          borderColor: Color(0xFF7DD3FC),
          icon: Icons.timelapse,
        );

      case 'filled':
      case 'completed':
      case 'resolved':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF166534),
          backgroundColor: Color(0xFFDCFCE7),
          borderColor: Color(0xFF86EFAC),
          icon: Icons.check_circle_outline,
        );

      case 'pending':
      case 'open':
      case 'under_review':
      case 'under-review':
      case 'awaiting_information':
      case 'awaiting-information':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF92400E),
          backgroundColor: Color(0xFFFEF3C7),
          borderColor: Color(0xFFFCD34D),
          icon: Icons.schedule,
        );

      case 'suspended':
      case 'rejected':
      case 'failed':
      case 'cancelled':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFFB91C1C),
          backgroundColor: Color(0xFFFEE2E2),
          borderColor: Color(0xFFFCA5A5),
          icon: Icons.cancel_outlined,
        );

      case 'expired':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF475569),
          backgroundColor: Color(0xFFF1F5F9),
          borderColor: Color(0xFFCBD5E1),
          icon: Icons.timer_off_outlined,
        );

      case 'reversed':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF7C2D12),
          backgroundColor: Color(0xFFFFEDD5),
          borderColor: Color(0xFFFDBA74),
          icon: Icons.undo,
        );

      case 'closed':
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF475569),
          backgroundColor: Color(0xFFF1F5F9),
          borderColor: Color(0xFFCBD5E1),
          icon: Icons.lock_outline,
        );

      default:
        return const _StatusConfiguration(
          foregroundColor: Color(0xFF334155),
          backgroundColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFCBD5E1),
          icon: Icons.info_outline,
        );
    }
  }

  String _formatStatus(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _StatusConfiguration {
  const _StatusConfiguration({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
}
