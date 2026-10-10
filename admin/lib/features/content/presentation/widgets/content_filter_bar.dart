import 'package:flutter/material.dart';

class ContentFilterBar extends StatefulWidget {
  const ContentFilterBar({
    super.key,
    required this.type,
    required this.status,
    required this.category,
    required this.search,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onReset,
  });

  /// Currently selected content type:
  /// announcements, news, or publications.
  final String type;

  final String? status;
  final String? category;
  final String search;

  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;

  /// Refreshes the current content list and overview.
  final VoidCallback onRefresh;

  /// Clears all active filters.
  final VoidCallback onReset;

  @override
  State<ContentFilterBar> createState() => _ContentFilterBarState();
}

class _ContentFilterBarState extends State<ContentFilterBar> {
  late final TextEditingController _searchController;

  static const Color _primaryRed = Color(0xFFD32F2F);
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _borderColor = Color(0xFFE0E5ED);

  static const List<DropdownMenuItem<String>> _statusItems = [
    DropdownMenuItem(value: 'draft', child: Text('Draft')),
    DropdownMenuItem(value: 'published', child: Text('Published')),
    DropdownMenuItem(value: 'archived', child: Text('Archived')),
  ];

  static const List<DropdownMenuItem<String>> _announcementCategories = [
    DropdownMenuItem(value: 'general', child: Text('General')),
    DropdownMenuItem(value: 'company', child: Text('Company')),
  ];

  static const List<DropdownMenuItem<String>> _newsCategories = [
    DropdownMenuItem(value: 'market', child: Text('Market')),
    DropdownMenuItem(value: 'asset', child: Text('Asset')),
    DropdownMenuItem(value: 'tokenization', child: Text('Tokenization')),
    DropdownMenuItem(value: 'education', child: Text('Education')),
    DropdownMenuItem(value: 'company', child: Text('Company')),
    DropdownMenuItem(value: 'general', child: Text('General')),
  ];

  static const List<DropdownMenuItem<String>> _publicationCategories = [
    DropdownMenuItem(value: 'education', child: Text('Education')),
    DropdownMenuItem(value: 'guide', child: Text('Guide')),
    DropdownMenuItem(value: 'report', child: Text('Report')),
    DropdownMenuItem(value: 'platform', child: Text('Platform')),
    DropdownMenuItem(value: 'general', child: Text('General')),
  ];

  List<DropdownMenuItem<String>> get _categoryItems {
    switch (widget.type) {
      case 'announcements':
        return _announcementCategories;
      case 'news':
        return _newsCategories;
      case 'publications':
        return _publicationCategories;
      default:
        return _newsCategories;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search);
  }

  @override
  void didUpdateWidget(covariant ContentFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.search != widget.search &&
        _searchController.text != widget.search) {
      _searchController.value = TextEditingValue(
        text: widget.search,
        selection: TextSelection.collapsed(offset: widget.search.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;

          final searchField = SizedBox(
            width: compact ? double.infinity : 300,
            child: TextField(
              controller: _searchController,
              onSubmitted: widget.onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search content...',
                prefixIcon: const Icon(Icons.search, color: _primaryBlue),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
                ),
              ),
            ),
          );

          final statusField = SizedBox(
            width: compact ? double.infinity : 170,
            child: _buildDropdown(
              value: widget.status,
              hint: 'All statuses',
              items: _statusItems,
              onChanged: widget.onStatusChanged,
            ),
          );

          final categoryField = SizedBox(
            width: compact ? double.infinity : 190,
            child: _buildDropdown(
              value: widget.category,
              hint: 'All categories',
              items: _categoryItems,
              onChanged: widget.onCategoryChanged,
            ),
          );

          final resetButton = OutlinedButton.icon(
            onPressed: widget.onReset,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryRed,
              side: const BorderSide(color: _primaryRed),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          final refreshButton = OutlinedButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryBlue,
              side: const BorderSide(color: _primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 12),
                statusField,
                const SizedBox(height: 12),
                categoryField,
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [resetButton, refreshButton],
                ),
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              searchField,
              statusField,
              categoryField,
              resetButton,
              refreshButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Keep the dropdown selection valid when changing content types.
    final validValues = items.map((item) => item.value).toSet();

    final selectedValue = value != null && validValues.contains(value)
        ? value
        : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: items,
      onChanged: onChanged,
    );
  }
}
