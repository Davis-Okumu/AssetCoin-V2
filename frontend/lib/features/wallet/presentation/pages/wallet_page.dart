import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wallet_controller.dart';
import '../widgets/token_balance_card.dart';
import '../widgets/total_asset_value_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/wallet_action_buttons.dart';
import '../widgets/wallet_balance_card.dart';
import '../../domain/wallet_transaction_type.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh wallet',
            onPressed: () {
              ref
                  .read(walletControllerProvider.notifier)
                  .refresh();
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: walletState.when(
        loading: () => const _WalletLoading(),
        error: (error, stackTrace) => _WalletError(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(walletControllerProvider);
          },
        ),
        data: (state) {
          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(walletControllerProvider.notifier)
                  .refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                32,
              ),
              children: [
                WalletBalanceCard(
                  wallet: state.summary,
                ),

                const SizedBox(height: 16),

                TotalAssetValueCard(
                  wallet: state.summary,
                ),

                const SizedBox(height: 16),

                TokenBalanceCard(
                  holdings: state.summary.tokenHoldings,
                  currency: state.summary.currency,
                ),

                const SizedBox(height: 20),

                WalletActionButtons(
                  onDeposit: () {
                    _showComingSoon(
                      context,
                      'Deposit',
                    );
                  },
                  onWithdraw: () {
                    _showComingSoon(
                      context,
                      'Withdraw',
                    );
                  },
                  onConvert: () {
                    _showComingSoon(
                      context,
                      'Convert',
                    );
                  },
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (state.transactions.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _showComingSoon(
                            context,
                            'Transaction History',
                          );
                        },
                        child: const Text(
                          'View All',
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                TransactionList(
                  transactions: state.transactions,
                  maxItems: 4,
                  onTransactionTap: (transaction) {
                    _showComingSoon(
                      context,
                      transaction
                          .transactionType
                          .displayName,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$feature flow coming next.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _WalletLoading extends StatelessWidget {
  const _WalletLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _WalletError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WalletError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 52,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load your wallet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}