import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_audit_log_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';
import '../controllers/audit_logs_controller.dart';
import '../controllers/ledger_overview_controller.dart';
import '../widgets/audit_logs_table.dart';

final auditLogOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(adminLedgerRepositoryProvider).getAuditOverview();
});

class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  final _searchController = TextEditingController();
  final _entityController = TextEditingController();
  final _actionController = TextEditingController();
  final _userIdController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _entityController.dispose();
    _actionController.dispose();
    _userIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() {
    return ref
        .read(auditLogsControllerProvider.notifier)
        .applyFilters(
          search: _searchController.text,
          entityType: _entityController.text,
          action: _actionController.text,
          userId: _userIdController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        );
  }

  void _clearFilters() {
    _searchController.clear();
    _entityController.clear();
    _actionController.clear();
    _userIdController.clear();
    _startDateController.clear();
    _endDateController.clear();

    ref.read(auditLogsControllerProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(auditLogsControllerProvider);
    final controller = ref.read(auditLogsControllerProvider.notifier);
    final overview = ref.watch(auditLogOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit logs'),
        actions: [
          IconButton(
            tooltip: 'Refresh audit logs',
            onPressed: () {
              ref.invalidate(auditLogsControllerProvider);
              ref.invalidate(auditLogOverviewProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Audit trail',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review recorded user and platform actions. These records are '
            'read-only; this page does not alter audit history.',
          ),
          const SizedBox(height: 20),
          overview.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Audit overview unavailable: $error'),
            data: (data) {
              final summary = _asMap(data['summary']);

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _AuditMetric(
                    title: 'Total logs',
                    value: '${summary['totalLogs'] ?? 0}',
                  ),
                  _AuditMetric(
                    title: 'Missing log hashes',
                    value: '${summary['logsWithoutHash'] ?? 0}',
                  ),
                  _AuditMetric(
                    title: 'Missing previous hashes',
                    value: '${summary['logsWithoutPreviousHash'] ?? 0}',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildFilters(context),
          const SizedBox(height: 16),
          logs.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => _ErrorPanel(
              message: 'Could not load audit logs: $error',
              onRetry: () => ref.invalidate(auditLogsControllerProvider),
            ),
            data: (result) => AuditLogsTable(
              result: result,
              isLoading: logs.isLoading,
              onPreviousPage: controller.previousPage,
              onNextPage: controller.nextPage,
              onOpen: _showLogDetails,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));

    InputDecoration decoration(String label) =>
        InputDecoration(labelText: label, border: border, isDense: true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter audit logs',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 560
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              Widget field(Widget child) =>
                  SizedBox(width: width, child: child);

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  field(
                    TextField(
                      controller: _searchController,
                      decoration: decoration('Search logs'),
                      onSubmitted: (_) => _applyFilters(),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _entityController,
                      decoration: decoration('Entity type'),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _actionController,
                      decoration: decoration('Action'),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _userIdController,
                      decoration: decoration('User ID'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  field(
                    TextField(
                      controller: _startDateController,
                      decoration: decoration('Start date (YYYY-MM-DD)'),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _endDateController,
                      decoration: decoration('End date (YYYY-MM-DD)'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Apply filters'),
              ),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use YYYY-MM-DD for date filters.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showLogDetails(AdminAuditLogModel log) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Audit log #${log.id}'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailLine('Action', log.actionLabel),
                _DetailLine('Entity type', log.entityTypeLabel),
                _DetailLine('Entity ID', log.entityId ?? '—'),
                _DetailLine('User ID', '${log.userId ?? '—'}'),
                _DetailLine('User', log.userName.isEmpty ? '—' : log.userName),
                _DetailLine('Email', log.email ?? '—'),
                _DetailLine('IP address', log.ipAddress ?? '—'),
                _DetailLine('User agent', log.userAgent ?? '—'),
                _DetailLine('Created at', '${log.createdAt ?? '—'}'),
                const Divider(height: 24),
                const Text(
                  'Previous values',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(_prettyJson(log.oldValues)),
                const SizedBox(height: 12),
                const Text(
                  'New values',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(_prettyJson(log.newValues)),
                const SizedBox(height: 12),
                const Text(
                  'Stored hash fields',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText('Previous hash: ${log.previousHash ?? '—'}'),
                SelectableText('Log hash: ${log.logHash ?? '—'}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _prettyJson(dynamic value) {
    if (value == null) return '—';

    try {
      if (value is String) {
        final decoded = jsonDecode(value);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }

      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}

class _AuditMetric extends StatelessWidget {
  const _AuditMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
