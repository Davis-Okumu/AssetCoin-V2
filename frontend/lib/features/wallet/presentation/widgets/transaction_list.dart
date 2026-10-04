import 'package:flutter/material.dart';

import '../../domain/wallet_transaction.dart';
import 'transaction_tile.dart';

class TransactionList extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final ValueChanged<WalletTransaction>? onTransactionTap;
  final int? maxItems;

  const TransactionList({
    super.key,
    required this.transactions,
    this.onTransactionTap,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final displayedTransactions = maxItems == null
        ? transactions
        : transactions.take(maxItems!).toList();

    if (displayedTransactions.isEmpty) {
      return _EmptyTransactions();
    }

    return Column(
      children: [
        for (int index = 0;
            index < displayedTransactions.length;
            index++) ...[
          TransactionTile(
            transaction: displayedTransactions[index],
            onTap: onTransactionTap == null
                ? null
                : () => onTransactionTap!(
                      displayedTransactions[index],
                    ),
          ),
          if (index < displayedTransactions.length - 1)
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(
                    alpha: 0.10,
                  ),
            ),
        ],
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: theme.colorScheme.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your wallet activity will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.60,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}