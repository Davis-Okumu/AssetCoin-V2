import 'package:flutter/material.dart';

class LedgerHashInspectionPanel extends StatelessWidget {
  const LedgerHashInspectionPanel({super.key, required this.inspection});

  final Map<String, dynamic> inspection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = _asMap(inspection['entry']);
    final previous = _asMap(inspection['previousEntryById']);
    final next = _asMap(inspection['nextEntryById']);

    final verified = inspection['verified'] == true;
    final verificationAvailable = inspection['verificationAvailable'] == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stored hash inspection',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Text(
              'This is an inspection of stored fields only. '
              'It does not independently verify the hash chain or '
              'prove that a record has or has not been altered.',
              style: TextStyle(color: Color(0xFF9A3412)),
            ),
          ),
          const SizedBox(height: 16),
          _InspectionStatus(
            label: 'Verification available',
            value: verificationAvailable ? 'Yes' : 'No',
          ),
          _InspectionStatus(
            label: 'Cryptographic verification result',
            value: verificationAvailable
                ? (verified ? 'Passed' : 'Not passed')
                : 'Not performed',
          ),
          const SizedBox(height: 12),
          _HashRecordCard(title: 'Selected entry', record: entry),
          const SizedBox(height: 10),
          _HashRecordCard(
            title: 'Previous record by database ID',
            record: previous,
          ),
          const SizedBox(height: 10),
          _HashRecordCard(title: 'Next record by database ID', record: next),
          if ((inspection['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              inspection['note'].toString(),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

class _HashRecordCard extends StatelessWidget {
  const _HashRecordCard({required this.title, required this.record});

  final String title;
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (record.isEmpty)
            const Text('No neighbouring record was returned.')
          else ...[
            _InspectionStatus(label: 'ID', value: _value(record['id'])),
            _InspectionStatus(
              label: 'Reference',
              value: _value(record['entryReference'] ?? record['reference']),
            ),
            _InspectionStatus(
              label: 'Previous hash',
              value: _value(record['previousHash'] ?? record['previous_hash']),
            ),
            _InspectionStatus(
              label: 'Entry hash',
              value: _value(
                record['entryHash'] ??
                    record['logHash'] ??
                    record['entry_hash'] ??
                    record['log_hash'],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return 'Missing';
    return value.toString();
  }
}

class _InspectionStatus extends StatelessWidget {
  const _InspectionStatus({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 175,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
