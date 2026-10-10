import 'package:flutter/material.dart';

import '../../data/models/admin_staff_overview_model.dart';

class StaffOverviewCards extends StatelessWidget {
  const StaffOverviewCards({super.key, required this.overview});

  final AdminStaffOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _OverviewItem(
        title: 'Total Staff',
        value: overview.totalStaff,
        icon: Icons.groups_outlined,
        color: const Color(0xFF2563EB),
        background: const Color(0xFFEFF6FF),
      ),
      _OverviewItem(
        title: 'Active Staff',
        value: overview.activeStaff,
        icon: Icons.verified_user_outlined,
        color: const Color(0xFF15803D),
        background: const Color(0xFFF0FDF4),
      ),
      _OverviewItem(
        title: 'Suspended',
        value: overview.suspendedStaff,
        icon: Icons.pause_circle_outline,
        color: const Color(0xFFB45309),
        background: const Color(0xFFFFFBEB),
      ),
      _OverviewItem(
        title: 'Locked Accounts',
        value: overview.lockedStaff,
        icon: Icons.lock_outline,
        color: const Color(0xFFDC2626),
        background: const Color(0xFFFEF2F2),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 650
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            return _OverviewCard(item: cards[index]);
          },
        );
      },
    );
  }
}

class _OverviewItem {
  const _OverviewItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.item});

  final _OverviewItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 23),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.value.toString(),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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
