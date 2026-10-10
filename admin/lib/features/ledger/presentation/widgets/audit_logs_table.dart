import 'package:flutter/material.dart';

import '../../data/models/admin_audit_log_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';

class AuditLogsTable extends StatelessWidget {
  const AuditLogsTable({
    super.key,
    required this.result,
    required this.onOpen,
    required this.onPreviousPage,
    required this.onNextPage,
    this.isLoading = false,
  });

  final AdminLedgerPaginatedResult<AdminAuditLogModel> result;
  final ValueChanged<AdminAuditLogModel> onOpen;
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Audit log records',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text('${result.total} record(s)'),
              ],
            ),
          ),
          const Divider(height: 1),
          if (result.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No audit logs match the current filters.'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('Entity')),
                  DataColumn(label: Text('Entity ID')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('')),
                ],
                rows: result.items.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(Text('#${log.id}')),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            log.actionLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(log.entityTypeLabel)),
                      DataCell(Text(log.entityId ?? '—')),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(
                            log.userName.isEmpty
                                ? 'Unknown user'
                                : log.userName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(_formatDate(log.createdAt))),
                      DataCell(
                        TextButton(
                          onPressed: () => onOpen(log),
                          child: const Text('View details'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
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
    String two(int value) => value.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
