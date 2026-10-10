import 'package:flutter/material.dart';

class NotificationFilterBar extends StatefulWidget {
  const NotificationFilterBar({
    super.key,
    required this.type,
    required this.status,
    required this.search,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onSearch,
    required this.onClear,
  });

  final String type;
  final String status;
  final String search;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  @override
  State<NotificationFilterBar> createState() => _NotificationFilterBarState();
}

class _NotificationFilterBarState extends State<NotificationFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search);
  }

  @override
  void didUpdateWidget(covariant NotificationFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.search != widget.search &&
        _searchController.text != widget.search) {
      _searchController.text = widget.search;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                value: widget.type,
                decoration: const InputDecoration(
                  labelText: 'Notification type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All types')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'security', child: Text('Security')),
                  DropdownMenuItem(value: 'workflow', child: Text('Workflow')),
                  DropdownMenuItem(value: 'approval', child: Text('Approval')),
                  DropdownMenuItem(value: 'asset', child: Text('Asset')),
                  DropdownMenuItem(value: 'kyc', child: Text('KYC')),
                  DropdownMenuItem(
                    value: 'tokenization',
                    child: Text('Tokenization'),
                  ),
                  DropdownMenuItem(value: 'trading', child: Text('Trading')),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'support', child: Text('Support')),
                ],
                onChanged: (value) {
                  if (value != null) widget.onTypeChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String>(
                value: widget.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All statuses')),
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'read', child: Text('Read')),
                  DropdownMenuItem(value: 'archived', child: Text('Archived')),
                ],
                onChanged: (value) {
                  if (value != null) widget.onStatusChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 270,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search notifications',
                  hintText: 'Title or message',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Search',
                    onPressed: () => widget.onSearch(_searchController.text),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
                onSubmitted: widget.onSearch,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                widget.onClear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}
