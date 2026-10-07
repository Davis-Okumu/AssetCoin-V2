import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_listing_model.dart';
import '../controllers/admin_trading_listing_details_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingListingDetailsPage extends ConsumerWidget {
  const TradingListingDetailsPage({super.key, required this.listingId});

  final int listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      adminTradingListingDetailsControllerProvider(listingId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(
                          adminTradingListingDetailsControllerProvider(
                            listingId,
                          ).notifier,
                        )
                        .refresh();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref
                  .read(
                    adminTradingListingDetailsControllerProvider(listingId)
                        .notifier,
                  )
                  .refresh();
            },
          );
        },
        data: (listing) {
          return _ListingDetailsContent(
            listing: listing,
            onSuspend: listing.canSuspend
                ? () => _suspendListing(context, ref, listing)
                : null,
            onReactivate: listing.canReactivate
                ? () => _reactivateListing(context, ref, listing)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _suspendListing(
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
              children: [
                Text('Suspend ${listing.tokenDisplayName}?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter the reason for suspension',
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

      await ref
          .read(
            adminTradingListingDetailsControllerProvider(listing.id).notifier,
          )
          .suspend(
            reason: reasonController.text.trim().isEmpty
                ? null
                : reasonController.text.trim(),
          );

      if (!context.mounted) {
        return;
      }

      final currentState = ref.read(
        adminTradingListingDetailsControllerProvider(listing.id),
      );

      if (currentState.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(currentState.error.toString())));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing suspended successfully.')),
      );
    } finally {
      reasonController.dispose();
    }
  }

  Future<void> _reactivateListing(
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
              children: [
                Text('Reactivate ${listing.tokenDisplayName}?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter the reason for reactivation',
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

      await ref
          .read(
            adminTradingListingDetailsControllerProvider(listing.id).notifier,
          )
          .reactivate(
            reason: reasonController.text.trim().isEmpty
                ? null
                : reasonController.text.trim(),
          );

      if (!context.mounted) {
        return;
      }

      final currentState = ref.read(
        adminTradingListingDetailsControllerProvider(listing.id),
      );

      if (currentState.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(currentState.error.toString())));
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

class _ListingDetailsContent extends StatelessWidget {
  const _ListingDetailsContent({
    required this.listing,
    this.onSuspend,
    this.onReactivate,
  });

  final AdminTradingListingModel listing;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                listing: listing,
                onSuspend: onSuspend,
                onReactivate: onReactivate,
              ),
              const SizedBox(height: 20),
              _OverviewSection(listing: listing),
              const SizedBox(height: 20),
              _TokenSection(listing: listing),
              const SizedBox(height: 20),
              _AssetSection(listing: listing),
              const SizedBox(height: 20),
              _SellerSection(listing: listing),
              const SizedBox(height: 20),
              _TimestampsSection(listing: listing),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.listing, this.onSuspend, this.onReactivate});

  final AdminTradingListingModel listing;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.tokenDisplayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.assetDisplayName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TradingStatusBadge(status: _safeString(listing.status)),
                ],
              ),
            ),
            if (onSuspend != null || onReactivate != null) ...[
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (onSuspend != null)
                    FilledButton.icon(
                      onPressed: onSuspend,
                      icon: const Icon(Icons.pause_circle_outline),
                      label: const Text('Suspend'),
                    ),
                  if (onReactivate != null)
                    FilledButton.icon(
                      onPressed: onReactivate,
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Reactivate'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.listing});

  final AdminTradingListingModel listing;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Listing Overview',
      icon: Icons.info_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Listing ID', value: '#${listing.id}'),
            _DetailItem(label: 'Listing Type', value: listing.listingTypeLabel),
            _DetailItem(label: 'Status', value: listing.statusLabel),
            _DetailItem(
              label: 'Currency',
              value: _safeString(listing.currency),
            ),
            _DetailItem(
              label: 'Quantity',
              value: _safeString(listing.quantity),
            ),
            _DetailItem(
              label: 'Remaining Quantity',
              value: _safeString(listing.remainingQuantity),
            ),
            _DetailItem(
              label: 'Price Per Token',
              value:
                  '${_safeString(listing.currency)} '
                  '${_safeString(listing.pricePerToken)}',
            ),
            _DetailItem(label: 'Seller ID', value: listing.sellerId.toString()),
          ],
        ),
      ],
    );
  }
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({required this.listing});

  final AdminTradingListingModel listing;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Token Information',
      icon: Icons.token_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Token ID', value: listing.tokenId.toString()),
            _DetailItem(
              label: 'Token Name',
              value: _safeString(listing.tokenName),
            ),
            _DetailItem(
              label: 'Token Code',
              value: _safeString(listing.tokenCode),
            ),
            _DetailItem(
              label: 'Token Status',
              value: _safeString(listing.tokenStatus),
            ),
            _DetailItem(
              label: 'Total Supply',
              value: _safeString(listing.totalSupply),
            ),
            _DetailItem(
              label: 'Available Supply',
              value: _safeString(listing.availableSupply),
            ),
          ],
        ),
      ],
    );
  }
}

class _AssetSection extends StatelessWidget {
  const _AssetSection({required this.listing});

  final AdminTradingListingModel listing;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Underlying Asset',
      icon: Icons.account_balance_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Asset ID', value: listing.assetId.toString()),
            _DetailItem(
              label: 'Asset Name',
              value: _safeString(listing.assetName),
            ),
            _DetailItem(
              label: 'Asset Code',
              value: _safeString(listing.assetCode),
            ),
            _DetailItem(
              label: 'Asset Type',
              value: _safeString(listing.assetType),
            ),
            _DetailItem(
              label: 'Asset Status',
              value: _safeString(listing.assetStatus),
            ),
          ],
        ),
      ],
    );
  }
}

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.listing});

  final AdminTradingListingModel listing;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Seller Information',
      icon: Icons.person_outline,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(label: 'Seller ID', value: listing.sellerId.toString()),
            _DetailItem(label: 'Name', value: listing.sellerName),
            _DetailItem(
              label: 'Email',
              value: _safeString(listing.sellerEmail),
            ),
            _DetailItem(
              label: 'Phone',
              value: _safeString(listing.sellerPhone),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimestampsSection extends StatelessWidget {
  const _TimestampsSection({required this.listing});

  final AdminTradingListingModel listing;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Listing Timeline',
      icon: Icons.schedule_outlined,
      children: [
        _DetailGrid(
          children: [
            _DetailItem(
              label: 'Created',
              value: _formatDate(listing.createdAt),
            ),
            _DetailItem(
              label: 'Updated',
              value: _formatDate(listing.updatedAt),
            ),
            _DetailItem(
              label: 'Expires',
              value: _formatDate(listing.expiresAt),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 18,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              'Unable to load listing',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
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
      ),
    );
  }
}

String _safeString(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '—';
  }

  return value;
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  return '${local.year}-'
      '${twoDigits(local.month)}-'
      '${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)}';
}
