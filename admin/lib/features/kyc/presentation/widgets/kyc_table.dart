import 'package:flutter/material.dart';

import '../../data/models/admin_kyc_application.dart';
import 'kyc_status_badge.dart';

class KycTable extends StatelessWidget {
  const KycTable({
    super.key,
    required this.applications,
    this.onApplicationTap,
  });

  final List<AdminKycApplication> applications;

  final ValueChanged<AdminKycApplication>? onApplicationTap;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'KYC Applications',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 32,
              headingRowHeight: 52,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 76,
              columns: const [
                DataColumn(label: Text('Applicant')),
                DataColumn(label: Text('National ID')),
                DataColumn(label: Text('Verification')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Submitted')),
                DataColumn(label: Text('Assignment')),
                DataColumn(label: Text('Action')),
              ],
              rows: applications
                  .map((application) => _buildRow(context, application))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, AdminKycApplication application) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 190,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.applicantName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  application.email,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(application.nationalId)),
        DataCell(Text(_formatValue(application.verificationMethod))),
        DataCell(KycStatusBadge(status: application.status)),
        DataCell(Text(_formatDate(application.submittedAt))),
        DataCell(Text(application.isAssigned ? 'Assigned' : 'Unassigned')),
        DataCell(
          OutlinedButton(
            onPressed: () {
              onApplicationTap?.call(application);
            },
            child: const Text('Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 52,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No KYC applications found',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Customer-submitted KYC applications will appear here.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
