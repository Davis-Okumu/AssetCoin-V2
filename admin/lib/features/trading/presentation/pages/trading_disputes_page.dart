import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_dispute_model.dart';
import '../../data/repositories/admin_trading_repository.dart';
import '../controllers/admin_trading_disputes_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingDisputesPage extends ConsumerStatefulWidget {
  const TradingDisputesPage({super.key});

  @override
  ConsumerState<TradingDisputesPage> createState() =>
      _TradingDisputesPageState();
}

class _TradingDisputesPageState extends ConsumerState<TradingDisputesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTradingDisputesControllerProvider);
    final controller = ref.read(
      adminTradingDisputesControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Disputes'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading ? null : controller.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _ErrorView(message: error.toString(), onRetry: controller.refresh),
        data: (result) {
          _syncSearchController(controller);

          return _DisputesContent(
            result: result,
            controller: controller,
            searchController: _searchController,
          );
        },
      ),
    );
  }

  void _syncSearchController(AdminTradingDisputesController controller) {
    final value = controller.searchQuery ?? '';

    if (_searchController.text != value) {
      _searchController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }
}

class _DisputesContent extends StatelessWidget {
  const _DisputesContent({
    required this.result,
    required this.controller,
    required this.searchController,
  });

  final AdminTradingPaginatedResult<AdminTradingDisputeModel> result;
  final AdminTradingDisputesController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final hasFilters = _hasFilters();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryHeader(
                total: result.total,
                open: result.items.where((item) => item.isOpen).length,
                critical: result.items.where((item) => item.isCritical).length,
              ),
              const SizedBox(height: 20),
              _FilterBar(
                searchController: searchController,
                status: controller.statusFilter,
                priority: controller.priorityFilter,
                onSearch: controller.search,
                onStatusChanged: controller.setStatus,
                onPriorityChanged: controller.setPriority,
                onClear: controller.clearFilters,
                hasFilters: hasFilters,
              ),
              const SizedBox(height: 20),
              if (result.isEmpty)
                const _EmptyView()
              else
                _DisputesTable(
                  items: result.items,
                  onOpen: (dispute) {
                    _showDisputePreview(context, dispute);
                  },
                ),
              const SizedBox(height: 20),
              _Pagination(
                result: result,
                onPrevious: result.hasPreviousPage
                    ? controller.previousPage
                    : null,
                onNext: result.hasNextPage ? controller.nextPage : null,
                onPageSizeChanged: controller.setPageSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFilters() {
    final search = controller.searchQuery;

    return (search?.trim().isNotEmpty ?? false) ||
        controller.statusFilter != null ||
        controller.priorityFilter != null;
  }

  void _showDisputePreview(
    BuildContext context,
    AdminTradingDisputeModel dispute,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_display(dispute.disputeReference)),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TradingStatusBadge(status: _display(dispute.status)),
                      const SizedBox(width: 8),
                      TradingStatusBadge(status: _display(dispute.priority)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _PreviewRow(label: 'Type', value: dispute.disputeTypeLabel),
                  _PreviewRow(label: 'Reason', value: _display(dispute.reason)),
                  _PreviewRow(label: 'Raised By', value: dispute.raisedByName),
                  _PreviewRow(label: 'Against', value: dispute.againstUserName),
                  _PreviewRow(
                    label: 'Assigned To',
                    value: dispute.assignedToName,
                  ),
                  _PreviewRow(
                    label: 'Transaction',
                    value: _nullableInt(dispute.transactionId),
                  ),
                  _PreviewRow(
                    label: 'Order',
                    value: _nullableInt(dispute.orderId),
                  ),
                  _PreviewRow(
                    label: 'Listing',
                    value: _nullableInt(dispute.listingId),
                  ),
                  _PreviewRow(
                    label: 'Created',
                    value: _formatDate(dispute.createdAt),
                  ),
                  if (dispute.description != null &&
                      dispute.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(dispute.description!),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.total,
    required this.open,
    required this.critical,
  });

  final int total;
  final int open;
  final int critical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Trading Disputes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _SummaryChip(
          icon: Icons.list_alt_outlined,
          label: 'Total',
          value: total.toString(),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.pending_actions_outlined,
          label: 'Open',
          value: open.toString(),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.priority_high_outlined,
          label: 'Critical',
          value: critical.toString(),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.status,
    required this.priority,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onClear,
    required this.hasFilters,
  });

  final TextEditingController searchController;
  final String? status;
  final String? priority;
  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  final VoidCallback onClear;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: searchController,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search disputes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearch(null);
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(
                    value: 'under_review',
                    child: Text('Under Review'),
                  ),
                  DropdownMenuItem(
                    value: 'awaiting_information',
                    child: Text('Awaiting Info'),
                  ),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'critical', child: Text('Critical')),
                ],
                onChanged: onPriorityChanged,
              ),
            ),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DisputesTable extends StatelessWidget {
  const _DisputesTable({required this.items, required this.onOpen});

  final List<AdminTradingDisputeModel> items;
  final ValueChanged<AdminTradingDisputeModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Reference')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Reason')),
            DataColumn(label: Text('Raised By')),
            DataColumn(label: Text('Against')),
            DataColumn(label: Text('Assigned To')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('')),
          ],
          rows: items.map((dispute) {
            return DataRow(
              cells: [
                DataCell(Text(_display(dispute.disputeReference))),
                DataCell(Text(dispute.disputeTypeLabel)),
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Text(
                      _display(dispute.reason),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(dispute.raisedByName)),
                DataCell(Text(dispute.againstUserName)),
                DataCell(Text(dispute.assignedToName)),
                DataCell(
                  TradingStatusBadge(status: _display(dispute.priority)),
                ),
                DataCell(TradingStatusBadge(status: _display(dispute.status))),
                DataCell(Text(_formatDate(dispute.createdAt))),
                DataCell(
                  IconButton(
                    tooltip: 'Open',
                    onPressed: () => onOpen(dispute),
                    icon: const Icon(Icons.open_in_new_outlined),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.result,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  final AdminTradingPaginatedResult<AdminTradingDisputeModel> result;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final start = result.total == 0
        ? 0
        : ((result.page - 1) * result.limit) + 1;

    final end = result.total == 0 ? 0 : (start + result.items.length - 1);

    return Row(
      children: [
        Text('$start–$end of ${result.total}'),
        const Spacer(),
        const Text('Rows:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: result.limit,
          items: const [
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 20, child: Text('20')),
            DropdownMenuItem(value: 50, child: Text('50')),
            DropdownMenuItem(value: 100, child: Text('100')),
          ],
          onChanged: (value) {
            if (value != null) {
              onPageSizeChanged(value);
            }
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Previous page',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          'Page ${result.page} of ${result.totalPages == 0 ? 1 : result.totalPages}',
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.gavel_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No trading disputes found',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
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
              'Unable to load trading disputes',
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
