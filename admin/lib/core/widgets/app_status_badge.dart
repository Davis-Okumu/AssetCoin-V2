import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status, this.icon});

  final String status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final configuration = _statusConfiguration(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: configuration.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: configuration.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? configuration.icon,
            size: 15,
            color: configuration.color,
          ),
          const SizedBox(width: 6),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: configuration.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfiguration _statusConfiguration(String value) {
    switch (value.toLowerCase().replaceAll(' ', '_')) {
      case 'pending':
        return const _StatusConfiguration(
          color: AppColors.warning,
          icon: Icons.pending_actions_outlined,
        );

      case 'under_review':
        return const _StatusConfiguration(
          color: AppColors.primary,
          icon: Icons.rate_review_outlined,
        );

      case 'changes_required':
        return const _StatusConfiguration(
          color: AppColors.warning,
          icon: Icons.edit_note_outlined,
        );

      case 'verified':
      case 'approved':
        return const _StatusConfiguration(
          color: AppColors.success,
          icon: Icons.verified_outlined,
        );

      case 'rejected':
        return const _StatusConfiguration(
          color: AppColors.danger,
          icon: Icons.cancel_outlined,
        );

      case 'active':
        return const _StatusConfiguration(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );

      case 'inactive':
        return const _StatusConfiguration(
          color: AppColors.textSecondary,
          icon: Icons.pause_circle_outline,
        );

      default:
        return const _StatusConfiguration(
          color: AppColors.textSecondary,
          icon: Icons.info_outline,
        );
    }
  }

  String _formatStatus(String value) {
    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

class _StatusConfiguration {
  const _StatusConfiguration({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}
