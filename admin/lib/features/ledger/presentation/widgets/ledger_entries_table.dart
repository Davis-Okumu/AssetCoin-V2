import 'package:flutter/material.dart';

import '../../data/models/admin_ledger_entry_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';

class LedgerEntriesTable extends StatelessWidget {
  const LedgerEntriesTable({
    super.key,
    required this.result,
    required this.onOpen,
    required this.onPreviousPage,
    required this.onNextPage,
    this.isLoading = false,
  });

  final AdminLedgerPaginatedResult<AdminLedgerEntryModel> result;
  final ValueChanged<AdminLedgerEntryModel> onOpen;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'Ledger entries',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${result.total} record(s)',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (result.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No ledger entries match your filters.'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: WidgetStatePropertyAll(
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                ),
                columns: const [
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Entry type')),
                  DataColumn(label: Text('Asset type')),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text('Currency')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('')),
                ],
                rows: result.items.map((entry) {
                  final isCredit = entry.isCredit;
                  final typeColor = isCredit
                      ? const Color(0xFF16803D)
                      : const Color(0xFFDC2626);

                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            entry.entryReference.isEmpty
                                ? '#${entry.id}'
                                : entry.entryReference,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(
                            entry.customerName.isEmpty
                                ? 'Unknown customer'
                                : entry.customerName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        _TypeLabel(
                          text: entry.entryTypeLabel,
                          color: typeColor,
                        ),
                      ),
                      DataCell(Text(entry.assetTypeLabel)),
                      DataCell(
                        Text(
                          entry.amount,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(entry.currency)),
                      DataCell(Text(_formatDate(entry.createdAt))),
                      DataCell(
                        TextButton.icon(
                          onPressed: () => onOpen(entry),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Details'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'Page ${result.page} of '
                  '${result.totalPages == 0 ? 1 : result.totalPages}',
                  style: theme.textTheme.bodySmall,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: isLoading || !result.hasPreviousPage
                          ? null
                          : onPreviousPage,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: isLoading || !result.hasNextPage
                          ? null
                          : onNextPage,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final local = date.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${local.year}-${twoDigits(local.month)}-'
        '${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
