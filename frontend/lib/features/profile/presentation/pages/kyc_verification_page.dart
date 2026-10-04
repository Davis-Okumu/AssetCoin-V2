
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/kyc_submission.dart';
import '../../data/models/kyc_status.dart';
import '../providers/profile_providers.dart';

class KycVerificationPage extends ConsumerStatefulWidget {
  const KycVerificationPage({
    super.key,
  });

  @override
  ConsumerState<KycVerificationPage> createState() =>
      _KycVerificationPageState();
}

class _KycVerificationPageState
    extends ConsumerState<KycVerificationPage> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _idDocumentPath;
  String? _idDocumentName;

  String? _selfiePath;
  String? _selfieName;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(kycStatusProvider);
    final historyAsync = ref.watch(kycHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('KYC & Verification'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kycStatusProvider);
          ref.invalidate(kycHistoryProvider);

          await Future.wait([
            ref.read(kycStatusProvider.future),
            ref.read(kycHistoryProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ),
          children: [
            _buildIntroCard(context),

            const SizedBox(height: 20),

            statusAsync.when(
              loading: () => const _LoadingCard(),
              error: (error, _) => _ErrorCard(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(kycStatusProvider);
                },
              ),
              data: (status) => _buildStatusCard(
                context,
                status,
              ),
            ),

            const SizedBox(height: 20),

            statusAsync.when(
              data: (status) {
                if (status.isVerified) {
                  return _buildVerifiedCard(context);
                }

                if (status.isProcessing) {
                  return _buildProcessingCard(
                    context,
                    status,
                  );
                }

                return _buildSubmissionSection(
                  context,
                  status,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            _buildVerificationRequirements(context),

            const SizedBox(height: 24),

            _buildHistorySection(
              context,
              historyAsync,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47C9),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 36,
          ),
          SizedBox(height: 14),
          Text(
            'Verify your identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete identity verification to access '
            'AssetCoin features that require a verified account.',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    KycStatus status,
  ) {
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Verification status',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _statusDescription(status),
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
          if (status.rejectionReason != null &&
              status.rejectionReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.red.shade100,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status.rejectionReason!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status.submittedAt != null) ...[
            const SizedBox(height: 14),
            _InfoRow(
              label: 'Submitted',
              value: _formatDate(status.submittedAt!),
            ),
          ],
          if (status.verifiedAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Verified',
              value: _formatDate(status.verifiedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionSection(
    BuildContext context,
    KycStatus status,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submit verification',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status.isRejected
                ? 'Your previous application was rejected. '
                    'Review the reason above and submit new documents.'
                : 'Provide your identity document and a selfie '
                    'to submit your verification application.',
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          _buildDocumentPicker(context),

          const SizedBox(height: 14),

          _buildSelfiePicker(context),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitKyc,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.verified_user_rounded,
                    ),
              label: Text(
                _isSubmitting
                    ? 'Submitting...'
                    : 'Submit for Verification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPicker(BuildContext context) {
    return _UploadTile(
      icon: Icons.description_outlined,
      title: 'Identity document',
      subtitle:
          _idDocumentName ?? 'Choose an ID image or PDF document',
      selected: _idDocumentPath != null,
      onTap: _chooseIdentityDocument,
    );
  }

  Widget _buildSelfiePicker(BuildContext context) {
    return _UploadTile(
      icon: Icons.face_retouching_natural_rounded,
      title: 'Verification selfie',
      subtitle:
          _selfieName ?? 'Take a clear selfie for identity verification',
      selected: _selfiePath != null,
      onTap: _takeSelfie,
    );
  }

  Widget _buildProcessingCard(
    BuildContext context,
    KycStatus status,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD875),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: Color(0xFFB77900),
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isUnderReview
                      ? 'Your application is under review'
                      : 'Your application is being processed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You do not need to submit another application '
                  'while this verification is being processed.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9BD7B1),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF168447),
            size: 30,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity verified',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your identity has been successfully verified.',
                  style: TextStyle(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRequirements(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What you need',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _RequirementTile(
          icon: Icons.badge_outlined,
          title: 'Valid identity document',
          subtitle: 'Upload a supported ID image or PDF.',
        ),
        const SizedBox(height: 10),
        _RequirementTile(
          icon: Icons.face_rounded,
          title: 'Clear selfie',
          subtitle:
              'Use a clear photo of yourself for verification.',
        ),
        const SizedBox(height: 10),
        _RequirementTile(
          icon: Icons.visibility_rounded,
          title: 'Readable information',
          subtitle:
              'Make sure your submitted document is clear and readable.',
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    AsyncValue<List<KycSubmission>> historyAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submission history',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const _LoadingCard(),
          error: (error, _) => _ErrorCard(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(kycHistoryProvider);
            },
          ),
          data: (history) {
            if (history.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'No previous KYC submissions.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }

            return Column(
              children: history
                  .map(
                    (submission) =>
                        _buildHistoryItem(submission),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    KycSubmission submission,
  ) {
    final color = _historyStatusColor(submission);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _historyStatusIcon(submission),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submission #${submission.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (submission.submittedAt != null)
                  Text(
                    _formatDate(submission.submittedAt!),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          _HistoryStatusBadge(
            text: submission.readableStatus,
            color: color,
          ),
        ],
      ),
    );
  }

Future<void> _chooseIdentityDocument() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'pdf',
    ],
  );

  if (file == null) {
    return;
  }

  final path = file.path;

  if (path == null || path.trim().isEmpty) {
    _showMessage(
      'Unable to access the selected file.',
    );
    return;
  }

  setState(() {
    _idDocumentPath = path;
    _idDocumentName = file.name;
  });
}

  Future<void> _takeSelfie() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (image == null) return;

    setState(() {
      _selfiePath = image.path;
      _selfieName = image.name;
    });
  }

  Future<void> _submitKyc() async {
    if (_idDocumentPath == null) {
      _showMessage(
        'Please select your identity document.',
      );
      return;
    }

    if (_selfiePath == null) {
      _showMessage(
        'Please take your verification selfie.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ref
          .read(profileActionsProvider)
          .submitKyc(
            idDocumentPath: _idDocumentPath!,
            selfiePath: _selfiePath!,
          );

      if (!mounted) return;

      setState(() {
        _idDocumentPath = null;
        _idDocumentName = null;
        _selfiePath = null;
        _selfieName = null;
      });

      ref.invalidate(kycStatusProvider);
      ref.invalidate(kycHistoryProvider);
      ref.invalidate(profileProvider);

      _showMessage(
        result.isProcessing
            ? 'Your KYC application was submitted successfully.'
            : 'Your KYC application was submitted.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _friendlyError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _statusDescription(KycStatus status) {
    if (status.isVerified) {
      return 'Your identity has been verified successfully.';
    }

    if (status.isRejected) {
      return 'Your previous KYC application was rejected. '
          'You can review the reason and submit a new application.';
    }

    if (status.isUnderReview) {
      return 'Your application is currently under review.';
    }

    if (status.isPending) {
      if (status.submittedAt != null) {
        return 'Your KYC application has been submitted and is '
            'waiting for verification.';
      }

      return 'You have not completed identity verification yet.';
    }

    return 'Your current verification status is '
        '${status.readableStatus}.';
  }

  Color _statusColor(KycStatus status) {
    if (status.isVerified) {
      return const Color(0xFF168447);
    }

    if (status.isRejected) {
      return const Color(0xFFD62828);
    }

    if (status.isProcessing) {
      return const Color(0xFFB77900);
    }

    return AppColors.primary;
  }

  IconData _statusIcon(KycStatus status) {
    if (status.isVerified) {
      return Icons.verified_rounded;
    }

    if (status.isRejected) {
      return Icons.cancel_rounded;
    }

    if (status.isProcessing) {
      return Icons.hourglass_top_rounded;
    }

    return Icons.shield_outlined;
  }

  Color _historyStatusColor(
    KycSubmission submission,
  ) {
    if (submission.isVerified) {
      return const Color(0xFF168447);
    }

    if (submission.isRejected) {
      return const Color(0xFFD62828);
    }

    if (submission.isPending ||
        submission.isUnderReview) {
      return const Color(0xFFB77900);
    }

    return AppColors.primary;
  }

  IconData _historyStatusIcon(
    KycSubmission submission,
  ) {
    if (submission.isVerified) {
      return Icons.verified_rounded;
    }

    if (submission.isRejected) {
      return Icons.cancel_rounded;
    }

    return Icons.pending_actions_rounded;
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('409')) {
      return 'Your KYC application is already being processed.';
    }

    if (message.contains('Unsupported file type')) {
      return 'That file type is not supported.';
    }

    if (message.contains('invalid')) {
      return 'One or more uploaded files are invalid.';
    }

    return message
        .replaceFirst(
          'ProfileRepositoryException: ',
          '',
        )
        .trim();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _StatusBadge extends StatelessWidget {
  final KycStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (status.isVerified) {
      color = const Color(0xFF168447);
    } else if (status.isRejected) {
      color = const Color(0xFFD62828);
    } else {
      color = const Color(0xFFB77900);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.readableStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HistoryStatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _HistoryStatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _UploadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEFF6FF)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : icon,
                color: selected
                    ? AppColors.primary
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _RequirementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
