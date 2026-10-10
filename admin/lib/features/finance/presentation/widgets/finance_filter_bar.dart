import 'package:flutter/material.dart';

class FinanceFilterBar extends StatelessWidget {
  const FinanceFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.status,
    required this.statusOptions,
    required this.onStatusChanged,
    this.searchHint = 'Search by reference or customer',
    this.showStatusFilter = true,
    this.onClear,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String status;
  final List<String> statusOptions;
  final ValueChanged<String?> onStatusChanged;
  final String searchHint;
  final bool showStatusFilter;
  final VoidCallback? onClear;

  String _label(String value) {
    if (value.toLowerCase() == 'all') return 'All statuses';

    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final searchField = TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        );

        final statusField = DropdownButtonFormField<String>(
          initialValue: statusOptions.contains(status) ? status : null,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: statusOptions
              .map(
                (value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(_label(value)),
                ),
              )
              .toList(),
          onChanged: onStatusChanged,
        );

        final clearButton = OutlinedButton.icon(
          onPressed:
              onClear ??
              () {
                searchController.clear();
                onSearchChanged('');
                if (statusOptions.contains('all')) {
                  onStatusChanged('all');
                }
              },
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: const Text('Clear'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              if (showStatusFilter) ...[
                const SizedBox(height: 12),
                statusField,
              ],
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: clearButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: searchField),
            if (showStatusFilter) ...[
              const SizedBox(width: 12),
              Expanded(flex: 2, child: statusField),
            ],
            const SizedBox(width: 12),
            clearButton,
          ],
        );
      },
    );
  }
}
