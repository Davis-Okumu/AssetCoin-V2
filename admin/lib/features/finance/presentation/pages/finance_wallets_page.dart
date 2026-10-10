import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/finance_wallets_controller.dart';
import '../widgets/finance_back_button.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_filter_bar.dart';
import '../widgets/wallets_table.dart';
import 'wallet_details_page.dart';

class FinanceWalletsPage extends ConsumerStatefulWidget {
  const FinanceWalletsPage({super.key});

  @override
  ConsumerState<FinanceWalletsPage> createState() => _FinanceWalletsPageState();
}

class _FinanceWalletsPageState extends ConsumerState<FinanceWalletsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsState = ref.watch(financeWalletsControllerProvider);
    final controller = ref.read(financeWalletsControllerProvider.notifier);

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
                    'Customer Wallets',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh wallets',
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review customer wallet balances, currencies and account statuses.',
            ),
            const SizedBox(height: 20),
            FinanceFilterBar(
              searchController: _searchController,
              onSearchChanged: controller.setSearchQuery,
              status: controller.statusFilter,
              statusOptions: const [
                'all',
                'active',
                'pending',
                'suspended',
                'closed',
              ],
              onStatusChanged: (value) {
                if (value != null) controller.setStatusFilter(value);
              },
              searchHint: 'Search customer, wallet address or user ID',
              onClear: () {
                _searchController.clear();
                controller.clearFilters();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: walletsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => FinanceEmptyState(
                  title: 'Unable to load wallets',
                  message: error.toString(),
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Retry',
                  onAction: controller.refresh,
                ),
                data: (_) {
                  final items = controller.filteredWallets;

                  return WalletsTable(
                    items: items,
                    onOpen: (wallet) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              WalletDetailsPage(walletId: wallet.id),
                        ),
                      );
                    },
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
