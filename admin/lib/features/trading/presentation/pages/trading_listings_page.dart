import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_listing_model.dart';
import '../controllers/admin_trading_listings_controller.dart';
import '../widgets/trading_filter_bar.dart';
import '../widgets/trading_listing_table.dart';

class TradingListingsPage extends ConsumerWidget {
  const TradingListingsPage({super.key, this.onOpenListing});

  final ValueChanged<int>? onOpenListing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(adminTradingListingsControllerProvider);

    final controller = ref.read(
      adminTradingListingsControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Listings'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: listingsState.isLoading ? null : controller.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(onRefresh: controller.refresh),
            const SizedBox(height: 20),
            TradingFilterBar(
              initialSearch: controller.searchQuery,
              initialStatus: controller.statusFilter,
              initialListingType: controller.listingTypeFilter,
              onSearch: controller.search,
              onStatusChanged: controller.setStatus,
              onListingTypeChanged: controller.setListingType,
              onClear: controller.clearFilters,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: listingsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  return _ErrorView(
                    message: error.toString(),
                    onRetry: controller.refresh,
                  );
                },
                data: (result) {
                  if (result.isEmpty) {
                    return _EmptyListings(
                      hasFilters:
                          controller.searchQuery != null ||
                          controller.statusFilter != null ||
                          controller.listingTypeFilter != null,
                      onClear: controller.clearFilters,
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: TradingListingTable(
                          items: result.items,
                          onOpen: (listing) {
                            _openListing(context, listing);
                          },
                          onSuspend: (listing) {
                            _confirmSuspend(context, ref, listing);
                          },
                          onReactivate: (listing) {
                            _confirmReactivate(context, ref, listing);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PaginationBar(
                        page: result.page,
                        totalPages: result.totalPages,
                        total: result.total,
                        pageSize: result.limit,
                        onPrevious: result.hasPreviousPage
                            ? controller.previousPage
                            : null,
                        onNext: result.hasNextPage ? controller.nextPage : null,
                        onPageSizeChanged: controller.setPageSize,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openListing(BuildContext context, AdminTradingListingModel listing) {
    if (onOpenListing != null) {
      onOpenListing!(listing.id);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(listing.tokenDisplayName),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow(label: 'Listing ID', value: '#${listing.id}'),
                  _DetailRow(label: 'Asset', value: listing.assetDisplayName),
                  _DetailRow(label: 'Seller', value: listing.sellerName),
                  _DetailRow(
                    label: 'Listing type',
                    value: listing.listingTypeLabel,
                  ),
                  _DetailRow(label: 'Quantity', value: listing.quantity),
                  _DetailRow(
                    label: 'Remaining',
                    value: listing.remainingQuantity,
                  ),
                  _DetailRow(
                    label: 'Price per token',
                    value: '${listing.currency} ${listing.pricePerToken}',
                  ),
                  _DetailRow(label: 'Status', value: listing.statusLabel),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSuspend(
    BuildContext context,
    WidgetRef ref,
    AdminTradingListingModel listing,
  ) async {
    final reasonController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Suspend Listing'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to suspend '
                  '${listing.tokenDisplayName}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter a reason for suspension',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Suspend'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      final controller = ref.read(
        adminTradingListingsControllerProvider.notifier,
      );

      await controller.suspendListing(
        listing.id,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing suspended successfully.')),
      );
    } finally {
      reasonController.dispose();
    }
  }

  Future<void> _confirmReactivate(
    BuildContext context,
    WidgetRef ref,
    AdminTradingListingModel listing,
  ) async {
    final reasonController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Reactivate Listing'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to reactivate '
                  '${listing.tokenDisplayName}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter a reason for reactivation',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Reactivate'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      final controller = ref.read(
        adminTradingListingsControllerProvider.notifier,
      );

      await controller.reactivateListing(
        listing.id,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing reactivated successfully.')),
      );
    } finally {
      reasonController.dispose();
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marketplace Listings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor, review and manage marketplace listings.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}

class _EmptyListings extends StatelessWidget {
  const _EmptyListings({required this.hasFilters, required this.onClear});

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off_outlined : Icons.list_alt_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No listings found' : 'No listings available',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'No listings match the selected filters.'
                : 'There are currently no marketplace listings.',
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56),
          const SizedBox(height: 16),
          Text(
            'Unable to load listings',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  final int page;
  final int totalPages;
  final int total;
  final int pageSize;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(
              'Page $page of ${totalPages == 0 ? 1 : totalPages}'
              ' • $total total',
            ),
            const Spacer(),
            const Text('Rows:'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: [10, 20, 50, 100].contains(pageSize) ? pageSize : 20,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 20, child: Text('20')),
                DropdownMenuItem(value: 50, child: Text('50')),
                DropdownMenuItem(value: 100, child: Text('100')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onPageSizeChanged(value);
                }
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Previous page',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('$page', style: const TextStyle(fontWeight: FontWeight.w600)),
            IconButton(
              tooltip: 'Next page',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
