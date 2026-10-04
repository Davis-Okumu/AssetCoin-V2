
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class AccountStatusCard extends StatelessWidget {
  const AccountStatusCard({
    super.key,
    required this.status,
    this.description,
    this.lastUpdated,
  });

  final String status;
  final String? description;
  final String? lastUpdated;

  Color get _statusColor {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return const Color(0xFF168653);

      case 'pending verification':
      case 'pending':
        return const Color(0xFFD68A16);

      case 'restricted':
        return const Color(0xFFE07827);

      case 'suspended':
        return const Color(0xFFDC3545);

      default:
        return const Color(0xFF2878D0);
    }
  }

  Color get _statusBackground {
    return _statusColor.withValues(alpha: 0.10);
  }

  IconData get _statusIcon {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return Icons.check_circle_rounded;

      case 'pending verification':
      case 'pending':
        return Icons.pending_actions_rounded;

      case 'restricted':
        return Icons.warning_amber_rounded;

      case 'suspended':
        return Icons.block_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  String get _defaultDescription {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return 'Your AssetCoin account is active and available for '
            'supported platform activities.';

      case 'pending verification':
      case 'pending':
        return 'Your account verification is still pending. '
            'Complete the required steps to proceed.';

      case 'restricted':
        return 'Some account activities are currently restricted. '
            'Check the information provided by AssetCoin.';

      case 'suspended':
        return 'Your account is currently suspended. '
            'Contact AssetCoin support for assistance.';

      default:
        return 'Your current account status is displayed here.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7ECF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: Color(0xFF2878D0),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Account Status',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon,
                      color: _statusColor,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            description ?? _defaultDescription,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.6,
            ),
          ),

          if (lastUpdated != null && lastUpdated!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(
              color: Color(0xFFEAEFF5),
              height: 1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 7),
                Text(
                  'Last updated: $lastUpdated',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}