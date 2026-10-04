
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/token_holding.dart';
import '../controllers/token_holdings_controller.dart';

final tokenHoldingDetailsProvider =
    FutureProvider.autoDispose.family<TokenHolding, int>(
  (ref, tokenId) async {
    final controller = ref.read(
      tokenHoldingsControllerProvider.notifier,
    );

    return controller.getTokenHoldingDetails(tokenId);
  },
);

class TokenHoldingDetailsPage extends ConsumerWidget {
  final int tokenId;

  const TokenHoldingDetailsPage({
    super.key,
    required this.tokenId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingAsync = ref.watch(
      tokenHoldingDetailsProvider(tokenId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holding Details'),
      ),
      body: holdingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(
              tokenHoldingDetailsProvider(tokenId),
            );
          },
        ),
        data: (holding) => _HoldingDetailsContent(
          holding: holding,
        ),
      ),
    );
  }
}

class _HoldingDetailsContent extends StatelessWidget {
  final TokenHolding holding;

  const _HoldingDetailsContent({
    required this.holding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tokenName = holding.token?.tokenName ?? 'Token';
    final tokenCode = holding.token?.tokenCode ?? '—';
    final tokenStatus = holding.token?.status ?? '—';
    final currency = holding.token?.currency ?? 'KES';

    final availableQuantity = _subtractDecimals(
      holding.quantity,
      holding.lockedQuantity,
    );

    final hasLockedQuantity = _isPositive(
      holding.lockedQuantity,
    );

    final hasInvestedAmount =
        holding.totalInvested != null &&
        holding.totalInvested!.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        32,
      ),
      children: [
        _TokenHeader(
          tokenName: tokenName,
          tokenCode: tokenCode,
          status: tokenStatus,
        ),
        const SizedBox(height: 16),
        _BalanceCard(
          quantity: holding.quantity,
          availableQuantity: availableQuantity,
          lockedQuantity: holding.lockedQuantity,
          currency: currency,
        ),
        const SizedBox(height: 16),
        _InformationCard(
          title: 'Investment',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            _InfoRow(
              label: 'Average Buy Price',
              value: _formatMoney(
                holding.averageBuyPrice,
                currency,
              ),
            ),
            _InfoRow(
              label: 'Total Invested',
              value: _formatMoney(
                holding.totalInvested,
                currency,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InformationCard(
          title: 'Holding Information',
          icon: Icons.token_outlined,
          children: [
            _InfoRow(
              label: 'Token',
              value: tokenName,
            ),
            _InfoRow(
              label: 'Token Code',
              value: tokenCode,
            ),
            _InfoRow(
              label: 'Holding ID',
              value: holding.id.toString(),
            ),
            _InfoRow(
              label: 'Token ID',
              value: holding.tokenId.toString(),
            ),
            _InfoRow(
              label: 'Status',
              valueWidget: _TokenStatusBadge(
                status: tokenStatus,
              ),
            ),
          ],
        ),
        if (holding.createdAt != null ||
            holding.updatedAt != null) ...[
          const SizedBox(height: 16),
          _InformationCard(
            title: 'Activity',
            icon: Icons.history,
            children: [
              if (holding.createdAt != null)
                _InfoRow(
                  label: 'Acquired',
                  value: _formatDateTime(
                    holding.createdAt!,
                  ),
                ),
              if (holding.updatedAt != null)
                _InfoRow(
                  label: 'Last Updated',
                  value: _formatDateTime(
                    holding.updatedAt!,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _isPositive(availableQuantity)
                ? () {
                    context.push(
                      '/trading/holdings/${holding.tokenId}/sell',
                    );
                  }
                : null,
            icon: const Icon(Icons.sell_outlined),
            label: const Text('Sell Tokens'),
          ),
        ),
        if (hasLockedQuantity) ...[
          const SizedBox(height: 12),
          _NoticeCard(
            icon: Icons.lock_outline,
            message:
                'Some of your tokens are currently locked and cannot be sold.',
          ),
        ],
        if (!hasInvestedAmount) ...[
          const SizedBox(height: 12),
          _NoticeCard(
            icon: Icons.info_outline,
            message:
                'Investment information is not available for this holding.',
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Available quantity is calculated from your total holding '
          'minus any locked quantity.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TokenHeader extends StatelessWidget {
  final String tokenName;
  final String tokenCode;
  final String status;

  const _TokenHeader({
    required this.tokenName,
    required this.tokenCode,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.token_outlined,
              size: 30,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tokenName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tokenCode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(
                      alpha: 0.85,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _TokenStatusBadge(
            status: status,
            inverted: true,
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String quantity;
  final String availableQuantity;
  final String lockedQuantity;
  final String currency;

  const _BalanceCard({
    required this.quantity,
    required this.availableQuantity,
    required this.lockedQuantity,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token Balance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formatDecimal(quantity),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total tokens held',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _BalanceRow(
              label: 'Available to sell',
              value: _formatDecimal(availableQuantity),
              valueColor: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _BalanceRow(
              label: 'Locked',
              value: _formatDecimal(lockedQuantity),
              valueColor: colorScheme.error,
            ),
            const SizedBox(height: 12),
            _BalanceRow(
              label: 'Currency',
              value: currency,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BalanceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _InformationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InformationCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._withSpacing(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final result = <Widget>[];

    for (var index = 0; index < widgets.length; index++) {
      result.add(widgets[index]);

      if (index < widgets.length - 1) {
        result.add(const SizedBox(height: 14));
      }
    }

    return result;
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
  }) : assert(
          value != null || valueWidget != null,
          'Either value or valueWidget must be provided.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget ??
                Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _TokenStatusBadge extends StatelessWidget {
  final String status;
  final bool inverted;

  const _TokenStatusBadge({
    required this.status,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final normalized = status.trim().toLowerCase();

    Color background;
    Color foreground;
    String label;

    switch (normalized) {
      case 'active':
        background = colorScheme.primary;
        foreground = colorScheme.onPrimary;
        label = 'Active';
        break;
      case 'paused':
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        label = 'Paused';
        break;
      case 'fully_sold':
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        label = 'Fully Sold';
        break;
      case 'suspended':
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        label = 'Suspended';
        break;
      case 'pending':
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurfaceVariant;
        label = 'Pending';
        break;
      case 'burned':
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        label = 'Burned';
        break;
      default:
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurfaceVariant;
        label = status.trim().isEmpty
            ? 'Unknown'
            : _titleCase(status);
    }

    if (inverted) {
      background = colorScheme.onPrimary.withValues(
        alpha: 0.16,
      );
      foreground = colorScheme.onPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _NoticeCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load holding',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDecimal(String value) {
  final normalized = value.trim();

  if (normalized.isEmpty) {
    return '0';
  }

  if (!normalized.contains('.')) {
    return normalized;
  }

  final parts = normalized.split('.');
  var fraction = parts[1];

  while (fraction.endsWith('0')) {
    fraction = fraction.substring(
      0,
      fraction.length - 1,
    );
  }

  if (fraction.isEmpty) {
    return parts[0];
  }

  return '${parts[0]}.$fraction';
}

String _formatMoney(
  String? amount,
  String currency,
) {
  if (amount == null || amount.trim().isEmpty) {
    return '—';
  }

  return '$currency ${_formatDecimal(amount)}';
}

String _subtractDecimals(
  String left,
  String right,
) {
  const scale = 8;
  final multiplier = BigInt.from(100000000);

  final leftScaled = _decimalToScaledInteger(left);
  final rightScaled = _decimalToScaledInteger(right);

  var result = leftScaled - rightScaled;

  if (result < BigInt.zero) {
    result = BigInt.zero;
  }

  final whole = result ~/ multiplier;
  final fraction = result % multiplier;

  if (fraction == BigInt.zero) {
    return whole.toString();
  }

  final fractionString = fraction
      .toString()
      .padLeft(scale, '0')
      .replaceFirst(RegExp(r'0+$'), '');

  return '$whole.$fractionString';
}

BigInt _decimalToScaledInteger(String value) {
  final normalized = value.trim();

  if (normalized.isEmpty) {
    return BigInt.zero;
  }

  final parts = normalized.split('.');

  final whole = BigInt.tryParse(
        parts.first,
      ) ??
      BigInt.zero;

  var fraction = parts.length > 1
      ? parts[1]
      : '';

  if (fraction.length > 8) {
    fraction = fraction.substring(0, 8);
  }

  fraction = fraction.padRight(8, '0');

  final fractionValue = BigInt.tryParse(
        fraction,
      ) ??
      BigInt.zero;

  return whole * BigInt.from(100000000) +
      fractionValue;
}

bool _isPositive(String value) {
  final normalized = value.trim();

  if (normalized.isEmpty) {
    return false;
  }

  final parts = normalized.split('.');

  final whole = BigInt.tryParse(
        parts.first,
      ) ??
      BigInt.zero;

  if (whole > BigInt.zero) {
    return true;
  }

  if (parts.length < 2) {
    return false;
  }

  return parts[1].replaceAll('0', '').isNotEmpty;
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();

  final hour = local.hour % 12 == 0
      ? 12
      : local.hour % 12;

  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '$day/$month/$year, $hour:$minute $period';
}
