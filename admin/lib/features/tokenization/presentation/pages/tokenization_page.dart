import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/token_offering_model.dart';
import '../../data/models/tokenization_proposal_model.dart';
import '../controllers/tokenization_controller.dart';
import '../widgets/tokenization_status_badge.dart';
import 'token_offering_page.dart';
import 'tokenization_proposal_page.dart';

class TokenizationPage extends ConsumerStatefulWidget {
  const TokenizationPage({super.key});

  @override
  ConsumerState<TokenizationPage> createState() => _TokenizationPageState();
}

class _TokenizationPageState extends ConsumerState<TokenizationPage> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tokenizationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tokenization')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () {
            ref.read(tokenizationControllerProvider.notifier).load();
          },
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () {
              return ref.read(tokenizationControllerProvider.notifier).load();
            },
            child: _TokenizationContent(
              data: data,
              selectedStatus: _selectedStatus,
              onStatusChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// TOKENIZATION CONTENT
// ============================================================

class _TokenizationContent extends StatelessWidget {
  const _TokenizationContent({
    required this.data,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final TokenizationPageState data;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final proposals = data.proposals;
    final offerings = data.offerings;

    final filteredProposals = selectedStatus == null || selectedStatus!.isEmpty
        ? proposals
        : proposals
              .where((proposal) => proposal.status == selectedStatus)
              .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeader(
                onCreateProposal: () {
                  _showComingSoonMessage(context);
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // OVERVIEW
              // ==================================================
              _OverviewSection(overview: data.overview),

              const SizedBox(height: 28),

              // ==================================================
              // FILTER
              // ==================================================
              _TokenizationFilterBar(
                selectedStatus: selectedStatus,
                onStatusChanged: onStatusChanged,
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PROPOSALS
              // ==================================================
              _SectionHeader(
                title: 'Tokenization Proposals',
                count: filteredProposals.length,
              ),

              const SizedBox(height: 12),

              if (filteredProposals.isEmpty)
                const _EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No tokenization proposals',
                  message:
                      'There are no proposals matching the selected filter.',
                )
              else
                _ProposalList(proposals: filteredProposals),

              const SizedBox(height: 32),

              // ==================================================
              // OFFERINGS
              // ==================================================
              _SectionHeader(title: 'Token Offerings', count: offerings.length),

              const SizedBox(height: 12),

              if (offerings.isEmpty)
                const _EmptyState(
                  icon: Icons.token_outlined,
                  title: 'No token offerings',
                  message: 'There are no token offerings available.',
                )
              else
                _OfferingList(offerings: offerings),

              const SizedBox(height: 32),

              // ==================================================
              // ASSIGNMENTS
              // ==================================================
              _SectionHeader(
                title: 'Tokenization Assignments',
                count: data.assignments.length,
              ),

              const SizedBox(height: 12),

              if (data.assignments.isEmpty)
                const _EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No assignments',
                  message: 'There are no tokenization assignments available.',
                )
              else
                _AssignmentList(assignments: data.assignments),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Proposal creation will be connected to the proposal creation workflow.',
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW
// ============================================================

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.overview});

  final dynamic overview;

  @override
  Widget build(BuildContext context) {
    if (overview == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1100) {
          columns = 4;
        } else if (width >= 700) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cards = _buildOverviewCards(context, overview);

        if (columns == 1) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.8,
          children: cards,
        );
      },
    );
  }

  List<Widget> _buildOverviewCards(BuildContext context, dynamic overview) {
    return [
      _SummaryCard(
        title: 'Total Proposals',
        value: _readValue(overview, 'totalProposals'),
        icon: Icons.description_outlined,
      ),
      _SummaryCard(
        title: 'Pending Review',
        value: _readValue(overview, 'pendingReview'),
        icon: Icons.rate_review_outlined,
      ),
      _SummaryCard(
        title: 'Approved',
        value: _readValue(overview, 'approvedProposals'),
        icon: Icons.check_circle_outline,
      ),
      _SummaryCard(
        title: 'Active Offerings',
        value: _readValue(overview, 'activeOfferings'),
        icon: Icons.token_outlined,
      ),
    ];
  }

  String _readValue(dynamic object, String property) {
    try {
      switch (property) {
        case 'totalProposals':
          return object.totalProposals?.toString() ?? '0';

        case 'pendingReview':
          return object.pendingReview?.toString() ?? '0';

        case 'approvedProposals':
          return object.approvedProposals?.toString() ?? '0';

        case 'activeOfferings':
          return object.activeOfferings?.toString() ?? '0';

        default:
          return '0';
      }
    } catch (_) {
      return '0';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FILTER BAR
// ============================================================

class _TokenizationFilterBar extends StatelessWidget {
  const _TokenizationFilterBar({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Filter proposals:',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String?>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'draft',
                    child: Text('Draft'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'pending_review',
                    child: Text('Pending Review'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'changes_required',
                    child: Text('Changes Required'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'approved',
                    child: Text('Approved'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'rejected',
                    child: Text('Rejected'),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            if (selectedStatus != null)
              OutlinedButton.icon(
                onPressed: () => onStatusChanged(null),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filter'),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAGE HEADER
// ============================================================

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onCreateProposal});

  final VoidCallback onCreateProposal;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tokenization Management',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage tokenization proposals, reviews, assignments, and marketplace offerings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: onCreateProposal,
          icon: const Icon(Icons.add),
          label: const Text('New Proposal'),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PROPOSALS
// ============================================================

class _ProposalList extends StatelessWidget {
  const _ProposalList({required this.proposals});

  final List<TokenizationProposalModel> proposals;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: proposals
            .map((proposal) => _ProposalListItem(proposal: proposal))
            .toList(),
      ),
    );
  }
}

class _ProposalListItem extends StatelessWidget {
  const _ProposalListItem({required this.proposal});

  final TokenizationProposalModel proposal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TokenizationProposalPage(proposalId: proposal.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.description_outlined)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposal.proposalReference,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(proposal.proposedTokenName ?? 'Tokenization Proposal'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            TokenizationStatusBadge(status: proposal.status),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OFFERINGS
// ============================================================

class _OfferingList extends StatelessWidget {
  const _OfferingList({required this.offerings});

  final List<TokenOfferingModel> offerings;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: offerings
            .map((offering) => _OfferingListItem(offering: offering))
            .toList(),
      ),
    );
  }
}

class _OfferingListItem extends StatelessWidget {
  const _OfferingListItem({required this.offering});

  final TokenOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TokenOfferingPage(offeringId: offering.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.token_outlined)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering.offeringReference,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(offering.tokenName ?? 'Token Offering'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            TokenizationStatusBadge(status: offering.status),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ASSIGNMENTS
// ============================================================

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({required this.assignments});

  final List<dynamic> assignments;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: assignments
            .map(
              (assignment) => ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.assignment_outlined),
                ),
                title: Text(
                  _assignmentValue(
                    assignment,
                    'assignmentReference',
                    'Tokenization Assignment',
                  ),
                ),
                subtitle: Text(
                  _assignmentValue(assignment, 'status', 'Assigned'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _assignmentValue(dynamic assignment, String field, String fallback) {
    try {
      if (field == 'assignmentReference') {
        return assignment.assignmentReference?.toString() ?? fallback;
      }

      if (field == 'status') {
        return assignment.status?.toString() ?? fallback;
      }
    } catch (_) {
      return fallback;
    }

    return fallback;
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
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
              'Unable to load tokenization data.',
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
