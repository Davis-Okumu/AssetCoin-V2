import 'package:flutter/material.dart';

import 'finance_stat_card.dart';

class FinanceSummaryItem {
  const FinanceSummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? color;
}

class FinanceSummaryCards extends StatelessWidget {
  const FinanceSummaryCards({
    super.key,
    required this.items,
    this.minimumCardWidth = 220,
  });

  final List<FinanceSummaryItem> items;
  final double minimumCardWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columns = (availableWidth / minimumCardWidth).floor().clamp(
          1,
          items.length,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 155,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return FinanceStatCard(
              title: item.title,
              value: item.value,
              icon: item.icon,
              subtitle: item.subtitle,
              iconColor: item.color,
            );
          },
        );
      },
    );
  }
}
