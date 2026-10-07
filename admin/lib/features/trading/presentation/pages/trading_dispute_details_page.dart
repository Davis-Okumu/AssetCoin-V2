import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_dispute_model.dart';
import '../controllers/admin_trading_dispute_details_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingDisputeDetailsPage extends ConsumerWidget {
  const TradingDisputeDetailsPage({super.key, required this.disputeId});

  final int disputeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      adminTradingDisputeDetailsControllerProvider(disputeId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(
                          adminTradingDisputeDetailsControllerProvider(
                            disputeId,
                          ).notifier,
                        )
                        .refresh();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          message: error.toString(),
          onRetry: () {
            ref
                .read(
                  adminTradingDisputeDetailsControllerProvider(disputeId)
                      .notifier,
                )
                .refresh();
          },
        ),
        data: (dispute) => _DisputeDetailsContent(
          dispute: dispute,
          controller: ref.read(
            adminTradingDisputeDetailsControllerProvider(disputeId).notifier,
          ),
        ),
      ),
    );
  }
}

class _DisputeDetailsContent extends StatelessWidget {
  const _DisputeDetailsContent({
    required this.dispute,
    required this.controller,
  });

  final AdminTradingDisputeModel dispute;
  final AdminTradingDisputeDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(dispute: dispute),
              const SizedBox(height: 20),
              _DisputeOverviewSection(dispute: dispute),
              const SizedBox(height: 20),
              _ParticipantsSection(dispute: dispute),
              const SizedBox(height: 20),
              _RelatedRecordsSection(dispute: dispute),
              const SizedBox(height: 20),
              _DescriptionSection(dispute: dispute),
              const SizedBox(height: 20),
              _ResolutionSection(dispute: dispute),
              const SizedBox(height: 20),
              _TimelineSection(dispute: dispute),
              const SizedBox(height: 24),
              _ActionBar(dispute: dispute, controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.gavel_outlined,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _display(dispute.disputeReference),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dispute.disputeTypeLabel,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TradingStatusBadge(status: _display(dispute.status)),
                      TradingStatusBadge(status: _display(dispute.priority)),
                    ],
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

class _DisputeOverviewSection extends StatelessWidget {
  const _DisputeOverviewSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Dispute Overview',
      icon: Icons.info_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Dispute ID', value: '#${dispute.id}'),
            _DetailItem(
              label: 'Reference',
              value: _display(dispute.disputeReference),
            ),
            _DetailItem(label: 'Type', value: dispute.disputeTypeLabel),
            _DetailItem(label: 'Status', value: dispute.statusLabel),
            _DetailItem(label: 'Priority', value: dispute.priorityLabel),
            _DetailItem(label: 'Reason', value: _display(dispute.reason)),
            _DetailItem(label: 'Assigned To', value: dispute.assignedToName),
          ],
        ),
      ],
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Participants',
      icon: Icons.people_outline,
      children: [
        _ParticipantCard(
          title: 'Raised By',
          name: dispute.raisedByName,
          email: dispute.raisedByEmail,
          phone: dispute.raisedByPhone,
          id: dispute.raisedBy,
        ),
        const SizedBox(height: 16),
        _ParticipantCard(
          title: 'Against User',
          name: dispute.againstUserName,
          email: dispute.againstUserEmail,
          phone: null,
          id: dispute.againstUserId,
        ),
        const SizedBox(height: 16),
        _ParticipantCard(
          title: 'Assigned Officer',
          name: dispute.assignedToName,
          email: null,
          phone: null,
          id: dispute.assignedTo,
        ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.title,
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
  });

  final String title;
  final String name;
  final String? email;
  final String? phone;
  final int? id;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 16,
        children: [
          _MiniDetail(label: title, value: name),
          _MiniDetail(label: 'User ID', value: _nullableInt(id)),
          if (email != null)
            _MiniDetail(label: 'Email', value: _display(email)),
          if (phone != null)
            _MiniDetail(label: 'Phone', value: _display(phone)),
        ],
      ),
    );
  }
}

class _RelatedRecordsSection extends StatelessWidget {
  const _RelatedRecordsSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Related Trading Records',
      icon: Icons.link_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(
              label: 'Transaction ID',
              value: _nullableInt(dispute.transactionId),
            ),
            _DetailItem(
              label: 'Order ID',
              value: _nullableInt(dispute.orderId),
            ),
            _DetailItem(
              label: 'Listing ID',
              value: _nullableInt(dispute.listingId),
            ),
          ],
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        dispute.description != null && dispute.description!.trim().isNotEmpty;

    return _SectionCard(
      title: 'Dispute Details',
      icon: Icons.description_outlined,
      children: [
        _DetailItem(label: 'Reason', value: _display(dispute.reason)),
        const SizedBox(height: 18),
        Text(
          'Description',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          hasDescription
              ? dispute.description!
              : 'No additional description provided.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _ResolutionSection extends StatelessWidget {
  const _ResolutionSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    final hasNotes =
        dispute.resolutionNotes != null &&
        dispute.resolutionNotes!.trim().isNotEmpty;

    return _SectionCard(
      title: 'Resolution',
      icon: Icons.task_alt_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Resolution Status', value: dispute.statusLabel),
            _DetailItem(
              label: 'Resolved By',
              value: _nullableInt(dispute.resolvedBy),
            ),
            _DetailItem(
              label: 'Resolved At',
              value: _formatDate(dispute.resolvedAt),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Resolution Notes',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          hasNotes ? dispute.resolutionNotes! : 'No resolution notes recorded.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.dispute});

  final AdminTradingDisputeModel dispute;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline',
      icon: Icons.schedule_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(
              label: 'Created',
              value: _formatDate(dispute.createdAt),
            ),
            _DetailItem(
              label: 'Last Updated',
              value: _formatDate(dispute.updatedAt),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.dispute, required this.controller});

  final AdminTradingDisputeModel dispute;
  final AdminTradingDisputeDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final canUpdate = !dispute.isFinalized;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showUpdateDialog(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Update Dispute'),
            ),
            OutlinedButton.icon(
              onPressed: canUpdate ? () => _showAssignDialog(context) : null,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Assign Officer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    String status = dispute.status;
    String priority = dispute.priority;
    final notesController = TextEditingController(
      text: dispute.resolutionNotes ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Dispute'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'open', child: Text('Open')),
                        DropdownMenuItem(
                          value: 'under_review',
                          child: Text('Under Review'),
                        ),
                        DropdownMenuItem(
                          value: 'awaiting_information',
                          child: Text('Awaiting Information'),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text('Resolved'),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text('Rejected'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Closed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(
                          value: 'critical',
                          child: Text('Critical'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            priority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Resolution Notes',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await controller.updateDispute(
                        status: status,
                        priority: priority,
                        resolutionNotes: notesController.text.trim(),
                      );

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    } catch (error) {
                      if (!dialogContext.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    notesController.dispose();

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispute updated successfully.')),
      );
    }
  }

  Future<void> _showAssignDialog(BuildContext context) async {
    final idController = TextEditingController();

    final assignedId = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Assign Dispute'),
          content: TextField(
            controller: idController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Admin Staff ID',
              hintText: 'Enter admin staff ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final id = int.tryParse(idController.text.trim());

                if (id != null && id > 0) {
                  Navigator.of(dialogContext).pop(id);
                }
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );

    idController.dispose();

    if (assignedId == null || !context.mounted) {
      return;
    }

    try {
      await controller.assign(assignedTo: assignedId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute assigned successfully.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 18,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              'Unable to load dispute',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
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

String _display(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '—';
  }

  return value;
}

String _nullableInt(int? value) {
  return value?.toString() ?? '—';
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  return '${local.year}-'
      '${twoDigits(local.month)}-'
      '${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)}';
}
