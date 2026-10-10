import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/ledger_entry_details_controller.dart';
import '../widgets/ledger_entry_details_panel.dart';

class LedgerEntryDetailsPage extends ConsumerStatefulWidget {
  const LedgerEntryDetailsPage({super.key, required this.entryId});

  final int entryId;

  @override
  ConsumerState<LedgerEntryDetailsPage> createState() =>
      _LedgerEntryDetailsPageState();
}

class _LedgerEntryDetailsPageState
    extends ConsumerState<LedgerEntryDetailsPage> {
  Map<String, dynamic>? _hashInspection;
  String? _hashInspectionError;
  bool _loadingHashInspection = false;

  Future<void> _inspectHashes() async {
    setState(() {
      _loadingHashInspection = true;
      _hashInspectionError = null;
      _hashInspection = null;
    });

    try {
      final result = await ref
          .read(ledgerEntryDetailsControllerProvider(widget.entryId).notifier)
          .loadHashInspection();

      if (!mounted) return;

      setState(() {
        _hashInspection = result;
        _loadingHashInspection = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hashInspectionError = error.toString();
        _loadingHashInspection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(
      ledgerEntryDetailsControllerProvider(widget.entryId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ledger entry details')),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text('Unable to load ledger entry: $error'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    ledgerEntryDetailsControllerProvider(widget.entryId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (entry) => Padding(
          padding: const EdgeInsets.all(20),
          child: LedgerEntryDetailsPanel(
            entry: entry,
            onInspectHashes: _inspectHashes,
            hashInspection: _hashInspection,
            hashInspectionError: _hashInspectionError,
            isLoadingHashInspection: _loadingHashInspection,
          ),
        ),
      ),
    );
  }
}
