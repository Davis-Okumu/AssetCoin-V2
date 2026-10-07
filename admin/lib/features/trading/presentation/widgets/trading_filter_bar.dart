import 'dart:async';

import 'package:flutter/material.dart';

class TradingFilterBar extends StatefulWidget {
  const TradingFilterBar({
    super.key,
    this.initialSearch,
    this.initialStatus,
    this.initialListingType,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onListingTypeChanged,
    required this.onClear,
  });

  final String? initialSearch;
  final String? initialStatus;
  final String? initialListingType;

  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onListingTypeChanged;
  final VoidCallback onClear;

  @override
  State<TradingFilterBar> createState() => _TradingFilterBarState();
}

class _TradingFilterBarState extends State<TradingFilterBar> {
  late final TextEditingController _searchController;

  Timer? _searchDebounce;

  String? _status;
  String? _listingType;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(text: widget.initialSearch ?? '');

    _status = widget.initialStatus;
    _listingType = widget.initialListingType;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      widget.onSearch(value.trim().isEmpty ? null : value.trim());
    });

    setState(() {});
  }

  void _clear() {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _status = null;
      _listingType = null;
    });

    widget.onClear();
  }

  bool get _hasFilters {
    return _searchController.text.trim().isNotEmpty ||
        _status != null ||
        _listingType != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search listings...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            widget.onSearch(null);
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String?>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'partially_filled',
                    child: Text('Partially Filled'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'filled',
                    child: Text('Filled'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'expired',
                    child: Text('Expired'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });

                  widget.onStatusChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String?>(
                initialValue: _listingType,
                decoration: const InputDecoration(
                  labelText: 'Listing type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  DropdownMenuItem<String?>(value: 'sell', child: Text('Sell')),
                  DropdownMenuItem<String?>(value: 'buy', child: Text('Buy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _listingType = value;
                  });

                  widget.onListingTypeChanged(value);
                },
              ),
            ),
            if (_hasFilters)
              OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear filters'),
              ),
          ],
        ),
      ),
    );
  }
}
