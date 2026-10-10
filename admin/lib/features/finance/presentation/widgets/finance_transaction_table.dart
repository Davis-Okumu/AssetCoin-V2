import 'package:flutter/material.dart';

import '../../data/models/finance_transaction_model.dart';
import 'finance_empty_state.dart';
import 'finance_status_badge.dart';

class FinanceTransactionTable extends StatelessWidget {
  const FinanceTransactionTable({super.key, required this.items, this.onOpen});

  final List<FinanceTransactionModel> items;
  final ValueChanged<FinanceTransactionModel>? onOpen;

  String _formatAmount(num amount, String currency) {
    final formatted = amount.abs().toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = parts[0];
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    final sign = amount < 0 ? '-' : '';
    return '$sign$currency ${buffer.toString()}.${parts[1]}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const FinanceEmptyState(
        title: 'No transactions found',
        message: 'Transactions will appear here when records are available.',
        icon: Icons.receipt_long_outlined,
      );
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          columns: const [
            DataColumn(label: Text('Reference')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('')),
          ],
          rows: items.map((item) {
            final transaction = item.transaction;

            return DataRow(
              cells: [
                DataCell(SelectableText(transaction.reference)),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      item.customerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(transaction.type)),
                DataCell(
                  Text(
                    _formatAmount(transaction.amount, transaction.currency),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(FinanceStatusBadge(status: transaction.status)),
                DataCell(Text(_formatDate(transaction.createdAt))),
                DataCell(
                  onOpen == null
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'View transaction',
                          onPressed: () => onOpen!(item),
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
