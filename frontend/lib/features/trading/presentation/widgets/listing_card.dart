
import 'package:flutter/material.dart';

import '../../domain/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  final Listing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final assetName = _displayAssetName();
    final tokenCode = _displayTokenCode();
    final assetType = _formatAssetType(listing.assetType);
    final imageUrl = listing.primaryImageUrl;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(
              context,
              imageUrl,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          assetName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (assetType.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _TypeBadge(
                          label: assetType,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tokenCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoColumn(
                          label: 'Price per token',
                          value:
                              '${listing.currency} ${_formatDecimal(listing.pricePerToken)}',
                          valueColor: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoColumn(
                          label: 'Available',
                          value: _formatQuantity(
                            listing.remainingQuantity,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize:
                            const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context,
    String? imageUrl,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return _ImagePlaceholder(
        colorScheme: colorScheme,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _ImagePlaceholder(
            colorScheme: colorScheme,
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

          return _ImagePlaceholder(
            colorScheme: colorScheme,
            loading: true,
          );
        },
      ),
    );
  }

  String _displayAssetName() {
    final assetName = listing.assetName?.trim();

    if (assetName != null && assetName.isNotEmpty) {
      return assetName;
    }

    final tokenName = listing.token?.tokenName.trim();

    if (tokenName != null && tokenName.isNotEmpty) {
      return tokenName;
    }

    return 'Tokenized Asset';
  }

  String _displayTokenCode() {
    final tokenCode = listing.token?.tokenCode.trim();

    if (tokenCode != null && tokenCode.isNotEmpty) {
      return tokenCode;
    }

    return 'TOKEN-${listing.tokenId}';
  }

  String _formatAssetType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final normalized = value.trim();

    return normalized
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}'
                  '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
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

  String _formatQuantity(String value) {
    return _formatDecimal(value);
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              color:
                  colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.colorScheme,
    this.loading = false,
  });

  final ColorScheme colorScheme;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.image_outlined,
                size: 42,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

