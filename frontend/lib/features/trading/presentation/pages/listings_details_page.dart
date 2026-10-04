
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/listing.dart';
import '../../domain/token.dart';
import '../controllers/marketplace_controller.dart';

class ListingDetailsPage extends ConsumerWidget {
  final int listingId;

  const ListingDetailsPage({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listingId <= 0) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Invalid listing identifier.',
          ),
        ),
      );
    }

    final listingDetails = ref.watch(
      listingDetailsProvider(listingId),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Listing Details'),
        centerTitle: false,
      ),
      body: listingDetails.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(
              listingDetailsProvider(listingId),
            );
          },
        ),
        data: (listing) {
          return _ListingDetailsContent(
            listing: listing,
            onBuy: () {
              context.push(
                '/trading/listings/$listingId/buy',
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// LISTING DETAILS PROVIDER
// ============================================================

final listingDetailsProvider = FutureProvider.family
    .autoDispose<Listing, int>((ref, listingId) async {
  final controller = ref.read(
    marketplaceControllerProvider.notifier,
  );

  return controller.getListingDetails(listingId);
});

// ============================================================
// CONTENT
// ============================================================

class _ListingDetailsContent extends StatelessWidget {
  final Listing listing;
  final VoidCallback onBuy;

  const _ListingDetailsContent({
    required this.listing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final token = listing.token;

    final assetName = _assetName(listing, token);
    final tokenCode = _tokenCode(listing, token);
    final assetType = _displayAssetType(
      listing.assetType,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(
            context,
            listing,
            assetName,
          ),

          const SizedBox(height: 20),

          _buildTitleSection(
            context,
            assetName: assetName,
            tokenCode: tokenCode,
            assetType: assetType,
            status: listing.status,
          ),

          const SizedBox(height: 20),

          _buildTradingCard(
            context,
            listing,
          ),

          const SizedBox(height: 16),

          _buildAssetInformation(
            context,
            listing,
          ),

          const SizedBox(height: 16),

          if (_hasDescription(listing, token))
            _buildDescription(
              context,
              listing,
              token,
            ),

          if (_hasLocation(listing))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildLocation(
                context,
                listing,
              ),
            ),

          const SizedBox(height: 24),

          _buildBuyButton(
            context,
            listing,
            onBuy,
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Transactions are subject to marketplace '
              'availability and account requirements.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO IMAGE
  // ============================================================

  Widget _buildHeroImage(
    BuildContext context,
    Listing listing,
    String assetName,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final imageUrl = listing.primaryImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _ImagePlaceholder(
                    assetName: assetName,
                  );
                },
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
            : _ImagePlaceholder(
                assetName: assetName,
              ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitleSection(
    BuildContext context, {
    required String assetName,
    required String tokenCode,
    required String assetType,
    required String status,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                assetName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(
              status: status,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.token_rounded,
              label: tokenCode,
            ),
            if (assetType.isNotEmpty)
              _InfoChip(
                icon: Icons.category_rounded,
                label: assetType,
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TRADING CARD
  // ============================================================

  Widget _buildTradingCard(
    BuildContext context,
    Listing listing,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final currency = listing.currency.isEmpty
        ? 'KES'
        : listing.currency;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Listing',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                  color: colorScheme.onPrimary.withValues(
                    alpha: 0.8,
                  ),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$currency ${listing.pricePerToken}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(
                'per token',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: colorScheme.onPrimary.withValues(
                        alpha: 0.8,
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: colorScheme.onPrimary.withValues(
              alpha: 0.18,
            ),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TradingMetric(
                  label: 'Available',
                  value: listing.remainingQuantity,
                  color: colorScheme.onPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: colorScheme.onPrimary.withValues(
                  alpha: 0.18,
                ),
              ),
              Expanded(
                child: _TradingMetric(
                  label: 'Total Listed',
                  value: listing.quantity,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSET INFORMATION
  // ============================================================

  Widget _buildAssetInformation(
    BuildContext context,
    Listing listing,
  ) {
    final token = listing.token;

    final tokenName = token?.tokenName ??
        listing.assetName ??
        'Tokenized Asset';

    final tokenCode = _tokenCode(
      listing,
      token,
    );

    return _SectionCard(
      title: 'Asset & Token Information',
      icon: Icons.account_balance_rounded,
      children: [
        _DetailRow(
          label: 'Asset',
          value: listing.assetName ??
              'Tokenized Asset',
        ),
        _DetailRow(
          label: 'Asset Type',
          value: _displayAssetType(
            listing.assetType,
          ),
        ),
        _DetailRow(
          label: 'Token',
          value: tokenName,
        ),
        _DetailRow(
          label: 'Token Code',
          value: tokenCode,
        ),
        if (token != null)
          _DetailRow(
            label: 'Token Supply',
            value: token.totalSupply,
          ),
        if (token != null)
          _DetailRow(
            label: 'Token Decimals',
            value: token.decimals.toString(),
          ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription(
    BuildContext context,
    Listing listing,
    Token? token,
  ) {
    final description =
        listing.assetDescription ??
        token?.description;

    if (description == null ||
        description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      children: [
        Text(
          description.trim(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                height: 1.6,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Widget _buildLocation(
    BuildContext context,
    Listing listing,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.place_outlined,
              size: 22,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                listing.assetLocation!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BUY BUTTON
  // ============================================================

  Widget _buildBuyButton(
    BuildContext context,
    Listing listing,
    VoidCallback onBuy,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

final canBuy =
    listing.remainingQuantity.trim().isNotEmpty &&
    (listing.status == 'active' ||
        listing.status == 'partially_filled');

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: canBuy ? onBuy : null,
        icon: const Icon(
          Icons.shopping_cart_checkout_rounded,
        ),
        label: const Text(
          'Buy Tokens',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _assetName(
    Listing listing,
    Token? token,
  ) {
    final name = listing.assetName;

    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    final tokenName = token?.tokenName;

    if (tokenName != null &&
        tokenName.trim().isNotEmpty) {
      return tokenName.trim();
    }

    return 'Tokenized Asset';
  }

  String _tokenCode(
    Listing listing,
    Token? token,
  ) {
    final code = token?.tokenCode;

    if (code != null && code.trim().isNotEmpty) {
      return code.trim();
    }

    return 'TOKEN-${listing.tokenId}';
  }

  String _displayAssetType(
    String? assetType,
  ) {
    if (assetType == null ||
        assetType.trim().isEmpty) {
      return 'Asset';
    }

    final normalized = assetType.trim();

    switch (normalized.toLowerCase()) {
      case 'land':
        return 'Land';
      case 'livestock':
        return 'Livestock';
      case 'produce':
        return 'Produce';
      case 'property':
        return 'Property';
      case 'vehicle':
        return 'Vehicle';
      case 'equipment':
        return 'Equipment';
      case 'other':
        return 'Other';
      default:
        return normalized;
    }
  }

  bool _hasDescription(
    Listing listing,
    Token? token,
  ) {
    final description =
        listing.assetDescription ??
        token?.description;

    return description != null &&
        description.trim().isNotEmpty;
  }

  bool _hasLocation(
    Listing listing,
  ) {
    return listing.assetLocation != null &&
        listing.assetLocation!.trim().isNotEmpty;
  }
}

// ============================================================
// IMAGE PLACEHOLDER
// ============================================================

class _ImagePlaceholder extends StatelessWidget {
  final String assetName;

  const _ImagePlaceholder({
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: 56,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                assetName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TRADING METRIC
// ============================================================

class _TradingMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TradingMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: color.withValues(
                    alpha: 0.72,
                  ),
                ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final normalized = status.toLowerCase();

    final isAvailable =
        normalized == 'active' ||
        normalized == 'partially_filled';

    final background = isAvailable
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final foreground = isAvailable
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final label = _statusLabel(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'active':
        return 'ACTIVE';
      case 'partially_filled':
        return 'PARTIALLY FILLED';
      case 'filled':
        return 'FILLED';
      case 'cancelled':
        return 'CANCELLED';
      case 'expired':
        return 'EXPIRED';
      case 'suspended':
        return 'SUSPENDED';
      default:
        return value
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
              'Unable to load listing',
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
              'The listing details could not be loaded. '
              'Please try again.',
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
              onPressed: onRetry,
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
}
