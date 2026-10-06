import 'package:flutter/material.dart';

import '../../data/models/admin_kyc_stats.dart';

class KycStatsCards extends StatelessWidget {
  const KycStatsCards({super.key, required this.stats});

  final AdminKycStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width >= 1200
            ? 6
            : width >= 850
            ? 3
            : width >= 550
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.55,
          children: [
            _KycStatCard(
              title: 'Total',
              value: stats.total,
              icon: Icons.assignment_outlined,
            ),
            _KycStatCard(
              title: 'Pending',
              value: stats.pending,
              icon: Icons.pending_actions_outlined,
            ),
            _KycStatCard(
              title: 'Under Review',
              value: stats.underReview,
              icon: Icons.rate_review_outlined,
            ),
            _KycStatCard(
              title: 'Changes Required',
              value: stats.changesRequired,
              icon: Icons.edit_note_outlined,
            ),
            _KycStatCard(
              title: 'Verified',
              value: stats.verified,
              icon: Icons.verified_outlined,
            ),
            _KycStatCard(
              title: 'Rejected',
              value: stats.rejected,
              icon: Icons.cancel_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _KycStatCard extends StatelessWidget {
  const _KycStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
