import 'package:flutter/material.dart';

import '../../data/models/admin_ledger_overview_model.dart';

class LedgerSummaryCards extends StatelessWidget {
  const LedgerSummaryCards({super.key, required this.summary});

  final AdminLedgerSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final cards = <_LedgerSummaryItem>[
      _LedgerSummaryItem(
        title: 'Total entries',
        value: _number(summary.totalEntries),
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF2563EB),
      ),
      _LedgerSummaryItem(
        title: 'Credit entries',
        value: _number(summary.creditEntries),
        icon: Icons.south_west_rounded,
        color: const Color(0xFF16803D),
      ),
      _LedgerSummaryItem(
        title: 'Debit entries',
        value: _number(summary.debitEntries),
        icon: Icons.north_east_rounded,
        color: const Color(0xFFDC2626),
      ),
      _LedgerSummaryItem(
        title: 'Fiat entries',
        value: _number(summary.fiatEntries),
        icon: Icons.payments_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _LedgerSummaryItem(
        title: 'Token entries',
        value: _number(summary.tokenEntries),
        icon: Icons.token_outlined,
        color: const Color(0xFF0F766E),
      ),
      _LedgerSummaryItem(
        title: 'Missing entry hashes',
        value: _number(summary.entriesWithoutHash),
        icon: Icons.fingerprint,
        color: const Color(0xFFB45309),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 3
            : constraints.maxWidth >= 650
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 104,
          ),
          itemBuilder: (context, index) {
            final item = cards[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _number(int value) => value.toString();
}

class _LedgerSummaryItem {
  const _LedgerSummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
