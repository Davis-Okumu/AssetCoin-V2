
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/asset.dart';
import '../providers/asset_providers.dart';
import '../widgets/asset_price_chart.dart';

class AssetDetailsPage extends ConsumerWidget {
  const AssetDetailsPage({
    super.key,
    required this.assetId,
  });

  final int assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetDetailsProvider(assetId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'Asset Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(assetDetailsProvider(assetId));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh asset',
          ),
        ],
      ),
      body: assetState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stackTrace) => _buildError(context, ref),
        data: (asset) => _buildDetails(context, ref, asset),
      ),
    );
  }

  // =========================
  // ASSET DETAILS
  // =========================

  Widget _buildDetails(
    BuildContext context,
    WidgetRef ref,
    Asset asset,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(assetDetailsProvider(assetId));
        await ref.read(assetDetailsProvider(assetId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(asset),

            const SizedBox(height: 22),

            _buildAssetHeading(asset),

            const SizedBox(height: 22),

            _buildEstimatedValue(asset),

            const SizedBox(height: 24),

            _buildSectionTitle('Asset Information'),

            const SizedBox(height: 12),

            _buildAssetInformation(asset),

            if (asset.token != null) ...[
              const SizedBox(height: 25),

              _buildSectionTitle('Token Information'),

              const SizedBox(height: 12),

              _buildTokenInformation(asset.token!),
            ],

            const SizedBox(height: 25),

            _buildSectionTitle('Price History'),

            const SizedBox(height: 12),

            AssetPriceChart(
              priceHistory: asset.priceHistory,
            ),

            if (asset.createdAt != null) ...[
              const SizedBox(height: 22),
              _buildCreatedDate(asset.createdAt!),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // IMAGE GALLERY
  // =========================

  Widget _buildImageGallery(Asset asset) {
    final photos = asset.photos
        .where((photo) => photo.photoUrl.isNotEmpty)
        .toList()
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) {
          return a.isPrimary ? -1 : 1;
        }

        return a.displayOrder.compareTo(b.displayOrder);
      });

    final imageUrls = photos.isNotEmpty
        ? photos.map((photo) => photo.photoUrl).toList()
        : asset.primaryPhoto != null &&
                asset.primaryPhoto!.isNotEmpty
            ? [asset.primaryPhoto!]
            : <String>[];

    if (imageUrls.isEmpty) {
      return _imagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 235,
        child: PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 235,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 55,
        color: Color(0xFF9AA9BE),
      ),
    );
  }

  // =========================
  // ASSET HEADING
  // =========================

  Widget _buildAssetHeading(Asset asset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBadge(
              asset.assetType.toUpperCase(),
              AppColors.primary,
            ),
            const SizedBox(width: 8),
            if (asset.token != null)
              _buildBadge(
                'TOKENIZED',
                const Color(0xFF16834A),
              ),
          ],
        ),

        const SizedBox(height: 13),

        Text(
          asset.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        if (asset.location != null &&
            asset.location!.isNotEmpty)
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  asset.location!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 7),

        Text(
          'Asset Code: ${asset.assetCode}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // =========================
  // ESTIMATED VALUE
  // =========================

  Widget _buildEstimatedValue(Asset asset) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFFB51F32),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMATED ASSET VALUE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            _formatCurrency(
              asset.estimatedValue,
              asset.currency,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (asset.token != null) ...[
            const SizedBox(height: 13),
            const Divider(
              color: Colors.white30,
              height: 1,
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Token Price',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Text(
                  _formatCurrency(
                    asset.token!.tokenPrice,
                    asset.token!.currency,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // ASSET INFORMATION
  // =========================

  Widget _buildAssetInformation(Asset asset) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _informationRow('Asset Name', asset.name),
          _informationDivider(),

          _informationRow(
            'Category',
            _capitalize(asset.assetType),
          ),
          _informationDivider(),

          _informationRow('Asset Code', asset.assetCode),
          _informationDivider(),

          _informationRow(
            'Location',
            asset.location ?? 'Not provided',
          ),
          _informationDivider(),

          _informationRow(
            'Registration Number',
            asset.registrationNumber ?? 'Not provided',
          ),
          _informationDivider(),

          _informationRow('Currency', asset.currency),
          _informationDivider(),

          _informationRow(
            'Status',
            _capitalize(asset.status ?? 'Available'),
          ),

          if (asset.latitude != null &&
              asset.longitude != null) ...[
            _informationDivider(),
            _informationRow(
              'Coordinates',
              '${asset.latitude}, ${asset.longitude}',
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // TOKEN INFORMATION
  // =========================

  Widget _buildTokenInformation(AssetToken token) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _informationRow('Token Name', token.tokenName),
          _informationDivider(),

          _informationRow('Token Code', token.tokenCode),
          _informationDivider(),

          _informationRow(
            'Total Supply',
            _formatQuantity(token.totalSupply),
          ),
          _informationDivider(),

          _informationRow(
            'Available Supply',
            _formatQuantity(token.availableSupply),
          ),
          _informationDivider(),

          _informationRow(
            'Token Price',
            _formatCurrency(
              token.tokenPrice,
              token.currency,
            ),
          ),
          _informationDivider(),

          _informationRow('Token Currency', token.currency),
          _informationDivider(),

          _informationRow(
            'Token Status',
            _capitalize(token.status),
          ),

          if (token.decimals != null) ...[
            _informationDivider(),
            _informationRow(
              'Decimal Places',
              token.decimals.toString(),
            ),
          ],

          if (token.mintedAt != null) ...[
            _informationDivider(),
            _informationRow(
              'Minted Date',
              _formatDate(token.mintedAt!),
            ),
          ],

          if (token.description != null &&
              token.description!.isNotEmpty) ...[
            _informationDivider(),
            _informationRow(
              'Description',
              token.description!,
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // SECTION TITLES
  // =========================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _informationRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  // =========================
  // CREATED DATE
  // =========================

  Widget _buildCreatedDate(DateTime date) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Asset registered on ${_formatDate(date)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load asset details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'The asset may be unavailable or your connection may have been interrupted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(assetDetailsProvider(assetId));
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
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    );
  }

  String _formatCurrency(double value, String currency) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');

    return '$currency ${_addThousandsSeparators(parts[0])}.${parts[1]}';
  }

  String _formatQuantity(double value) {
    return _addThousandsSeparators(
      value.toStringAsFixed(2).split('.').first,
    );
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

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1).replaceAll('_', ' ');
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}