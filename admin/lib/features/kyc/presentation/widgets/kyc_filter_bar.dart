import 'package:flutter/material.dart';

class KycFilterBar extends StatelessWidget {
  const KycFilterBar({
    super.key,
    this.searchController,
    this.status,
    this.assignedTo,
    this.onSearchChanged,
    this.onStatusChanged,
    this.onAssignedToChanged,
    this.onClear,
    this.showAssignmentFilter = false,
  });

  final TextEditingController? searchController;

  final String? status;
  final int? assignedTo;

  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onStatusChanged;
  final ValueChanged<int?>? onAssignedToChanged;
  final VoidCallback? onClear;

  final bool showAssignmentFilter;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search applicant, email or ID...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      searchController != null &&
                          searchController!.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController!.clear();
                            onSearchChanged?.call('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String?>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'under_review',
                    child: Text('Under Review'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'changes_required',
                    child: Text('Changes Required'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'verified',
                    child: Text('Verified'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'rejected',
                    child: Text('Rejected'),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            if (showAssignmentFilter)
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int?>(
                  initialValue: assignedTo,
                  decoration: const InputDecoration(
                    labelText: 'Assignment',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All reviewers'),
                    ),
                  ],
                  onChanged: onAssignedToChanged,
                ),
              ),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
