import 'package:flutter/material.dart';

import '../../data/models/admin_content_model.dart';

class ContentOverviewCards extends StatelessWidget {
  const ContentOverviewCards({super.key, required this.overview});

  final AdminContentOverview overview;

  static const Color _primaryRed = Color(0xFFD32F2F);
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _warningOrange = Color(0xFFEF6C00);

  @override
  Widget build(BuildContext context) {
    final cards = <_OverviewCardData>[
      _OverviewCardData(
        title: 'Total Content',
        value: overview.total,
        subtitle: 'All content records',
        icon: Icons.library_books_outlined,
        color: _primaryBlue,
      ),
      _OverviewCardData(
        title: 'Drafts',
        value: overview.drafts,
        subtitle: 'Awaiting publication',
        icon: Icons.edit_note_outlined,
        color: _warningOrange,
      ),
      _OverviewCardData(
        title: 'Published',
        value: overview.published,
        subtitle: 'Available to users',
        icon: Icons.check_circle_outline,
        color: _successGreen,
      ),
      _OverviewCardData(
        title: 'Archived',
        value: overview.archived,
        subtitle: 'No longer active',
        icon: Icons.archive_outlined,
        color: _primaryRed,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;

        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth >= 1100
            ? 4
            : availableWidth >= 650
            ? 2
            : 1;

        final cardWidth =
            (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: cardWidth,
              child: _OverviewCard(data: card),
            );
          }).toList(),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data});

  final _OverviewCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 23),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: data.color.withValues(alpha: 0.75),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF687386),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8791A2)),
          ),
        ],
      ),
    );
  }
}

class _OverviewCardData {
  const _OverviewCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
}
