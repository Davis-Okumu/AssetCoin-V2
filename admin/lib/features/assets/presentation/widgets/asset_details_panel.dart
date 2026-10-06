import 'package:flutter/material.dart';

import '../../data/models/admin_asset_details_model.dart';
import 'asset_status_badge.dart';

class AssetDetailsPanel extends StatelessWidget {
  const AssetDetailsPanel({super.key, required this.data});

  final AdminAssetDetailsModel data;

  @override
  Widget build(BuildContext context) {
    final asset = data.asset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverview(context, asset),

        const SizedBox(height: 20),

        _buildOwner(context, asset),

        const SizedBox(height: 20),

        _buildAssetInformation(context, asset),

        const SizedBox(height: 20),

        _buildPhotos(context),

        const SizedBox(height: 20),

        _buildDocuments(context),

        const SizedBox(height: 20),

        _buildValuations(context),

        const SizedBox(height: 20),

        _buildReviews(context),

        const SizedBox(height: 20),

        _buildStatusHistory(context),

        if (data.tokens.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildTokens(context),
        ],
      ],
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(BuildContext context, asset) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _assetIcon(asset.assetType),
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    asset.assetCode,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AssetStatusBadge(status: asset.status),
          ],
        ),
      ),
    );
  }

  Widget _buildOwner(BuildContext context, asset) {
    final owner = asset.owner;

    return _sectionCard(
      context: context,
      title: 'Asset Owner',
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            child: Text(_initials(owner?.firstName, owner?.lastName)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.ownerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (owner?.email != null) Text(owner!.email!),
                if (owner?.phone != null) Text(owner!.phone!),
              ],
            ),
          ),
          if (owner?.kycStatus != null)
            Chip(label: Text('KYC: ${_formatStatus(owner!.kycStatus!)}')),
        ],
      ),
    );
  }

  Widget _buildAssetInformation(BuildContext context, asset) {
    return _sectionCard(
      context: context,
      title: 'Asset Information',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700
              ? 3
              : constraints.maxWidth >= 450
              ? 2
              : 1;

          final fields = [
            _DetailField(
              label: 'Asset Type',
              value: _formatStatus(asset.assetType),
            ),
            _DetailField(
              label: 'Estimated Value',
              value: asset.estimatedValue == null
                  ? '—'
                  : '${asset.currency} ${asset.estimatedValue!.toStringAsFixed(2)}',
            ),
            _DetailField(
              label: 'Registration Number',
              value: asset.registrationNumber ?? '—',
            ),
            _DetailField(label: 'Location', value: asset.location ?? '—'),
            _DetailField(
              label: 'Latitude',
              value: asset.latitude?.toString() ?? '—',
            ),
            _DetailField(
              label: 'Longitude',
              value: asset.longitude?.toString() ?? '—',
            ),
            _DetailField(label: 'Created', value: asset.createdAt),
            _DetailField(label: 'Last Updated', value: asset.updatedAt ?? '—'),
            _DetailField(
              label: 'Review Notes',
              value: asset.reviewNotes ?? '—',
            ),
          ];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fields.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 20,
              mainAxisSpacing: 18,
              mainAxisExtent: 68,
            ),
            itemBuilder: (context, index) {
              return _DetailItem(field: fields[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotos(BuildContext context) {
    if (data.photos.isEmpty) {
      return _sectionCard(
        context: context,
        title: 'Asset Photos',
        child: const _EmptySection(message: 'No photos available.'),
      );
    }

    return _sectionCard(
      context: context,
      title: 'Asset Photos',
      trailing: Text('${data.photos.length} photos'),
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: data.photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final photo = data.photos[index];

            return Container(
              width: 180,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Image.network(
                photo.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(Icons.broken_image_outlined, size: 36),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocuments(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Documents',
      trailing: Text('${data.documents.length}'),
      child: data.documents.isEmpty
          ? const _EmptySection(message: 'No documents submitted.')
          : Column(
              children: data.documents
                  .map(
                    (document) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.description_outlined),
                      ),
                      title: Text(document.documentName),
                      subtitle: Text(
                        '${_formatStatus(document.documentType)} • ${_formatStatus(document.status)}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Open document',
                        onPressed: document.documentUrl == null
                            ? null
                            : () {
                                // Document navigation/download
                                // will be connected when the
                                // admin document endpoint is added.
                              },
                        icon: const Icon(Icons.open_in_new),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildValuations(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Valuations',
      trailing: Text('${data.valuations.length}'),
      child: data.valuations.isEmpty
          ? const _EmptySection(message: 'No valuations available.')
          : Column(
              children: data.valuations.map((valuation) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.price_check_outlined),
                  ),
                  title: Text(
                    '${valuation.currency} ${valuation.valuationAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${_formatStatus(valuation.valuationMethod)}${valuation.valuerName == null ? '' : ' • ${valuation.valuerName}'}',
                  ),
                  trailing: AssetStatusBadge(status: valuation.status),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildReviews(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Review History',
      trailing: Text('${data.reviews.length}'),
      child: data.reviews.isEmpty
          ? const _EmptySection(message: 'No reviews recorded yet.')
          : Column(
              children: data.reviews.map((review) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.rate_review_outlined),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.admin?.fullName ?? 'Administrator',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AssetStatusBadge(status: review.decision),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(review.comments ?? 'No comments provided.'),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildStatusHistory(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Status History',
      trailing: Text('${data.statusHistory.length}'),
      child: data.statusHistory.isEmpty
          ? const _EmptySection(message: 'No status history available.')
          : Column(
              children: data.statusHistory.map((history) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.history)),
                  title: Row(
                    children: [
                      if (history.previousStatus != null) ...[
                        AssetStatusBadge(status: history.previousStatus!),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, size: 16),
                        ),
                      ],
                      AssetStatusBadge(status: history.newStatus),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(history.changeReason ?? 'No reason provided.'),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTokens(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Tokenization',
      trailing: Text('${data.tokens.length}'),
      child: Column(
        children: data.tokens.map((token) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.token_outlined)),
            title: Text(
              token.tokenName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(token.tokenCode),
            trailing: token.status == null
                ? null
                : AssetStatusBadge(status: token.status!),
          );
        }).toList(),
      ),
    );
  }

  IconData _assetIcon(String type) {
    switch (type) {
      case 'land':
        return Icons.landscape_outlined;
      case 'livestock':
        return Icons.pets_outlined;
      case 'produce':
        return Icons.agriculture_outlined;
      case 'vehicle':
        return Icons.directions_car_outlined;
      case 'property':
        return Icons.home_work_outlined;
      case 'equipment':
        return Icons.construction_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _formatStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _initials(String? firstName, String? lastName) {
    final first = firstName?.trim().isNotEmpty == true
        ? firstName!.trim()[0]
        : '';

    final last = lastName?.trim().isNotEmpty == true ? lastName!.trim()[0] : '';

    return '$first$last'.toUpperCase();
  }
}

class _DetailField {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.field});

  final _DetailField field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          field.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
