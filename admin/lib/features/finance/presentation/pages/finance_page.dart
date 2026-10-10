import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/finance_overview_controller.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_summary_cards.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(financeOverviewControllerProvider);
    final controller = ref.read(financeOverviewControllerProvider.notifier);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page heading and refresh action.
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Finance Overview',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh finance overview',
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor wallet balances and financial activity across AssetCoin.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Finance overview statistics.
            overview.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => FinanceEmptyState(
                title: 'Unable to load finance overview',
                message: error.toString(),
                icon: Icons.cloud_off_outlined,
                actionLabel: 'Retry',
                onAction: controller.refresh,
              ),
              data: (data) {
                final items = <FinanceSummaryItem>[
                  FinanceSummaryItem(
                    title: 'Total Wallets',
                    value: data.totalWallets.toString(),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  FinanceSummaryItem(
                    title: 'Wallet Balances',
                    value: 'KES ${data.totalWalletBalance.toStringAsFixed(2)}',
                    icon: Icons.account_balance_outlined,
                    color: const Color(0xFF2563EB),
                  ),
                  FinanceSummaryItem(
                    title: 'Total Deposits',
                    value: 'KES ${data.totalDeposits.toStringAsFixed(2)}',
                    icon: Icons.south_west,
                    color: const Color(0xFF16834A),
                  ),
                  FinanceSummaryItem(
                    title: 'Total Withdrawals',
                    value: 'KES ${data.totalWithdrawals.toStringAsFixed(2)}',
                    icon: Icons.north_east,
                    color: const Color(0xFFCC3333),
                  ),
                  FinanceSummaryItem(
                    title: 'Total Transactions',
                    value: data.totalTransactions.toString(),
                    icon: Icons.receipt_long_outlined,
                  ),
                ];

                return FinanceSummaryCards(items: items);
              },
            ),

            const SizedBox(height: 28),

            // Finance management navigation.
            Text(
              'Finance Management',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;

                final actions = [
                  _FinanceAction(
                    title: 'Customer Wallets',
                    description: 'Inspect wallet balances and account status.',
                    icon: Icons.account_balance_wallet_outlined,
                    route: '/finance/wallets',
                  ),
                  _FinanceAction(
                    title: 'Transactions',
                    description: 'Review deposits, withdrawals and other wallet activity.',
                    icon: Icons.receipt_long_outlined,
                    route: '/finance/transactions',
                  ),
                  _FinanceAction(
                    title: 'Deposits',
                    description: 'Review recorded incoming payments.',
                    icon: Icons.south_west,
                    route: '/finance/deposits',
                  ),
                  _FinanceAction(
                    title: 'Withdrawals',
                    description: 'Review recorded withdrawal requests.',
                    icon: Icons.north_east,
                    route: '/finance/withdrawals',
                  ),
                  _FinanceAction(
                    title: 'Reconciliation',
                    description:
                        'Review reconciliation records and differences.',
                    icon: Icons.fact_check_outlined,
                    route: '/finance/reconciliation',
                  ),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 145,
                  ),
                  itemBuilder: (context, index) {
                    final action = actions[index];

                    return Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.go(action.route),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                action.icon,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      action.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      action.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceAction {
  const _FinanceAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
}
