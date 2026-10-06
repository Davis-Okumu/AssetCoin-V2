import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/assets_controller.dart';
import '../widgets/asset_filter_bar.dart';
import '../widgets/asset_summary_cards.dart';
import '../widgets/assets_table.dart';

class AssetsPage extends ConsumerWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(assetsControllerProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),

                const SizedBox(height: 24),

                assetsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => _buildError(context, ref, error),
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AssetSummaryCards(data: data),

                      const SizedBox(height: 24),

                      AssetFilterBar(
                        onSearchChanged: (value) {
                          ref
                              .read(assetsControllerProvider.notifier)
                              .setSearch(value);
                        },
                        onStatusChanged: (value) {
                          ref
                              .read(assetsControllerProvider.notifier)
                              .setStatus(value);
                        },
                        onAssetTypeChanged: (value) {
                          ref
                              .read(assetsControllerProvider.notifier)
                              .setAssetType(value);
                        },
                        onClear: () {
                          ref
                              .read(assetsControllerProvider.notifier)
                              .clearFilters();
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTableHeader(context, data),

                      const SizedBox(height: 12),

                      AssetsTable(data: data),

                      const SizedBox(height: 16),

                      _buildPagination(context, ref, data),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Management',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Review, verify and manage assets submitted by AssetCoin users.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(assetsControllerProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context, dynamic data) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Assets',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${data.pagination.total} total',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, WidgetRef ref, dynamic data) {
    final controller = ref.read(assetsControllerProvider.notifier);

    final pagination = data.pagination;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          pagination.total == 0
              ? 'No results'
              : 'Page ${pagination.page} of ${pagination.totalPages}',
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Previous page',
          onPressed: pagination.page > 1 ? controller.previousPage : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: pagination.page < pagination.totalPages
              ? controller.nextPage
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 52),
            const SizedBox(height: 12),
            const Text(
              'Unable to load assets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ref.read(assetsControllerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
