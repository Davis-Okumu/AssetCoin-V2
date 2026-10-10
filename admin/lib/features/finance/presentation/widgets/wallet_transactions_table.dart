import 'package:flutter/material.dart';

import '../../data/models/wallet_transaction_model.dart';
import 'finance_empty_state.dart';
import 'finance_status_badge.dart';

class WalletTransactionsTable extends StatelessWidget {
  const WalletTransactionsTable({super.key, required this.items, this.onOpen});

  final List<WalletTransactionModel> items;
  final ValueChanged<WalletTransactionModel>? onOpen;

  String _amount(num? amount, String currency) {
    if (amount == null) return '—';

    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _date(DateTime? value) {
    if (value == null) return '—';

    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const FinanceEmptyState(
        title: 'No wallet transactions',
        message: 'This wallet does not have any transaction records yet.',
        icon: Icons.receipt_long_outlined,
      );
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1000),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          columns: const [
            DataColumn(label: Text('Reference')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Balance Before')),
            DataColumn(label: Text('Balance After')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('')),
          ],
          rows: items.map((transaction) {
            return DataRow(
              cells: [
                DataCell(SelectableText(transaction.reference)),
                DataCell(Text(transaction.type)),
                DataCell(
                  Text(
                    _amount(transaction.amount, transaction.currency),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    _amount(transaction.balanceBefore, transaction.currency),
                  ),
                ),
                DataCell(
                  Text(_amount(transaction.balanceAfter, transaction.currency)),
                ),
                DataCell(FinanceStatusBadge(status: transaction.status)),
                DataCell(Text(_date(transaction.createdAt))),
                DataCell(
                  onOpen == null
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'View transaction',
                          onPressed: () => onOpen!(transaction),
                          icon: const Icon(Icons.open_in_new, size: 18),
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
