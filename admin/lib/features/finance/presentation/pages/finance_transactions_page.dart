import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/finance_transactions_controller.dart';
import '../widgets/finance_back_button.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_filter_bar.dart';
import '../widgets/finance_transaction_table.dart';

class FinanceTransactionsPage extends ConsumerStatefulWidget {
  const FinanceTransactionsPage({super.key});

  @override
  ConsumerState<FinanceTransactionsPage> createState() =>
      _FinanceTransactionsPageState();
}

class _FinanceTransactionsPageState
    extends ConsumerState<FinanceTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(financeTransactionsControllerProvider);
    final controller = ref.read(financeTransactionsControllerProvider.notifier);

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
                    'Wallet Transactions',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh transactions',
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review recorded wallet activity and transaction statuses.',
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
              searchHint: 'Search transaction reference or customer',
              onClear: () {
                _searchController.clear();
                controller.clearFilters();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: transactionsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => FinanceEmptyState(
                  title: 'Unable to load transactions',
                  message: error.toString(),
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Retry',
                  onAction: controller.refresh,
                ),
                data: (_) => FinanceTransactionTable(
                  items: controller.filteredTransactions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
