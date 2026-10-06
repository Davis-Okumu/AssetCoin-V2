import 'package:flutter/material.dart';

class KycStatusBadge extends StatelessWidget {
  const KycStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final configuration = _configuration(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: configuration.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: configuration.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(configuration.icon, size: 15, color: configuration.color),
          const SizedBox(width: 6),
          Text(
            configuration.label,
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

  _StatusConfiguration _configuration(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return const _StatusConfiguration(
          label: 'Pending',
          icon: Icons.pending_actions_outlined,
          color: Colors.orange,
        );

      case 'under_review':
        return const _StatusConfiguration(
          label: 'Under Review',
          icon: Icons.rate_review_outlined,
          color: Colors.blue,
        );

      case 'changes_required':
        return const _StatusConfiguration(
          label: 'Changes Required',
          icon: Icons.edit_note_outlined,
          color: Colors.deepOrange,
        );

      case 'verified':
        return const _StatusConfiguration(
          label: 'Verified',
          icon: Icons.verified_outlined,
          color: Colors.green,
        );

      case 'rejected':
        return const _StatusConfiguration(
          label: 'Rejected',
          icon: Icons.cancel_outlined,
          color: Colors.red,
        );

      default:
        return const _StatusConfiguration(
          label: 'Unknown',
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }
}

class _StatusConfiguration {
  const _StatusConfiguration({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
