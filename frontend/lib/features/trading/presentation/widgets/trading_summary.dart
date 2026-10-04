
import 'package:flutter/material.dart';

class TradingSummary extends StatelessWidget {
  const TradingSummary({
    super.key,
    this.marketplaceCount,
    this.orderCount,
    this.holdingCount,
    this.title = 'Trading Overview',
    this.subtitle =
        'Manage your tokenized asset activity',
  });

  final int? marketplaceCount;
  final int? orderCount;
  final int? holdingCount;

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.candlestick_chart_rounded,
                  color: colorScheme.onPrimary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        color:
                            colorScheme.onPrimary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: colorScheme.onPrimary
                            .withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon:
                      Icons.storefront_outlined,
                  label: 'Marketplace',
                  value: marketplaceCount,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  icon:
                      Icons.receipt_long_outlined,
                  label: 'Orders',
                  value: orderCount,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.token_outlined,
                  label: 'Holdings',
                  value: holdingCount,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final int? value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '—',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall
                ?.copyWith(
              color: colorScheme.onPrimary
                  .withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
