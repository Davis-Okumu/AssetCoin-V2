import 'package:flutter/material.dart';

class LedgerFilterBar extends StatefulWidget {
  const LedgerFilterBar({
    super.key,
    required this.onApply,
    required this.onClear,
    this.isLoading = false,
  });

  final Future<void> Function({
    String? search,
    String? entryType,
    String? assetType,
    String? currency,
    String? startDate,
    String? endDate,
  })
  onApply;

  final VoidCallback onClear;
  final bool isLoading;

  @override
  State<LedgerFilterBar> createState() => _LedgerFilterBarState();
}

class _LedgerFilterBarState extends State<LedgerFilterBar> {
  final _searchController = TextEditingController();
  final _currencyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _entryType;
  String? _assetType;

  @override
  void dispose() {
    _searchController.dispose();
    _currencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    await widget.onApply(
      search: _searchController.text.trim(),
      entryType: _entryType,
      assetType: _assetType,
      currency: _currencyController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
    );
  }

  void _clear() {
    _searchController.clear();
    _currencyController.clear();
    _startDateController.clear();
    _endDateController.clear();

    setState(() {
      _entryType = null;
      _assetType = null;
    });

    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));

    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
      border: border,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

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
            'Filter ledger entries',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
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
                      decoration: decoration('Search reference, user or ID'),
                      onSubmitted: (_) => _apply(),
                    ),
                  ),
                  field(
                    DropdownButtonFormField<String>(
                      value: _entryType,
                      decoration: decoration('Entry type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Credit'),
                        ),
                        DropdownMenuItem(value: 'debit', child: Text('Debit')),
                      ],
                      onChanged: (value) => setState(() => _entryType = value),
                    ),
                  ),
                  field(
                    DropdownButtonFormField<String>(
                      value: _assetType,
                      decoration: decoration('Asset type'),
                      items: const [
                        DropdownMenuItem(value: 'fiat', child: Text('Fiat')),
                        DropdownMenuItem(value: 'token', child: Text('Token')),
                      ],
                      onChanged: (value) => setState(() => _assetType = value),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _currencyController,
                      decoration: decoration('Currency (e.g. KES)'),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: widget.isLoading ? null : _apply,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Apply filters'),
              ),
              OutlinedButton.icon(
                onPressed: widget.isLoading ? null : _clear,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dates use YYYY-MM-DD. Filters are applied by the server.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
