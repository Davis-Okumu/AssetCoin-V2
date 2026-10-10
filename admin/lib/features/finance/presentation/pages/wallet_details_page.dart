import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wallet_controller.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_stat_card.dart';
import '../widgets/finance_status_badge.dart';
import '../widgets/wallet_transactions_table.dart';

class WalletDetailsPage extends ConsumerWidget {
  const WalletDetailsPage({super.key, required this.walletId});

  final int walletId;

  String _money(num amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletDetailsControllerProvider(walletId));
    final transactionsState = ref.watch(
      walletTransactionsControllerProvider(walletId),
    );

    final walletController = ref.read(
      walletDetailsControllerProvider(walletId).notifier,
    );
    final transactionsController = ref.read(
      walletTransactionsControllerProvider(walletId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet #$walletId'),
        actions: [
          IconButton(
            tooltip: 'Refresh wallet',
            onPressed: walletController.refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Refresh transactions',
            onPressed: transactionsController.refresh,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: walletState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: FinanceEmptyState(
            title: 'Unable to load wallet',
            message: error.toString(),
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Retry',
            onAction: walletController.refresh,
          ),
        ),
        data: (wallet) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Details',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  wallet.walletAddress.isEmpty
                      ? 'Wallet ID: ${wallet.id}'
                      : wallet.walletAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Wallet status: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FinanceStatusBadge(status: wallet.status),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850
                        ? 3
                        : constraints.maxWidth >= 500
                        ? 2
                        : 1;

                    final cards = [
                      FinanceStatCard(
                        title: 'Available Balance',
                        value: _money(wallet.availableBalance, wallet.currency),
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF16834A),
                      ),
                      FinanceStatCard(
                        title: 'Locked Balance',
                        value: _money(wallet.lockedBalance, wallet.currency),
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFF996500),
                      ),
                      FinanceStatCard(
                        title: 'Total Balance',
                        value: _money(wallet.totalBalance, wallet.currency),
                        icon: Icons.account_balance_outlined,
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ];

                    return GridView.count(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: constraints.maxWidth < 500 ? 2.2 : 1.6,
                      children: cards,
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Transaction History',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                transactionsState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => FinanceEmptyState(
                    title: 'Unable to load transactions',
                    message: error.toString(),
                    icon: Icons.cloud_off_outlined,
                    actionLabel: 'Retry',
                    onAction: transactionsController.refresh,
                  ),
                  data: (transactions) =>
                      WalletTransactionsTable(items: transactions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
