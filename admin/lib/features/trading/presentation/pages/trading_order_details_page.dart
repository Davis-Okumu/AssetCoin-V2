import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_order_model.dart';
import '../controllers/admin_trading_order_details_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingOrderDetailsPage extends ConsumerWidget {
  const TradingOrderDetailsPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      adminTradingOrderDetailsControllerProvider(orderId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(
                          adminTradingOrderDetailsControllerProvider(orderId)
                              .notifier,
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
                  adminTradingOrderDetailsControllerProvider(orderId).notifier,
                )
                .refresh();
          },
        ),
        data: (order) => _OrderDetailsContent(order: order),
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order});

  final AdminTradingOrderModel order;

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
              _HeaderCard(order: order),
              const SizedBox(height: 20),
              _OrderOverviewSection(order: order),
              const SizedBox(height: 20),
              _CustomerSection(order: order),
              const SizedBox(height: 20),
              _TokenSection(order: order),
              const SizedBox(height: 20),
              _AssetSection(order: order),
              const SizedBox(height: 20),
              _ListingSection(order: order),
              const SizedBox(height: 20),
              _TimelineSection(order: order),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final AdminTradingOrderModel order;

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
                order.isBuyOrder
                    ? Icons.shopping_cart_outlined
                    : Icons.sell_outlined,
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
                    _display(order.orderReference),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(order.customerName, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      TradingStatusBadge(status: _display(order.status)),
                      _TypeBadge(
                        label: order.orderTypeLabel,
                        isBuy: order.isBuyOrder,
                      ),
                    ],
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

class _OrderOverviewSection extends StatelessWidget {
  const _OrderOverviewSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Order Overview',
      icon: Icons.receipt_long_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Order ID', value: '#${order.id}'),
            _DetailItem(
              label: 'Order Reference',
              value: _display(order.orderReference),
            ),
            _DetailItem(label: 'Order Type', value: order.orderTypeLabel),
            _DetailItem(label: 'Status', value: order.statusLabel),
            _DetailItem(label: 'Quantity', value: _display(order.quantity)),
            _DetailItem(
              label: 'Filled Quantity',
              value: _display(order.filledQuantity),
            ),
            _DetailItem(
              label: 'Price Per Token',
              value:
                  '${_display(order.currency)} '
                  '${_display(order.pricePerToken)}',
            ),
            _DetailItem(
              label: 'Total Amount',
              value:
                  '${_display(order.currency)} '
                  '${_display(order.totalAmount)}',
            ),
            _DetailItem(label: 'Currency', value: _display(order.currency)),
          ],
        ),
      ],
    );
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'User ID', value: order.userId.toString()),
            _DetailItem(label: 'Name', value: order.customerName),
            _DetailItem(label: 'Email', value: _display(order.email)),
            _DetailItem(label: 'Phone', value: _display(order.phone)),
          ],
        ),
      ],
    );
  }
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Token Information',
      icon: Icons.token_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Token ID', value: order.tokenId.toString()),
            _DetailItem(label: 'Token Name', value: _display(order.tokenName)),
            _DetailItem(label: 'Token Code', value: _display(order.tokenCode)),
          ],
        ),
      ],
    );
  }
}

class _AssetSection extends StatelessWidget {
  const _AssetSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Underlying Asset',
      icon: Icons.account_balance_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Asset Name', value: _display(order.assetName)),
            _DetailItem(label: 'Asset Code', value: _display(order.assetCode)),
            _DetailItem(label: 'Asset Type', value: _display(order.assetType)),
          ],
        ),
      ],
    );
  }
}

class _ListingSection extends StatelessWidget {
  const _ListingSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Marketplace Listing',
      icon: Icons.storefront_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Listing ID', value: order.listingId.toString()),
            _DetailItem(
              label: 'Listing Status',
              value: _display(order.listingStatus),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Order Timeline',
      icon: Icons.schedule_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Created', value: _formatDate(order.createdAt)),
            _DetailItem(
              label: 'Last Updated',
              value: _formatDate(order.updatedAt),
            ),
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.isBuy});

  final String label;
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
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
              'Unable to load order',
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
