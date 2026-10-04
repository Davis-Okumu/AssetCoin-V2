
import 'package:flutter/material.dart';

import '../../domain/token_holding.dart';

class TokenHoldingCard extends StatelessWidget {
  const TokenHoldingCard({
    super.key,
    required this.holding,
    this.onTap,
  });

  final TokenHolding holding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tokenName =
        holding.token?.tokenName.trim();

    final tokenCode =
        holding.token?.tokenCode.trim();

    final displayName =
        tokenName != null && tokenName.isNotEmpty
            ? tokenName
            : 'Token Holding';

    final displayCode =
        tokenCode != null && tokenCode.isNotEmpty
            ? tokenCode
            : 'TOKEN-${holding.tokenId}';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.token_rounded,
                      color:
                          colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          displayCode,
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: colorScheme
                                .onSurfaceVariant,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Token balance',
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDecimal(
                        holding.quantity,
                      ),
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HoldingMetric(
                      label: 'Locked',
                      value: _formatDecimal(
                        holding.lockedQuantity,
                      ),
                    ),
                  ),
                  if (holding.averageBuyPrice !=
                      null)
                    Expanded(
                      child: _HoldingMetric(
                        label: 'Avg. price',
                        value:
                            '${holding.token?.currency ?? 'KES'} ${_formatDecimal(holding.averageBuyPrice!)}',
                        valueColor:
                            colorScheme.primary,
                      ),
                    ),
                ],
              ),
              if (holding.totalInvested !=
                  null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total invested',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '${holding.token?.currency ?? 'KES'} ${_formatDecimal(holding.totalInvested!)}',
                      style: theme
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
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

class _HoldingMetric extends StatelessWidget {
  const _HoldingMetric({
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

