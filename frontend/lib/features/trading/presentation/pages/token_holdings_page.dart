
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/token_holdings_controller.dart';
import '../widgets/token_holding_card.dart';

class TokenHoldingsPage extends ConsumerWidget {
  const TokenHoldingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(
      tokenHoldingsControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Holdings'),
      ),
      body: holdingsAsync.when(
        loading: () => const _LoadingView(),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () {
            ref
                .read(tokenHoldingsControllerProvider.notifier)
                .refreshHoldings();
          },
        ),
        data: (holdingsState) {
          return _HoldingsContent(
            state: holdingsState,
            onRefresh: () {
              return ref
                  .read(tokenHoldingsControllerProvider.notifier)
                  .refreshHoldings();
            },
            onNextPage: holdingsState.hasNextPage
                ? () {
                    return ref
                        .read(
                          tokenHoldingsControllerProvider.notifier,
                        )
                        .loadNextPage();
                  }
                : null,
            onPreviousPage: holdingsState.hasPreviousPage
                ? () {
                    return ref
                        .read(
                          tokenHoldingsControllerProvider.notifier,
                        )
                        .loadPreviousPage();
                  }
                : null,
            onHoldingTap: (tokenId) {
              context.push(
                '/trading/holdings/$tokenId',
              );
            },
          );
        },
      ),
    );
  }
}

class _HoldingsContent extends StatelessWidget {
  final TokenHoldingsState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onNextPage;
  final Future<void> Function()? onPreviousPage;
  final ValueChanged<int> onHoldingTap;

  const _HoldingsContent({
    required this.state,
    required this.onRefresh,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onHoldingTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.hasHoldings) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const _EmptyHoldingsView(),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          _HoldingsHeader(
            count: state.pagination.total > 0
                ? state.pagination.total
                : state.count,
          ),
          const SizedBox(height: 16),
          ...state.holdings.map(
            (holding) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: TokenHoldingCard(
                holding: holding,
                onTap: () {
                  onHoldingTap(holding.tokenId);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          _PaginationControls(
            page: state.pagination.page,
            totalPages: state.pagination.totalPages,
            hasPreviousPage: state.hasPreviousPage,
            hasNextPage: state.hasNextPage,
            onPreviousPage: onPreviousPage,
            onNextPage: onNextPage,
          ),
        ],
      ),
    );
  }
}

class _HoldingsHeader extends StatelessWidget {
  final int count;

  const _HoldingsHeader({
    required this.count,
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
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
                  'Your Holdings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 1
                      ? '1 token holding'
                      : '$count token holdings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final Future<void> Function()? onPreviousPage;
  final Future<void> Function()? onNextPage;

  const _PaginationControls({
    required this.page,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: hasPreviousPage
                  ? onPreviousPage
                  : null,
              icon: const Icon(
                Icons.chevron_left,
              ),
            ),
            Expanded(
              child: Text(
                'Page $page of $totalPages',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: hasNextPage
                  ? onNextPage
                  : null,
              icon: const Icon(
                Icons.chevron_right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHoldingsView extends StatelessWidget {
  const _EmptyHoldingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 72,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'No Token Holdings',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'You do not have any token holdings yet. '
          'Browse the marketplace to find available tokens.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
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
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load token holdings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
