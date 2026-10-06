import 'package:flutter/material.dart';

import '../../data/models/admin_kyc_application.dart';

class KycReviewActions extends StatelessWidget {
  const KycReviewActions({
    super.key,
    required this.application,
    this.isLoading = false,
    this.onStartReview,
    this.onRequestInformation,
    this.onApprove,
    this.onReject,
  });

  final AdminKycApplication application;

  final bool isLoading;

  final VoidCallback? onStartReview;
  final VoidCallback? onRequestInformation;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final canStartReview =
        application.status == 'pending' ||
        application.status == 'changes_required';

    final canReview = application.status == 'under_review';

    final isFinal =
        application.status == 'verified' || application.status == 'rejected';

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Actions',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _description(
                canStartReview: canStartReview,
                canReview: canReview,
                isFinal: isFinal,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (canStartReview)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStartReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Start Review'),
                ),
              )
            else if (canReview)
              _buildReviewButtons(context)
            else if (isFinal)
              _buildFinalState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Approve KYC'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRequestInformation,
            icon: const Icon(Icons.info_outline),
            label: const Text('Request Information'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onReject,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Reject KYC'),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalState(BuildContext context) {
    final verified = application.status == 'verified';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (verified ? Colors.green : Theme.of(context).colorScheme.error)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.verified_outlined : Icons.cancel_outlined,
            color: verified
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              verified
                  ? 'This KYC application has been verified.'
                  : 'This KYC application has been rejected.',
            ),
          ),
        ],
      ),
    );
  }

  String _description({
    required bool canStartReview,
    required bool canReview,
    required bool isFinal,
  }) {
    if (canStartReview) {
      return 'Open this application for formal verification.';
    }

    if (canReview) {
      return 'Review the submitted information and choose an appropriate action.';
    }

    if (isFinal) {
      return 'This application has reached a final review status.';
    }

    return 'No review actions are currently available.';
  }
}
