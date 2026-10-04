
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/listing.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/listing_card.dart';
import '../widgets/marketplace_filters.dart';
import '../widgets/trading_summary.dart';

class TradingPage extends ConsumerStatefulWidget {
  const TradingPage({super.key});

  @override
  ConsumerState<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends ConsumerState<TradingPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final marketplaceState = ref.watch(
      marketplaceControllerProvider,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(marketplaceControllerProvider.notifier)
                .refreshMarketplace();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverToBoxAdapter(
                child: _buildTradingSummary(
                  context,
                  marketplaceState,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildTabs(context),
              ),
              if (_selectedTab == 0)
                ..._buildMarketplaceContent(
                  context,
                  marketplaceState,
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildComingSoonContent(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trading',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buy, sell and manage tokenized assets.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.candlestick_chart_rounded,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildTradingSummary(
    BuildContext context,
    AsyncValue<MarketplaceState> marketplaceState,
  ) {
    final marketplaceCount = marketplaceState.whenOrNull(
      data: (state) => state.pagination.total,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),
      child: TradingSummary(
        marketplaceCount: marketplaceCount,
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const tabs = [
      (
        label: 'Marketplace',
        icon: Icons.storefront_rounded,
      ),
      (
        label: 'Orders',
        icon: Icons.receipt_long_rounded,
      ),
      (
        label: 'Holdings',
        icon: Icons.account_balance_wallet_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        12,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) {
              final selected = _selectedTab == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[index].icon,
                          size: 18,
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tabs[index].label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? colorScheme.onPrimary
                                      : colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MARKETPLACE
  // ============================================================

  List<Widget> _buildMarketplaceContent(
    BuildContext context,
    AsyncValue<MarketplaceState> marketplaceState,
  ) {
    return marketplaceState.when(
      loading: () {
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                20,
              ),
              child: MarketplaceFilters(),
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ];
      },
      error: (error, stackTrace) {
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                20,
              ),
              child: MarketplaceFilters(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildErrorState(
              context,
              error,
            ),
          ),
        ];
      },
      data: (state) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                4,
                20,
                20,
              ),
              child: MarketplaceFilters(
                onSearchChanged: (value) {
                  ref
                      .read(
                        marketplaceControllerProvider
                            .notifier,
                      )
                      .search(value);
                },
                onAssetTypeChanged: (value) {
                  ref
                      .read(
                        marketplaceControllerProvider
                            .notifier,
                      )
                      .setAssetType(value);
                },
                onClear: () {
                  ref
                      .read(
                        marketplaceControllerProvider
                            .notifier,
                      )
                      .clearFilters();
                },
              ),
            ),
          ),

          if (!state.hasListings)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyMarketplace(context),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                12,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildResultsHeader(
                  context,
                  state,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),
              sliver: SliverList.separated(
                itemCount: state.listings.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final listing =
                      state.listings[index];

                  return ListingCard(
                    listing: listing,
                    onTap: () {
                      _openListingDetails(
                        context,
                        listing,
                      );
                    },
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPagination(
                context,
                state,
              ),
            ),
          ],
        ];
      },
    );
  }

  // ============================================================
  // RESULTS HEADER
  // ============================================================

  Widget _buildResultsHeader(
    BuildContext context,
    MarketplaceState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final total = state.pagination.total;

    return Row(
      children: [
        Expanded(
          child: Text(
            total == 1
                ? '1 marketplace listing'
                : '$total marketplace listings',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
          ),
        ),
        if (state.pagination.totalPages > 1)
          Text(
            'Page ${state.pagination.page} '
            'of ${state.pagination.totalPages}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination(
    BuildContext context,
    MarketplaceState state,
  ) {
    if (!state.hasNextPage &&
        !state.hasPreviousPage) {
      return const SizedBox(height: 20);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        32,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.hasPreviousPage
                  ? () {
                      ref
                          .read(
                            marketplaceControllerProvider
                                .notifier,
                          )
                          .loadPreviousPage();
                    }
                  : null,
              icon: const Icon(
                Icons.chevron_left_rounded,
              ),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: state.hasNextPage
                  ? () {
                      ref
                          .read(
                            marketplaceControllerProvider
                                .notifier,
                          )
                          .loadNextPage();
                    }
                  : null,
              icon: const Icon(
                Icons.chevron_right_rounded,
              ),
              label: const Text('Next'),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyMarketplace(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No listings found',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are currently no tokenized assets '
              'matching your search or filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(
                      marketplaceControllerProvider
                          .notifier,
                    )
                    .clearFilters();
              },
              icon: const Icon(
                Icons.filter_alt_off_rounded,
              ),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    BuildContext context,
    Object error,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load marketplace',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading '
              'the available listings.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(
                      marketplaceControllerProvider
                          .notifier,
                    )
                    .refreshMarketplace();
              },
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

  // ============================================================
  // ORDERS / HOLDINGS PLACEHOLDER
  // ============================================================

  Widget _buildComingSoonContent(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final isOrders = _selectedTab == 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOrders
                    ? Icons.receipt_long_rounded
                    : Icons.account_balance_wallet_rounded,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isOrders
                  ? 'Orders'
                  : 'Token Holdings',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isOrders
                  ? 'Your orders will appear here once '
                    'the orders page is connected.'
                  : 'Your token holdings will appear here '
                    'once the holdings page is connected.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LISTING DETAILS NAVIGATION
  // ============================================================

  void _openListingDetails(
    BuildContext context,
    Listing listing,
  ) {
    context.push(
      '/trading/listings/${listing.id}',
    );
  }
}