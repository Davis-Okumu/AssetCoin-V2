
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/orders_controller.dart';
import '../widgets/order_status_badge.dart';

final orderDetailsProvider = FutureProvider.autoDispose
    .family<dynamic, int>((ref, orderId) async {
  final controller = ref.read(
    ordersControllerProvider.notifier,
  );

  return controller.getOrderDetails(orderId);
});

class OrdersDetailsPage extends ConsumerWidget {
  final int orderId;

  const OrdersDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final orderAsync = ref.watch(
      orderDetailsProvider(orderId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return _OrderDetailsError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                orderDetailsProvider(orderId),
              );
            },
          );
        },
        data: (order) {
          return _OrderDetailsContent(
            order: order,
          );
        },
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  final dynamic order;

  const _OrderDetailsContent({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final quantity = _decimalString(
      order.quantity,
    );

    final filledQuantity = _decimalString(
      order.filledQuantity,
    );

    final remainingQuantity =
        _subtractDecimals(
      quantity,
      filledQuantity,
    );

    final filledRatio = _calculateProgress(
      filledQuantity,
      quantity,
    );

    final isBuy =
        order.orderType.toLowerCase() == 'buy';

    return RefreshIndicator(
      onRefresh: () async {
        // The provider is invalidated by the
        // surrounding page when necessary.
      },
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          _OrderHeaderCard(
            orderReference:
                order.orderReference,
            orderType: order.orderType,
            status: order.status,
            isBuy: isBuy,
          ),

          const SizedBox(height: 16),

          _ProgressCard(
            filledQuantity: filledQuantity,
            totalQuantity: quantity,
            remainingQuantity:
                remainingQuantity,
            progress: filledRatio,
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Order Information',
            icon: Icons.receipt_long_rounded,
            children: [
              _InfoRow(
                label: 'Order ID',
                value: '#${order.id}',
              ),
              _InfoRow(
                label: 'Order Reference',
                value: order.orderReference,
              ),
              _InfoRow(
                label: 'Order Type',
                value: _formatLabel(
                  order.orderType,
                ),
              ),
              _InfoRow(
                label: 'Status',
                valueWidget: OrderStatusBadge(
                  status: order.status,
                ),
              ),
              if (order.listingId != null)
                _InfoRow(
                  label: 'Listing ID',
                  value:
                      '#${order.listingId}',
                ),
            ],
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Token Details',
            icon: Icons.token_rounded,
            children: [
              _InfoRow(
                label: 'Token ID',
                value: '#${order.tokenId}',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Trade Details',
            icon: Icons.swap_horiz_rounded,
            children: [
              _InfoRow(
                label: 'Quantity',
                value: quantity,
              ),
              _InfoRow(
                label: 'Filled Quantity',
                value: filledQuantity,
              ),
              _InfoRow(
                label: 'Remaining Quantity',
                value: remainingQuantity,
              ),
              _InfoRow(
                label: 'Price Per Token',
                value:
                    '${order.pricePerToken} ${order.currency}',
              ),
              _InfoRow(
                label: 'Total Amount',
                value:
                    '${order.totalAmount} ${order.currency}',
              ),
              _InfoRow(
                label: 'Currency',
                value: order.currency,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Timeline',
            icon: Icons.schedule_rounded,
            children: [
              _InfoRow(
                label: 'Created',
                value: _formatDate(
                  order.createdAt,
                ),
              ),
              _InfoRow(
                label: 'Last Updated',
                value: _formatDate(
                  order.updatedAt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _decimalString(
    String value,
  ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '0';
    }

    if (!trimmed.contains('.')) {
      return trimmed;
    }

    var result = trimmed
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );

    return result.isEmpty ? '0' : result;
  }

  static String _subtractDecimals(
    String first,
    String second,
  ) {
    final firstParts = _decimalParts(first);
    final secondParts = _decimalParts(second);

    final scale = firstParts.length > secondParts.length
        ? firstParts.length
        : secondParts.length;

    final firstInteger = BigInt.parse(
      _combineParts(firstParts, scale),
    );

    final secondInteger = BigInt.parse(
      _combineParts(secondParts, scale),
    );

    final difference =
        firstInteger - secondInteger;

    if (difference <= BigInt.zero) {
      return '0';
    }

    final negative = difference.isNegative;
    final absolute = negative
        ? -difference
        : difference;

    final digits = absolute.toString();

    if (scale == 0) {
      return '${negative ? '-' : ''}$digits';
    }

    final padded =
        digits.padLeft(scale + 1, '0');

    final splitPosition =
        padded.length - scale;

    var whole =
        padded.substring(0, splitPosition);

    var fraction =
        padded.substring(splitPosition);

    fraction = fraction.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (fraction.isEmpty) {
      return '${negative ? '-' : ''}$whole';
    }

    if (whole.isEmpty) {
      whole = '0';
    }

    return '${negative ? '-' : ''}$whole.$fraction';
  }

  static List<String> _decimalParts(
    String value,
  ) {
    final normalized =
        value.trim().isEmpty
            ? '0'
            : value.trim();

    final parts =
        normalized.split('.');

    return [
      parts.first.isEmpty
          ? '0'
          : parts.first,
      if (parts.length > 1) parts[1],
    ];
  }

  static String _combineParts(
    List<String> parts,
    int scale,
  ) {
    final whole = parts.first;
    final fraction =
        parts.length > 1 ? parts[1] : '';

    final paddedFraction =
        fraction.padRight(scale, '0');

    final combined =
        '$whole$paddedFraction';

    final normalized =
        combined.replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    );

    return normalized.isEmpty
        ? '0'
        : normalized;
  }

  static double _calculateProgress(
    String filled,
    String total,
  ) {
    final filledParts = _decimalParts(filled);
    final totalParts = _decimalParts(total);

    final scale = filledParts.length > totalParts.length
        ? filledParts.length
        : totalParts.length;

    final filledInteger = BigInt.parse(
      _combineParts(filledParts, scale),
    );

    final totalInteger = BigInt.parse(
      _combineParts(totalParts, scale),
    );

    if (totalInteger <= BigInt.zero) {
      return 0;
    }

    if (filledInteger <= BigInt.zero) {
      return 0;
    }

    if (filledInteger >= totalInteger) {
      return 1;
    }

    // Only the visual progress indicator uses a double.
    // Financial values themselves remain strings/BigInt.
    return filledInteger.toDouble() /
        totalInteger.toDouble();
  }

  static String _formatLabel(
    String value,
  ) {
    final normalized = value
        .trim()
        .replaceAll('_', ' ');

    if (normalized.isEmpty) {
      return '-';
    }

    return normalized
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String _formatDate(
    DateTime value,
  ) {
    final local = value.toLocal();

    final month = local.month
        .toString()
        .padLeft(2, '0');

    final day = local.day
        .toString()
        .padLeft(2, '0');

    final hour = local.hour
        .toString()
        .padLeft(2, '0');

    final minute = local.minute
        .toString()
        .padLeft(2, '0');

    return '${local.year}-$month-$day '
        '$hour:$minute';
  }
}

class _OrderHeaderCard extends StatelessWidget {
  final String orderReference;
  final String orderType;
  final String status;
  final bool isBuy;

  const _OrderHeaderCard({
    required this.orderReference,
    required this.orderType,
    required this.status,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.16),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  isBuy
                      ? Icons.shopping_cart_rounded
                      : Icons.sell_rounded,
                  color:
                      colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatReference(
                        orderReference,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: colorScheme
                                .onPrimary,
                            fontWeight:
                                FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatType(orderType),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: colorScheme
                                .onPrimary
                                .withValues(
                              alpha: 0.85,
                            ),
                            fontWeight:
                                FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OrderStatusBadge(
            status: status,
          ),
        ],
      ),
    );
  }

  static String _formatReference(
    String reference,
  ) {
    if (reference.trim().isEmpty) {
      return 'Order';
    }

    return reference;
  }

  static String _formatType(
    String type,
  ) {
    final normalized =
        type.trim().toLowerCase();

    if (normalized == 'buy') {
      return 'Buy Order';
    }

    if (normalized == 'sell') {
      return 'Sell Order';
    }

    return type;
  }
}

class _ProgressCard extends StatelessWidget {
  final String filledQuantity;
  final String totalQuantity;
  final String remainingQuantity;
  final double progress;

  const _ProgressCard({
    required this.filledQuantity,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline
              .withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Order Progress',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ProgressValue(
                    label: 'Filled',
                    value: filledQuantity,
                  ),
                ),
                Expanded(
                  child: _ProgressValue(
                    label: 'Remaining',
                    value: remainingQuantity,
                  ),
                ),
                Expanded(
                  child: _ProgressValue(
                    label: 'Total',
                    value: totalQuantity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressValue extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline
              .withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme
                        .onSurface
                        .withValues(alpha: 0.62),
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value ?? '-',
                    textAlign:
                        TextAlign.right,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsError
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrderDetailsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load order',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
