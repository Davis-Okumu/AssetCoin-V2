
import 'package:flutter/material.dart';

import '../../domain/order.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final TradingOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isBuy =
        order.orderType.toLowerCase() == 'buy';

    final orderTypeColor = isBuy
        ? colorScheme.primary
        : colorScheme.error;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: orderTypeColor
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBuy
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: orderTypeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBuy
                              ? 'Buy Order'
                              : 'Sell Order',
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.orderReference,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(
                    status: order.status,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OrderMetric(
                      label: 'Quantity',
                      value: _formatDecimal(
                        order.quantity,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _OrderMetric(
                      label: 'Filled',
                      value: _formatDecimal(
                        order.filledQuantity,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _OrderMetric(
                      label: 'Price',
                      value:
                          '${order.currency} ${_formatDecimal(order.pricePerToken)}',
                      valueColor:
                          colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    '${order.currency} ${_formatDecimal(order.totalAmount)}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDecimal(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '0';
    }

    if (!trimmed.contains('.')) {
      return trimmed;
    }

    final parts = trimmed.split('.');
    final integerPart = parts.first;

    var decimalPart = parts.last;

    decimalPart = decimalPart.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (decimalPart.isEmpty) {
      return integerPart;
    }

    return '$integerPart.$decimalPart';
  }
}

class _OrderMetric extends StatelessWidget {
  const _OrderMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

