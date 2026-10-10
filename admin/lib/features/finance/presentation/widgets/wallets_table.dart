import 'package:flutter/material.dart';

import '../../data/models/finance_wallet_model.dart';
import 'finance_empty_state.dart';
import 'finance_status_badge.dart';

class WalletsTable extends StatelessWidget {
  const WalletsTable({super.key, required this.items, this.onOpen});

  final List<FinanceWalletModel> items;
  final ValueChanged<FinanceWalletModel>? onOpen;

  String _money(num amount, String currency) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final formatted = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        formatted.write(',');
      }

      formatted.write(whole[i]);
    }

    return '$currency ${formatted.toString()}.${parts[1]}';
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
    if (items.isEmpty) {
      return const FinanceEmptyState(
        title: 'No wallets found',
        message: 'Customer wallets will appear here when available.',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1050),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          columns: const [
            DataColumn(label: Text('Wallet ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Wallet Address')),
            DataColumn(label: Text('Available Balance')),
            DataColumn(label: Text('Locked Balance')),
            DataColumn(label: Text('Currency')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('')),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.id.toString())),
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
                DataCell(
                  SizedBox(
                    width: 160,
                    child: SelectableText(
                      item.walletAddress.isEmpty ? '—' : item.walletAddress,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _money(item.availableBalance, item.currency),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(_money(item.lockedBalance, item.currency))),
                DataCell(Text(item.currency)),
                DataCell(FinanceStatusBadge(status: item.status)),
                DataCell(Text(_date(item.createdAt))),
                DataCell(
                  onOpen == null
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'View wallet',
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
