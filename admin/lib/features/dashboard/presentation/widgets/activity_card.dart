import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.assets, required this.kyc});
  final List<RecentAssetActivity> assets;
  final List<RecentKycActivity> kyc;
  @override
  Widget build(BuildContext context) {
    final activities = <Widget>[
      ...assets
          .take(4)
          .map(
            (item) => _ActivityRow(
              icon: Icons.inventory_2_outlined,
              title: item.name,
              subtitle: [
                item.assetType,
                if (item.ownerName.isNotEmpty) item.ownerName,
              ].join(' • '),
              status: item.status,
              time: _formatDate(item.createdAt),
            ),
          ),
      ...kyc
          .take(4)
          .map(
            (item) => _ActivityRow(
              icon: Icons.verified_user_outlined,
              title: item.userName,
              subtitle: 'KYC review',
              status: item.status,
              time: _formatDate(item.reviewedAt ?? item.submittedAt),
            ),
          ),
    ];
    return _DashboardCard(
      title: 'Recent Activity',
      icon: Icons.bolt_rounded,
      child: activities.isEmpty
          ? const _EmptyActivity()
          : Column(children: activities),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Recently';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
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
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(status),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final positive =
        normalized.contains('approved') ||
        normalized.contains('verified') ||
        normalized.contains('completed') ||
        normalized.contains('active');
    final negative =
        normalized.contains('rejected') ||
        normalized.contains('suspended') ||
        normalized.contains('failed');
    final color = positive
        ? const Color(0xFF16A34A)
        : negative
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Pending' : status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'No recent activity available.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
