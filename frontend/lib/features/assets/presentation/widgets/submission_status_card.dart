
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/asset_submission.dart';

class SubmissionStatusCard extends StatelessWidget {
  const SubmissionStatusCard({
    super.key,
    required this.submission,
    this.onTap,
  });

  final AssetSubmission submission;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFB7791F);

      case 'under_review':
        return const Color(0xFF2563EB);

      case 'changes_required':
        return const Color(0xFFB45309);

      case 'approved':
      case 'tokenized':
        return const Color(0xFF16834A);

      case 'rejected':
      case 'suspended':
        return const Color(0xFFDC2626);

      default:
        return Colors.grey.shade700;
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF7E6);

      case 'under_review':
        return const Color(0xFFEFF6FF);

      case 'changes_required':
        return const Color(0xFFFFF7ED);

      case 'approved':
      case 'tokenized':
        return const Color(0xFFECFDF3);

      case 'rejected':
      case 'suspended':
        return const Color(0xFFFEF2F2);

      default:
        return Colors.grey.shade100;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;

      case 'under_review':
        return Icons.fact_check_outlined;

      case 'changes_required':
        return Icons.edit_note_rounded;

      case 'approved':
        return Icons.check_circle_outline_rounded;

      case 'tokenized':
        return Icons.token_outlined;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'suspended':
        return Icons.pause_circle_outline_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatCurrency(double value, String currency) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0];

    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      buffer.write(whole[i]);

      final remaining = whole.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return '$currency ${buffer.toString()}.${parts[1]}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(submission.status);
    final statusBackground = _statusBackground(submission.status);

    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME AND STATUS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      submission.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(submission.status),
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          submission.displayStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CATEGORY AND LOCATION
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 15,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    submission.assetType.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (submission.location != null &&
                      submission.location!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        submission.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ESTIMATED VALUE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED VALUE',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatCurrency(
                        submission.estimatedValue,
                        submission.currency,
                      ),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // REJECTION REASON
              if (submission.rejectionReason != null &&
                  submission.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD5D5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REVIEW FEEDBACK',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        submission.rejectionReason!,
                        style: const TextStyle(
                          color: Color(0xFF7F1D1D),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // SUBMISSION FOOTER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      submission.assetCode,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(submission.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}