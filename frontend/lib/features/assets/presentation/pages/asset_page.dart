
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/asset.dart';
import '../controllers/assets_controller.dart';
import '../providers/asset_providers.dart';
import '../widgets/asset_card.dart';
import '../widgets/asset_category_tabs.dart';
import '../widgets/asset_search_bar.dart';

class AssetPage extends ConsumerStatefulWidget {
  const AssetPage({super.key});

  @override
  ConsumerState<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends ConsumerState<AssetPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 350) {
      ref.read(assetsControllerProvider.notifier).loadMoreAssets();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsControllerProvider);
    final categoriesState = ref.watch(assetCategoriesProvider);
    final statsState = ref.watch(assetMarketStatsProvider);

    final controller = ref.read(assetsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshAssets,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 18),

                _buildSubmitAssetButton(),

                const SizedBox(height: 12),

                _buildMySubmissionsButton(),

                const SizedBox(height: 22),

                _buildMarketStatistics(statsState),

                const SizedBox(height: 26),

                _buildSectionHeading(
                  title: 'Explore Assets',
                  subtitle: 'Discover tokenized real-world assets.',
                ),

                const SizedBox(height: 16),

                AssetSearchBar(
                  initialValue: controller.currentSearch ?? '',
                  onSearch: controller.searchAssets,
                ),

                const SizedBox(height: 18),

                categoriesState.when(
                  data: (categories) {
                    return AssetCategoryTabs(
                      categories: categories,
                      selectedCategory:
                          controller.currentCategory ?? 'all',
                      onCategorySelected: controller.filterByCategory,
                    );
                  },
                  loading: () => const SizedBox(
                    height: 46,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => _buildCategoryError(),
                ),

                const SizedBox(height: 26),

                _buildSectionHeading(
                  title: 'Available Marketplace Assets',
                  subtitle: 'Browse approved and tokenized assets.',
                ),

                const SizedBox(height: 16),

                assetsState.when(
                  loading: () => _buildLoadingState(),
                  error: (error, stackTrace) => _buildErrorState(),
                  data: (assets) => _buildAssetsList(
                    assets,
                    controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // MARKETPLACE HEADER
  // =========================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSETCOIN MARKETPLACE',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Explore Assets',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Discover opportunities backed by real-world assets.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: 25,
          ),
        ),
      ],
    );
  }

  // =========================
  // SUBMIT ASSET BUTTON
  // =========================

  Widget _buildSubmitAssetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(RouteNames.submitAsset);
        },
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          size: 21,
        ),
        label: const Text(
          'Submit an Asset',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // =========================
  // MY SUBMISSIONS BUTTON
  // =========================

  Widget _buildMySubmissionsButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push(RouteNames.mySubmissions);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Submissions',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your submitted assets and their status',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // MARKET STATISTICS
  // =========================

  Widget _buildMarketStatistics(
    AsyncValue<Map<String, dynamic>> statsState,
  ) {
    return statsState.when(
      loading: () => _buildStatsLoading(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (stats) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MARKET OVERVIEW',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _statCard(
                  title: 'Total Assets',
                  value: _formatCount(stats['totalAssets']),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
                _statCard(
                  title: 'Total Tokens',
                  value: _formatCount(stats['totalTokens']),
                  icon: Icons.token_outlined,
                  color: AppColors.secondary,
                ),
                _statCard(
                  title: 'Total Asset Value',
                  value: _formatAmount(stats['totalAssetValue']),
                  icon: Icons.account_balance_outlined,
                  color: const Color(0xFF247A64),
                ),
                _statCard(
                  title: 'Available Token Value',
                  value: _formatAmount(
                    stats['totalAvailableTokenValue'],
                  ),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF8A5AC2),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      height: 135,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }

  // =========================
  // SECTION HEADINGS
  // =========================

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // =========================
  // CATEGORY ERROR
  // =========================

  Widget _buildCategoryError() {
    return Container(
      height: 46,
      alignment: Alignment.centerLeft,
      child: Text(
        'Unable to load asset categories.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================
  // ASSET LIST
  // =========================

  Widget _buildAssetsList(
    List<Asset> assets,
    AssetsController controller,
  ) {
    if (assets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ...assets.map(
          (asset) => AssetCard(
            asset: asset,
            onTap: () {
              context.push('/assets/${asset.id}');
            },
          ),
        ),

        if (controller.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),

        if (!controller.hasMore && assets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              'You have reached the end of the marketplace.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  // =========================
  // LOADING STATE
  // =========================

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 55),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'No assets available yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Approved and tokenized assets will appear here when they become available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.primary,
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load marketplace',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(assetsControllerProvider.notifier)
                  .refreshAssets();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // NUMBER FORMATTING
  // =========================

  String _formatCount(dynamic value) {
    final number = _toNumber(value).toInt();
    return _addThousandsSeparators(number.toString());
  }

  String _formatAmount(dynamic value) {
    final number = _toNumber(value);
    final formatted = number.toStringAsFixed(2);
    final parts = formatted.split('.');

    return '${_addThousandsSeparators(parts[0])}.${parts[1]}';
  }

  num _toNumber(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _addThousandsSeparators(String value) {
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);

      final remaining = value.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}