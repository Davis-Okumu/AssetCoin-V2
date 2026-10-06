import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AssetStatusBadge extends StatelessWidget {
  const AssetStatusBadge({super.key, required this.status});

  final String status;

  String get _label {
    switch (status) {
      case 'under_review':
        return 'Under Review';

      case 'changes_required':
        return 'Changes Required';

      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      case 'tokenized':
        return 'Tokenized';

      case 'suspended':
        return 'Suspended';

      case 'draft':
        return 'Draft';

      case 'pending':
        return 'Pending';

      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case 'approved':
      case 'tokenized':
        return AppColors.successLight;

      case 'rejected':
      case 'suspended':
        return AppColors.dangerLight;

      case 'under_review':
      case 'pending':
      case 'changes_required':
        return AppColors.warningLight;

      default:
        return AppColors.surfaceSecondary;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case 'approved':
      case 'tokenized':
        return AppColors.success;

      case 'rejected':
      case 'suspended':
        return AppColors.danger;

      case 'under_review':
      case 'pending':
      case 'changes_required':
        return AppColors.warning;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
