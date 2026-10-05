import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, required this.transactions});
  final List<RecentTransaction> transactions;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF2563EB),
                size: 21,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent transactions available.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 62,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
                columns: const [
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                ],
                rows: transactions
                    .take(10)
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(
                            Text(item.reference.isEmpty ? '—' : item.reference),
                          ),
                          DataCell(
                            Text(item.userName.isEmpty ? '—' : item.userName),
                          ),
                          DataCell(Text(item.type)),
                          DataCell(
                            Text(
                              '${item.currency} '
                              '${_money(item.amount)}',
                            ),
                          ),
                          DataCell(_StatusBadge(item.status)),
                          DataCell(Text(_date(item.createdAt))),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  static String _money(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
  }

  static String _date(DateTime? date) {
    if (date == null) {
      return '—';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color =
        normalized.contains('complete') ||
            normalized.contains('success') ||
            normalized.contains('approved')
        ? const Color(0xFF16A34A)
        : normalized.contains('failed') || normalized.contains('rejected')
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
