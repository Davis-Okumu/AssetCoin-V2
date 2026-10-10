import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/ledger_entries_controller.dart';
import '../controllers/ledger_overview_controller.dart';
import '../widgets/ledger_entries_table.dart';
import '../widgets/ledger_filter_bar.dart';
import '../widgets/ledger_summary_cards.dart';
import 'ledger_entry_details_page.dart';

class LedgerPage extends ConsumerWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(ledgerOverviewControllerProvider);
    final entries = ref.watch(ledgerEntriesControllerProvider);
    final entriesController = ref.read(
      ledgerEntriesControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        actions: [
          IconButton(
            tooltip: 'Refresh ledger',
            onPressed: () {
              ref.invalidate(ledgerOverviewControllerProvider);
              ref.invalidate(ledgerEntriesControllerProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ledgerOverviewControllerProvider);
          ref.invalidate(ledgerEntriesControllerProvider);
          await ref.read(ledgerOverviewControllerProvider.future);
          await ref.read(ledgerEntriesControllerProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Financial ledger and transaction records',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Review recorded entries and trace their linked records. '
              'This module is read-only.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            overview.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _ErrorPanel(
                message: 'Could not load ledger overview: $error',
                onRetry: () => ref.invalidate(ledgerOverviewControllerProvider),
              ),
              data: (data) {
                final note = data.note;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LedgerSummaryCards(summary: data.summary),
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(note, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LedgerFilterBar(
              isLoading: entries.isLoading,
              onApply:
                  ({
                    search,
                    entryType,
                    assetType,
                    currency,
                    startDate,
                    endDate,
                  }) {
                    return entriesController.applyFilters(
                      search: search,
                      entryType: entryType,
                      assetType: assetType,
                      currency: currency,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  },
              onClear: () {
                entriesController.clearFilters();
              },
            ),
            const SizedBox(height: 16),
            entries.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _ErrorPanel(
                message: 'Could not load ledger entries: $error',
                onRetry: () => ref.invalidate(ledgerEntriesControllerProvider),
              ),
              data: (result) => LedgerEntriesTable(
                result: result,
                isLoading: entries.isLoading,
                onPreviousPage: entriesController.previousPage,
                onNextPage: entriesController.nextPage,
                onOpen: (entry) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LedgerEntryDetailsPage(entryId: entry.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
