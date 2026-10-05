import 'package:flutter/material.dart';

class UserSummaryCards extends StatelessWidget {
  const UserSummaryCards({
    super.key,
    required this.totalUsers,
    required this.currentPage,
    required this.totalPages,
    required this.showingCount,
  });

  final int totalUsers;

  final int currentPage;

  final int totalPages;

  final int showingCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1100
            ? 4
            : width >= 700
            ? 2
            : 1;

        const spacing = 16.0;

        final cardWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        final cards = [
          _SummaryCard(
            title: 'Total Users',
            value: '$totalUsers',
            icon: Icons.people_outline,
            subtitle: 'Customer accounts',
          ),
          _SummaryCard(
            title: 'Showing',
            value: '$showingCount',
            icon: Icons.view_list_outlined,
            subtitle: 'Users on this page',
          ),
          _SummaryCard(
            title: 'Current Page',
            value: '$currentPage',
            icon: Icons.layers_outlined,
            subtitle: totalPages == 0 ? 'No pages' : 'of $totalPages pages',
          ),
          const _SummaryCard(
            title: 'Server Search',
            value: 'Active',
            icon: Icons.search_outlined,
            subtitle: 'Search & filters enabled',
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.subtitle,
  });

  final String title;

  final String value;

  final IconData icon;

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
