import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_overview_model.dart';
import '../controllers/admin_trading_overview_controller.dart';
import '../widgets/trading_stat_card.dart';
import '../widgets/trading_status_badge.dart';

class TradingOverviewPage extends ConsumerWidget {
  const TradingOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(adminTradingOverviewControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () {
          return ref
              .read(adminTradingOverviewControllerProvider.notifier)
              .refresh();
        },
        child: overviewAsync.when(
          loading: () => const _TradingOverviewLoading(),
          error: (error, stackTrace) => _TradingOverviewError(
            message: error.toString(),
            onRetry: () {
              ref
                  .read(adminTradingOverviewControllerProvider.notifier)
                  .refresh();
            },
          ),
          data: (overview) => _TradingOverviewContent(overview: overview),
        ),
      ),
    );
  }
}

class _TradingOverviewContent extends StatelessWidget {
  const _TradingOverviewContent({required this.overview});

  final AdminTradingOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marketplace & Trading',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor marketplace activity, orders, trades, and disputes.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          _buildSummaryGrid(context),
          const SizedBox(height: 24),
          _buildTradingHealth(context),
          const SizedBox(height: 24),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    final cards = <Widget>[
      TradingStatCard(
        title: 'Total Listings',
        value: _formatNumber(overview.listings.total),
        icon: Icons.inventory_2_outlined,
      ),
      TradingStatCard(
        title: 'Active Listings',
        value: _formatNumber(overview.listings.active),
        icon: Icons.storefront_outlined,
      ),
      TradingStatCard(
        title: 'Open Orders',
        value: _formatNumber(overview.orders.open),
        icon: Icons.shopping_cart_outlined,
      ),
      TradingStatCard(
        title: 'Completed Trades',
        value: _formatNumber(overview.trades.completed),
        icon: Icons.swap_horiz_rounded,
      ),
      TradingStatCard(
        title: 'Trade Volume',
        value: _formatAmount(overview.trades.volume),
        icon: Icons.account_balance_wallet_outlined,
      ),
      TradingStatCard(
        title: 'Trading Fees',
        value: _formatAmount(overview.trades.fees),
        icon: Icons.payments_outlined,
      ),
      TradingStatCard(
        title: 'Open Disputes',
        value: _formatNumber(overview.disputes.open),
        icon: Icons.report_problem_outlined,
      ),
      TradingStatCard(
        title: 'Suspended Listings',
        value: _formatNumber(overview.suspendedListings),
        icon: Icons.block_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1300) {
          columns = 4;
        } else if (width >= 900) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 16.0;
        final cardWidth = (width - ((columns - 1) * spacing)) / columns;

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

  Widget _buildTradingHealth(BuildContext context) {
    return _SectionCard(
      title: 'Trading Health',
      icon: Icons.analytics_outlined,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _HealthItem(
            label: 'Listings',
            value: '${overview.listings.active} active',
            status: 'active',
          ),
          _HealthItem(
            label: 'Orders',
            value: '${overview.orders.open} open',
            status: overview.orders.open > 0 ? 'pending' : 'completed',
          ),
          _HealthItem(
            label: 'Trades',
            value: '${overview.trades.completed} completed',
            status: 'completed',
          ),
          _HealthItem(
            label: 'Disputes',
            value: '${overview.disputes.open} open',
            status: overview.disputes.open > 0 ? 'open' : 'resolved',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),
        _RecentTradesCard(trades: overview.recentTrades),
        const SizedBox(height: 16),
        _RecentDisputesCard(disputes: overview.recentDisputes),
      ],
    );
  }

  String _formatNumber(int value) {
    return value.toString();
  }

  String _formatAmount(String value) {
    final number = double.tryParse(value) ?? 0;

    return number.toStringAsFixed(2);
  }
}

class _HealthItem extends StatelessWidget {
  const _HealthItem({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TradingStatusBadge(status: status, compact: true),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTradesCard extends StatelessWidget {
  const _RecentTradesCard({required this.trades});

  final List<Map<String, dynamic>> trades;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Trades',
      icon: Icons.swap_horiz_rounded,
      child: trades.isEmpty
          ? const _InlineEmptyState(message: 'No recent trades.')
          : Column(
              children: trades.take(5).map((trade) {
                final buyerName = _fullName(
                  trade['buyerFirstName'],
                  trade['buyerLastName'],
                );

                final sellerName = _fullName(
                  trade['sellerFirstName'],
                  trade['sellerLastName'],
                );

                final tokenName =
                    trade['tokenName']?.toString() ?? 'Unknown token';

                final amount = trade['totalAmount']?.toString() ?? '0.00';

                final currency = trade['currency']?.toString() ?? 'KES';

                final status = trade['status']?.toString() ?? 'unknown';

                return _ActivityRow(
                  icon: Icons.swap_horiz_rounded,
                  title: tokenName,
                  subtitle: '$buyerName → $sellerName',
                  trailing: '$currency $amount',
                  status: status,
                );
              }).toList(),
            ),
    );
  }

  static String _fullName(dynamic firstName, dynamic lastName) {
    final first = firstName?.toString().trim() ?? '';
    final last = lastName?.toString().trim() ?? '';

    final value = '$first $last'.trim();

    return value.isEmpty ? 'Unknown user' : value;
  }
}

class _RecentDisputesCard extends StatelessWidget {
  const _RecentDisputesCard({required this.disputes});

  final List<Map<String, dynamic>> disputes;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Disputes',
      icon: Icons.report_problem_outlined,
      child: disputes.isEmpty
          ? const _InlineEmptyState(message: 'No recent disputes.')
          : Column(
              children: disputes.take(5).map((dispute) {
                final reference =
                    dispute['disputeReference']?.toString() ?? 'Dispute';

                final reason =
                    dispute['reason']?.toString() ?? 'No reason provided';

                final status = dispute['status']?.toString() ?? 'unknown';

                final priority = dispute['priority']?.toString() ?? 'normal';

                return _ActivityRow(
                  icon: Icons.report_problem_outlined,
                  title: reference,
                  subtitle: reason,
                  trailing: priority,
                  status: status,
                );
              }).toList(),
            ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 5),
              TradingStatusBadge(status: status, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

class _TradingOverviewLoading extends StatelessWidget {
  const _TradingOverviewLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _TradingOverviewError extends StatelessWidget {
  const _TradingOverviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load trading overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
