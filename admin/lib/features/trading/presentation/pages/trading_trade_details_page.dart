import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_trade_model.dart';
import '../controllers/admin_trading_trade_details_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingTradeDetailsPage extends ConsumerWidget {
  const TradingTradeDetailsPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      adminTradingTradeDetailsControllerProvider(transactionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(
                          adminTradingTradeDetailsControllerProvider(
                            transactionId,
                          ).notifier,
                        )
                        .refresh();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          message: error.toString(),
          onRetry: () {
            ref
                .read(
                  adminTradingTradeDetailsControllerProvider(transactionId)
                      .notifier,
                )
                .refresh();
          },
        ),
        data: (trade) => _TradeDetailsContent(trade: trade),
      ),
    );
  }
}

class _TradeDetailsContent extends StatelessWidget {
  const _TradeDetailsContent({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(trade: trade),
              const SizedBox(height: 20),
              _TradeOverviewSection(trade: trade),
              const SizedBox(height: 20),
              _BuyerSection(trade: trade),
              const SizedBox(height: 20),
              _SellerSection(trade: trade),
              const SizedBox(height: 20),
              _TokenSection(trade: trade),
              const SizedBox(height: 20),
              _AssetSection(trade: trade),
              const SizedBox(height: 20),
              _OrderSection(trade: trade),
              const SizedBox(height: 20),
              _LedgerSection(trade: trade),
              const SizedBox(height: 20),
              _TimelineSection(trade: trade),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.swap_horiz_outlined,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _display(trade.transactionReference),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    trade.tokenDisplayName,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  TradingStatusBadge(status: _display(trade.status)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeOverviewSection extends StatelessWidget {
  const _TradeOverviewSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Trade Overview',
      icon: Icons.swap_horiz_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Transaction ID', value: '#${trade.id}'),
            _DetailItem(
              label: 'Transaction Reference',
              value: _display(trade.transactionReference),
            ),
            _DetailItem(label: 'Status', value: trade.statusLabel),
            _DetailItem(label: 'Currency', value: _display(trade.currency)),
            _DetailItem(label: 'Quantity', value: _display(trade.quantity)),
            _DetailItem(
              label: 'Price Per Token',
              value:
                  '${_display(trade.currency)} '
                  '${_display(trade.pricePerToken)}',
            ),
            _DetailItem(
              label: 'Total Amount',
              value:
                  '${_display(trade.currency)} '
                  '${_display(trade.totalAmount)}',
            ),
            _DetailItem(
              label: 'Trading Fee',
              value:
                  '${_display(trade.currency)} '
                  '${_display(trade.feeAmount)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _BuyerSection extends StatelessWidget {
  const _BuyerSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Buyer Information',
      icon: Icons.person_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Buyer ID', value: trade.buyerId.toString()),
            _DetailItem(label: 'Name', value: trade.buyerName),
            _DetailItem(label: 'Email', value: _display(trade.buyerEmail)),
            _DetailItem(label: 'Phone', value: _display(trade.buyerPhone)),
          ],
        ),
      ],
    );
  }
}

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Seller Information',
      icon: Icons.person_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Seller ID', value: trade.sellerId.toString()),
            _DetailItem(label: 'Name', value: trade.sellerName),
            _DetailItem(label: 'Email', value: _display(trade.sellerEmail)),
            _DetailItem(label: 'Phone', value: _display(trade.sellerPhone)),
          ],
        ),
      ],
    );
  }
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Token Information',
      icon: Icons.token_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Token ID', value: trade.tokenId.toString()),
            _DetailItem(label: 'Token Name', value: _display(trade.tokenName)),
            _DetailItem(label: 'Token Code', value: _display(trade.tokenCode)),
          ],
        ),
      ],
    );
  }
}

class _AssetSection extends StatelessWidget {
  const _AssetSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Underlying Asset',
      icon: Icons.account_balance_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Asset ID', value: trade.assetId.toString()),
            _DetailItem(label: 'Asset Name', value: _display(trade.assetName)),
            _DetailItem(label: 'Asset Code', value: _display(trade.assetCode)),
            _DetailItem(label: 'Asset Type', value: _display(trade.assetType)),
          ],
        ),
      ],
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Related Orders & Listing',
      icon: Icons.receipt_long_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(
              label: 'Listing ID',
              value: _nullableInt(trade.listingId),
            ),
            _DetailItem(
              label: 'Buy Order ID',
              value: _nullableInt(trade.buyOrderId),
            ),
            _DetailItem(
              label: 'Sell Order ID',
              value: _nullableInt(trade.sellOrderId),
            ),
          ],
        ),
      ],
    );
  }
}

class _LedgerSection extends StatelessWidget {
  const _LedgerSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ledger & Integrity',
      icon: Icons.security_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(
              label: 'Previous Hash',
              value: _display(trade.previousHash),
            ),
            _DetailItem(
              label: 'Transaction Hash',
              value: _display(trade.transactionHash),
            ),
            _DetailItem(
              label: 'Hash Chain Status',
              value: trade.hasTransactionHash
                  ? 'Transaction hash recorded'
                  : 'Transaction hash unavailable',
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Trade Timeline',
      icon: Icons.schedule_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Created', value: _formatDate(trade.createdAt)),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 18,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              'Unable to load trade',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _display(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '—';
  }

  return value;
}

String _nullableInt(int? value) {
  return value?.toString() ?? '—';
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  return '${local.year}-'
      '${twoDigits(local.month)}-'
      '${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)}';
}
