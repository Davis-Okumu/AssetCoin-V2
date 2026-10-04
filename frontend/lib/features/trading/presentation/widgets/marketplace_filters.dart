
import 'dart:async';

import 'package:flutter/material.dart';

class MarketplaceFilters extends StatefulWidget {
  const MarketplaceFilters({
    super.key,
    this.search = '',
    this.selectedAssetType,
    this.onSearchChanged,
    this.onAssetTypeChanged,
    this.onClear,
  });

  final String search;
  final String? selectedAssetType;

  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onAssetTypeChanged;
  final VoidCallback? onClear;

  @override
  State<MarketplaceFilters> createState() =>
      _MarketplaceFiltersState();
}

class _MarketplaceFiltersState
    extends State<MarketplaceFilters> {
  late final TextEditingController
      _searchController;

  Timer? _searchDebounce;

  static const List<_AssetFilter> _filters = [
    _AssetFilter(
      label: 'All',
      value: null,
      icon: Icons.grid_view_rounded,
    ),
    _AssetFilter(
      label: 'Land',
      value: 'land',
      icon: Icons.landscape_outlined,
    ),
    _AssetFilter(
      label: 'Livestock',
      value: 'livestock',
      icon: Icons.pets_outlined,
    ),
    _AssetFilter(
      label: 'Produce',
      value: 'produce',
      icon: Icons.eco_outlined,
    ),
    _AssetFilter(
      label: 'Property',
      value: 'property',
      icon: Icons.home_work_outlined,
    ),
    _AssetFilter(
      label: 'Vehicles',
      value: 'vehicle',
      icon: Icons.directions_car_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _searchController =
        TextEditingController(text: widget.search);
  }

  @override
  void didUpdateWidget(
    covariant MarketplaceFilters oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.search !=
        _searchController.text) {
      _searchController.text = widget.search;
      _searchController.selection =
          TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: _handleSearchChanged,
          decoration: InputDecoration(
            hintText:
                'Search tokenized assets...',
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            suffixIcon:
                _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (
              context,
              index,
            ) =>
                const SizedBox(width: 8),
            itemBuilder: (
              context,
              index,
            ) {
              final filter = _filters[index];

              final selected =
                  widget.selectedAssetType ==
                      filter.value;

              return FilterChip(
                selected: selected,
                onSelected: (_) {
                  widget.onAssetTypeChanged
                      ?.call(filter.value);
                },
                avatar: Icon(
                  filter.icon,
                  size: 17,
                ),
                label: Text(filter.label),
                showCheckmark: false,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              );
            },
          ),
        ),
        if (_hasActiveFilter) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onClear ?? _clearAll,
              icon: const Icon(
                Icons.filter_alt_off_outlined,
                size: 18,
              ),
              label: const Text(
                'Clear filters',
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool get _hasActiveFilter {
    return _searchController.text.trim().isNotEmpty ||
        widget.selectedAssetType != null;
  }

  void _handleSearchChanged(String value) {
    setState(() {});

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () {
        widget.onSearchChanged?.call(value);
      },
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {});

    widget.onSearchChanged?.call('');
  }

  void _clearAll() {
    _clearSearch();
    widget.onAssetTypeChanged?.call(null);
    widget.onClear?.call();
  }
}

class _AssetFilter {
  const _AssetFilter({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String? value;
  final IconData icon;
}

