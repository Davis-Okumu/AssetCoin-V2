import 'package:flutter/material.dart';

import '../../domain/wallet_summary.dart';

class TokenBalanceCard extends StatelessWidget {
  final List<TokenHoldingSummary> holdings;
  final String currency;

  const TokenBalanceCard({
    super.key,
    required this.holdings,
    required this.currency,
  });

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }

    return quantity.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (holdings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.token_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Token Holdings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your token investments will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // HEADER
          // --------------------------------------------------

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.token_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Token Holdings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${holdings.length} ${holdings.length == 1 ? 'asset' : 'assets'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // --------------------------------------------------
          // HOLDINGS
          // --------------------------------------------------

          ...holdings.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final holding = entry.value;

              return Column(
                children: [
                  _TokenHoldingTile(
                    holding: holding,
                    currency: currency,
                    formatAmount: _formatAmount,
                    formatQuantity: _formatQuantity,
                  ),

                  if (index < holdings.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TokenHoldingTile extends StatelessWidget {
  final TokenHoldingSummary holding;
  final String currency;
  final String Function(double) formatAmount;
  final String Function(double) formatQuantity;

  const _TokenHoldingTile({
    required this.holding,
    required this.currency,
    required this.formatAmount,
    required this.formatQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final availableQuantity =
        holding.quantity - holding.lockedQuantity;

    return Row(
      children: [
        // ----------------------------------------------------
        // TOKEN ICON
        // ----------------------------------------------------

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE53935),
                Color(0xFFC62828),
              ],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.token_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        // ----------------------------------------------------
        // TOKEN INFORMATION
        // ----------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holding.tokenName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                holding.tokenCode,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${formatQuantity(availableQuantity)} available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ----------------------------------------------------
        // CURRENT VALUE
        // ----------------------------------------------------

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency ${formatAmount(holding.currentValue)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$currency ${formatAmount(holding.tokenPrice)} / token',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.60),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}