import 'package:flutter/material.dart';

class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final config = switch (normalized) {
      'verified' => (
          label: 'Identity Verified',
          icon: Icons.verified_rounded,
        ),
      'pending' => (
          label: 'Verification Pending',
          icon: Icons.schedule_rounded,
        ),
      'rejected' => (
          label: 'Verification Rejected',
          icon: Icons.error_outline_rounded,
        ),
      _ => (
          label: 'Verification Required',
          icon: Icons.shield_outlined,
        ),
    };

    final colorScheme = Theme.of(context).colorScheme;

    final Color color;

    switch (normalized) {
      case 'verified':
        color = Colors.green;
        break;

      case 'pending':
        color = Colors.orange;
        break;

      case 'rejected':
        color = colorScheme.error;
        break;

      default:
        color = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            config.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}