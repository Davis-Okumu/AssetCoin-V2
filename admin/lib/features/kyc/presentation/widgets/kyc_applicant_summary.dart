import 'package:flutter/material.dart';

import '../../data/models/admin_kyc_application.dart';
import 'kyc_status_badge.dart';

class KycApplicantSummary extends StatelessWidget {
  const KycApplicantSummary({super.key, required this.application});

  final AdminKycApplication application;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicant Information',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 700) {
                  return Column(
                    children: [
                      _buildApplicantIdentity(context),
                      const SizedBox(height: 24),
                      _buildApplicantDetails(context),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildApplicantIdentity(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 3, child: _buildApplicantDetails(context)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantIdentity(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(context),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.applicantName,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                application.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (application.phone != null &&
                  application.phone!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  application.phone!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              KycStatusBadge(status: application.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    final photoUrl = application.profilePhotoUrl;

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return CircleAvatar(radius: 34, backgroundImage: NetworkImage(photoUrl));
    }

    return CircleAvatar(
      radius: 34,
      child: Text(
        _initials,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }

  Widget _buildApplicantDetails(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 20,
      children: [
        _InfoItem(label: 'National ID', value: application.nationalId),
        _InfoItem(
          label: 'Verification Method',
          value: _formatValue(application.verificationMethod),
        ),
        _InfoItem(
          label: 'Submitted',
          value: _formatDate(application.submittedAt),
        ),
        _InfoItem(label: 'Application ID', value: '#${application.id}'),
      ],
    );
  }

  String get _initials {
    final first = application.firstName.trim();
    final last = application.lastName.trim();

    if (first.isEmpty && last.isEmpty) {
      return '?';
    }

    final firstInitial = first.isNotEmpty ? first[0].toUpperCase() : '';

    final lastInitial = last.isNotEmpty ? last[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }

  String _formatValue(String value) {
    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
