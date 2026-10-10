import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/finance_withdrawals_controller.dart';
import '../widgets/finance_back_button.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_filter_bar.dart';
import '../widgets/finance_status_badge.dart';

class FinanceWithdrawalsPage extends ConsumerStatefulWidget {
  const FinanceWithdrawalsPage({super.key});

  @override
  ConsumerState<FinanceWithdrawalsPage> createState() =>
      _FinanceWithdrawalsPageState();
}

class _FinanceWithdrawalsPageState
    extends ConsumerState<FinanceWithdrawalsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(num amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _date(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalsState = ref.watch(financeWithdrawalsControllerProvider);
    final controller = ref.read(financeWithdrawalsControllerProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FinanceBackButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Withdrawals',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh withdrawals',
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review recorded outgoing wallet transactions and their statuses.',
            ),
            const SizedBox(height: 20),
            FinanceFilterBar(
              searchController: _searchController,
              onSearchChanged: controller.setSearchQuery,
              status: controller.statusFilter,
              statusOptions: const [
                'all',
                'pending',
                'processing',
                'completed',
                'failed',
                'reversed',
              ],
              onStatusChanged: (value) {
                if (value != null) controller.setStatusFilter(value);
              },
              searchHint: 'Search withdrawal reference or customer',
              onClear: () {
                _searchController.clear();
                controller.clearFilters();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: withdrawalsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => FinanceEmptyState(
                  title: 'Unable to load withdrawals',
                  message: error.toString(),
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Retry',
                  onAction: controller.refresh,
                ),
                data: (_) {
                  final items = controller.filteredWithdrawals;

                  if (items.isEmpty) {
                    return const FinanceEmptyState(
                      title: 'No withdrawals found',
                      message: 'No withdrawals match the current filters or the API returned no records.',
                      icon: Icons.north_east,
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 850),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Reference')),
                            DataColumn(label: Text('Customer')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Date')),
                          ],
                          rows: items.map((withdrawal) {
                            final transaction = withdrawal.transaction;

                            return DataRow(
                              cells: [
                                DataCell(SelectableText(transaction.reference)),
                                DataCell(
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      withdrawal.customerName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _money(
                                      transaction.amount,
                                      transaction.currency,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  FinanceStatusBadge(
                                    status: transaction.status,
                                  ),
                                ),
                                DataCell(Text(_date(transaction.createdAt))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
