import 'package:flutter/material.dart';

import '../../data/models/admin_kyc_review.dart';
import 'kyc_status_badge.dart';

class KycReviewHistory extends StatelessWidget {
  const KycReviewHistory({super.key, required this.reviews});

  final List<AdminKycReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review History',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'A record of actions taken during the KYC review.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (reviews.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: List.generate(reviews.length, (index) {
                  return _ReviewHistoryItem(
                    review: reviews[index],
                    isLast: index == reviews.length - 1,
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, size: 36),
          const SizedBox(height: 10),
          Text(
            'No review activity yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ReviewHistoryItem extends StatelessWidget {
  const _ReviewHistoryItem({required this.review, required this.isLast});

  final AdminKycReview review;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(review.newStatus),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              review.reviewerName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            KycStatusBadge(status: review.newStatus),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (review.previousStatus != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Status changed from '
                      '${_formatStatus(review.previousStatus!)} '
                      'to '
                      '${_formatStatus(review.newStatus)}.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (review.comments != null &&
                      review.comments!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CommentBox(label: 'Comments', text: review.comments!),
                  ],
                  if (review.rejectionReason != null &&
                      review.rejectionReason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CommentBox(
                      label: 'Rejection Reason',
                      text: review.rejectionReason!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'changes_required':
        return Colors.deepOrange;
      case 'under_review':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
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

  String _formatDate(DateTime value) {
    final date = value.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _CommentBox extends StatelessWidget {
  const _CommentBox({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}
