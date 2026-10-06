import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tokenization_proposal_model.dart';
import '../controllers/tokenization_controller.dart';
import '../controllers/tokenization_proposal_controller.dart';
import '../widgets/tokenization_status_badge.dart';

// ============================================================
// PROPOSAL DETAIL PROVIDER (loads the proposal)
// ============================================================
// NOTE: assumes tokenizationApiProvider exposes getProposal(int).
// Rename the call below if your API method is named differently.
// You can move this provider into its own file if you prefer.

final tokenizationProposalDetailProvider =
    FutureProvider.family<TokenizationProposalModel, int>((ref, id) async {
      final api = ref.read(tokenizationApiProvider);

      final json = await api.getProposal(id);

      return TokenizationProposalModel.fromJson(json);
    });

class TokenizationProposalPage extends ConsumerWidget {
  const TokenizationProposalPage({super.key, required this.proposalId});

  final int proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tokenizationProposalDetailProvider(proposalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tokenization Proposal')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(tokenizationProposalDetailProvider(proposalId));
          },
        ),
        data: (proposal) {
          return _ProposalContent(proposal: proposal, proposalId: proposalId);
        },
      ),
    );
  }
}

// ============================================================
// PROPOSAL CONTENT
// ============================================================

class _ProposalContent extends ConsumerWidget {
  const _ProposalContent({required this.proposal, required this.proposalId});

  final TokenizationProposalModel proposal;
  final int proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      tokenizationProposalControllerProvider.notifier,
    );
    final isBusy = ref.watch(tokenizationProposalControllerProvider).isLoading;

    final informationCards = <Widget>[
      _InfoCard(
        title: 'Proposal',
        children: [
          _InfoRow(label: 'Reference', value: proposal.proposalReference),
          _InfoRow(
            label: 'Status',
            valueWidget: TokenizationStatusBadge(status: proposal.status),
          ),
          _InfoRow(label: 'Token Name', value: proposal.proposedTokenName),
          _InfoRow(label: 'Token Code', value: proposal.proposedTokenCode),
          _InfoRow(
            label: 'Total Supply',
            value: proposal.totalSupply.toString(),
          ),
          _InfoRow(
            label: 'Offering Supply',
            value: proposal.offeringSupply.toString(),
          ),
          _InfoRow(
            label: 'Initial Token Price',
            value: '${proposal.initialTokenPrice} ${proposal.currency}',
          ),
          _InfoRow(label: 'Currency', value: proposal.currency),
        ],
      ),
      _InfoCard(
        title: 'Asset',
        children: [
          _InfoRow(label: 'Asset', value: _stringValue(proposal.assetName)),
          _InfoRow(
            label: 'Asset Code',
            value: _stringValue(proposal.assetCode),
          ),
          _InfoRow(
            label: 'Asset Type',
            value: _stringValue(proposal.assetType),
          ),
        ],
      ),
      _InfoCard(
        title: 'Description',
        children: [
          Text(
            _hasText(proposal.description)
                ? proposal.description!
                : 'No description provided.',
          ),
        ],
      ),
      _InfoCard(
        title: 'Review Notes',
        children: [
          Text(
            _hasText(proposal.reviewNotes)
                ? proposal.reviewNotes!
                : 'No review notes.',
          ),
        ],
      ),
    ];

    final actions = _ActionPanel(
      proposal: proposal,
      isBusy: isBusy,
      onSubmit: () async {
        await _runAction(context, ref, () => controller.submit(proposalId));
      },
      onReview: () async {
        await _showReviewDialog(context, ref, controller);
      },
      onApprove: () async {
        await _runAction(context, ref, () => controller.approve(proposalId));
      },
      onReject: () async {
        await _showRejectDialog(context, ref, controller);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: informationCards
                                .map(
                                  (card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: card,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(width: 320, child: actions),
                      ],
                    )
                  : Column(
                      children: [
                        ...informationCards.map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: card,
                          ),
                        ),
                        actions,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // RUN ACTION (shows errors, refreshes proposal on success)
  // ==========================================================

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    await action();

    final actionState = ref.read(tokenizationProposalControllerProvider);

    if (actionState.hasError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: ${actionState.error}')),
        );
      }
      return;
    }

    ref.invalidate(tokenizationProposalDetailProvider(proposalId));
  }

  // ==========================================================
  // REVIEW DIALOG
  // ==========================================================

  Future<void> _showReviewDialog(
    BuildContext context,
    WidgetRef ref,
    TokenizationProposalController controller,
  ) async {
    final commentsController = TextEditingController();

    final result = await showDialog<_ReviewResult>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Review Proposal'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: commentsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Review comments',
                hintText: 'Enter your review comments.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  _ReviewResult(
                    decision: 'changes_required',
                    comments: commentsController.text.trim(),
                  ),
                );
              },
              child: const Text('Request Changes'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  _ReviewResult(
                    decision: 'approved',
                    comments: commentsController.text.trim(),
                  ),
                );
              },
              child: const Text('Approve Review'),
            ),
          ],
        );
      },
    );

    commentsController.dispose();

    if (result == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _runAction(
      context,
      ref,
      () => controller.review(
        proposalId,
        decision: result.decision,
        comments: result.comments.isEmpty ? null : result.comments,
      ),
    );
  }

  // ==========================================================
  // REJECT DIALOG
  // ==========================================================

  Future<void> _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    TokenizationProposalController controller,
  ) async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Proposal'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Rejection reason',
                hintText: 'Enter the reason for rejection.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(reason);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _runAction(
      context,
      ref,
      () => controller.reject(proposalId, reason: result),
    );
  }
}

// ============================================================
// REVIEW RESULT
// ============================================================

class _ReviewResult {
  const _ReviewResult({required this.decision, required this.comments});

  final String decision;
  final String comments;
}

// ============================================================
// ACTION PANEL
// ============================================================

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.proposal,
    required this.isBusy,
    required this.onSubmit,
    required this.onReview,
    required this.onApprove,
    required this.onReject,
  });

  final TokenizationProposalModel proposal;
  final bool isBusy;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onReview;
  final Future<void> Function() onApprove;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    // ----------------------------------------------------------
    // DRAFT / CHANGES REQUIRED
    // ----------------------------------------------------------

    if (proposal.status == 'draft' || proposal.status == 'changes_required') {
      buttons.add(
        FilledButton.icon(
          onPressed: isBusy ? null : onSubmit,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit Proposal'),
        ),
      );
    }

    // ----------------------------------------------------------
    // PENDING REVIEW
    // ----------------------------------------------------------

    if (proposal.status == 'pending_review') {
      buttons.add(
        FilledButton.icon(
          onPressed: isBusy ? null : onReview,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Review Proposal'),
        ),
      );
    }

    // ----------------------------------------------------------
    // PENDING APPROVAL
    // ----------------------------------------------------------

    if (proposal.status == 'pending_approval') {
      buttons.add(
        FilledButton.icon(
          onPressed: isBusy ? null : onApprove,
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Approve Proposal'),
        ),
      );

      buttons.add(
        OutlinedButton.icon(
          onPressed: isBusy ? null : onReject,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Reject Proposal'),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...buttons.map(
              (button) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION CARD
// ============================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: valueWidget ?? Text(value ?? '—')),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to load tokenization proposal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _stringValue(String? value) {
  if (!_hasText(value)) {
    return '—';
  }

  return value!;
}
