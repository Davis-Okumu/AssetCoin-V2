
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../providers/asset_providers.dart';

class SubmissionDetailsPage extends ConsumerWidget {
  const SubmissionDetailsPage({
    super.key,
    required this.assetId,
  });

  final int assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState =
        ref.watch(myAssetSubmissionDetailsProvider(assetId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submission Details'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(myAssetSubmissionDetailsProvider(assetId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: submissionState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildError(ref, error),
data: (submission) => _buildContent(ref, submission),
      ),
    );
  }

  Widget _buildContent(
  WidgetRef ref,
  Map<String, dynamic> submission,
) {
    final photos = _asList(submission['photos']);
    final documents = _asList(submission['documents']);

    return RefreshIndicator(
onRefresh: () async {
  ref.invalidate(myAssetSubmissionDetailsProvider(assetId));
  await ref.read(myAssetSubmissionDetailsProvider(assetId).future);
},
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatusCard(submission),
          const SizedBox(height: 24),

          _buildSectionTitle('Asset Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _infoRow('Asset name', _value(submission['name'])),
            _infoRow('Asset code', _value(submission['assetCode'])),
            _infoRow('Category', _formatCategory(submission['assetType'])),
            _infoRow('Location', _value(submission['location'])),
            _infoRow(
              'Estimated value',
              _formatMoney(
                submission['estimatedValue'],
                submission['currency'],
              ),
            ),
            _infoRow('Registration number',
                _value(submission['registrationNumber'])),
            _infoRow('Description', _value(submission['description'])),
          ]),
          const SizedBox(height: 24),

          _buildSectionTitle('Review Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _infoRow('Current status', _formatStatus(submission['status'])),
            _infoRow(
              'Date submitted',
              _formatDate(submission['createdAt']),
            ),
            _infoRow(
              'Last updated',
              _formatDate(submission['updatedAt']),
            ),
          ]),
          if (_value(submission['rejectionReason']) != 'Not provided') ...[
            const SizedBox(height: 24),
            _buildFeedbackCard(submission['rejectionReason'].toString()),
          ],
          const SizedBox(height: 24),

          _buildSectionTitle('Asset Photos'),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            _buildEmptyMessage('No photos have been uploaded.')
          else
            _buildPhotos(photos),
          const SizedBox(height: 24),

          _buildSectionTitle('Submitted Documents'),
          const SizedBox(height: 12),
          if (documents.isEmpty)
            _buildEmptyMessage('No documents have been uploaded.')
          else
            ...documents.map(_buildDocumentCard),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> submission) {
    final status = _value(submission['status']);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUBMISSION STATUS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatStatus(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _statusDescription(status),
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              _formatStatus(status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Review Feedback',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reason,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos(List<dynamic> photos) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final photo = _asMap(photos[index]);
          final photoUrl = _value(photo['photoUrl']);

          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 190,
              color: Colors.grey.shade200,
              child: photoUrl == 'Not provided'
                  ? const Icon(Icons.image_not_supported_outlined)
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 35,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(dynamic document) {
    final data = _asMap(document);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _value(data['documentName']),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatCategory(data['documentType'])} • '
                  '${_formatStatus(_value(data['status']))}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(data['createdAt']),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildError(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load submission details',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(myAssetSubmissionDetailsProvider(assetId));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not provided';
    }
    return value.toString();
  }

  String _formatCategory(dynamic value) {
    final text = _value(value);
    if (text == 'Not provided') return text;

    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _statusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your asset submission has been received and is awaiting review.';
      case 'under_review':
        return 'Your asset is currently being reviewed.';
      case 'changes_required':
        return 'Changes or additional information may be required for this submission.';
      case 'approved':
        return 'Your asset has been approved and is awaiting the next processing stage.';
      case 'rejected':
        return 'This submission was not approved. Review the feedback provided below.';
      case 'tokenized':
        return 'Your asset has been tokenized and is part of the marketplace.';
      case 'suspended':
        return 'This asset submission is currently suspended.';
      default:
        return 'View the information and current status of your asset submission.';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'tokenized':
        return Colors.green;
      case 'rejected':
      case 'suspended':
        return Colors.red;
      case 'under_review':
      case 'changes_required':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatMoney(dynamic amount, dynamic currency) {
    if (amount == null) return 'Not provided';

    final currencyCode = _value(currency);
    return '$currencyCode ${amount.toString()}';
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Not provided';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  List<dynamic> _asList(dynamic value) {
    return value is List ? value : [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return {};
  }

}