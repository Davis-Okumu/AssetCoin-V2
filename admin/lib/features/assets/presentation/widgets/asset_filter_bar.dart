import 'dart:async';

import 'package:flutter/material.dart';

class AssetFilterBar extends StatefulWidget {
  const AssetFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onAssetTypeChanged,
    required this.onClear,
  });

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onAssetTypeChanged;
  final VoidCallback onClear;

  @override
  State<AssetFilterBar> createState() => _AssetFilterBarState();
}

class _AssetFilterBarState extends State<AssetFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(value);
    });
  }

  void _clear() {
    _searchController.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
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
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search assets, owners or codes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: null,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'under_review',
                    child: Text('Under Review'),
                  ),
                  DropdownMenuItem(
                    value: 'changes_required',
                    child: Text('Changes Required'),
                  ),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  DropdownMenuItem(
                    value: 'tokenized',
                    child: Text('Tokenized'),
                  ),
                  DropdownMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged: widget.onStatusChanged,
              ),
            ),

            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: null,
                decoration: const InputDecoration(
                  labelText: 'Asset Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'land', child: Text('Land')),
                  DropdownMenuItem(
                    value: 'livestock',
                    child: Text('Livestock'),
                  ),
                  DropdownMenuItem(value: 'produce', child: Text('Produce')),
                  DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                  DropdownMenuItem(value: 'property', child: Text('Property')),
                  DropdownMenuItem(
                    value: 'equipment',
                    child: Text('Equipment'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: widget.onAssetTypeChanged,
              ),
            ),

            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}
