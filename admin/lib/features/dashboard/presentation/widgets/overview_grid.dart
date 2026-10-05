import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';
import 'overview_card.dart';

class OverviewGrid extends StatelessWidget {
  const OverviewGrid({super.key, required this.overview});
  final DashboardOverview overview;
  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      OverviewCard(
        title: 'Total Users',
        value: _number(overview.totalUsers),
        subtitle: '${_number(overview.newUsersLast30Days)} new in 30 days',
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF2563EB),
      ),
      OverviewCard(
        title: 'Total Assets',
        value: _number(overview.totalAssets),
        subtitle: '${_number(overview.tokenizedAssets)} tokenized',
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFFDC2626),
      ),
      OverviewCard(
        title: 'Asset Value',
        value: _currency(overview.totalAssetValue),
        subtitle: 'Approved and managed assets',
        icon: Icons.account_balance_outlined,
        iconColor: const Color(0xFF0F766E),
      ),
      OverviewCard(
        title: 'Verified KYC',
        value: _number(overview.verifiedKyc),
        subtitle: '${_number(overview.pendingKyc)} pending',
        icon: Icons.verified_user_outlined,
        iconColor: const Color(0xFF16A34A),
      ),
      OverviewCard(
        title: 'Active Tokens',
        value: _number(overview.activeTokens),
        subtitle: '${_compact(overview.totalTokenSupply)} total supply',
        icon: Icons.token_outlined,
        iconColor: const Color(0xFF7C3AED),
      ),
      OverviewCard(
        title: 'Wallet Balance',
        value: _currency(overview.totalWalletBalance),
        subtitle: '${_number(overview.activeWallets)} active wallets',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF0891B2),
      ),
      OverviewCard(
        title: 'Trading Volume',
        value: _currency(overview.tradingVolume),
        subtitle: '${_number(overview.activeListings)} active listings',
        icon: Icons.swap_horizontal_circle_outlined,
        iconColor: const Color(0xFFEA580C),
      ),
      OverviewCard(
        title: 'Pending Approvals',
        value: _number(overview.pendingApprovals),
        subtitle: '${_number(overview.openSupportTickets)} support tickets',
        icon: Icons.pending_actions_outlined,
        iconColor: const Color(0xFFDB2777),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns;
        if (width >= 1350) {
          columns = 4;
        } else if (width >= 900) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }
        final spacing = width < 600 ? 12.0 : 16.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  static String _number(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }

  static String _currency(double value) {
    return 'KES ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)},')}';
  }

  static String _compact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
