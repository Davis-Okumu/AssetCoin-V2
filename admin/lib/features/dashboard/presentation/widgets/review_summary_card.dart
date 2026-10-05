import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({super.key, required this.overview});
  final DashboardOverview overview;
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
                Icons.fact_check_outlined,
                color: Color(0xFFDC2626),
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Review Queue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ReviewRow(
            label: 'Pending KYC',
            value: overview.pendingKyc,
            icon: Icons.person_search_outlined,
          ),
          _ReviewRow(
            label: 'Assets pending review',
            value: overview.pendingAssets + overview.assetsUnderReview,
            icon: Icons.inventory_2_outlined,
          ),
          _ReviewRow(
            label: 'Changes requested',
            value: overview.assetsChangesRequired,
            icon: Icons.edit_note_outlined,
          ),
          _ReviewRow(
            label: 'Approval requests',
            value: overview.pendingApprovals,
            icon: Icons.approval_outlined,
          ),
          _ReviewRow(
            label: 'Open support tickets',
            value: overview.openSupportTickets,
            icon: Icons.support_agent_outlined,
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final highlighted = value > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: highlighted
                ? const Color(0xFFDC2626)
                : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: highlighted
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
