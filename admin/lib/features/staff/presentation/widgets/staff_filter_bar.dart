import 'package:flutter/material.dart';

class StaffFilterBar extends StatelessWidget {
  const StaffFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onRoleChanged,
    required this.onClearFilters,
    this.selectedStatus,
    this.selectedRole,
    this.roles = const [],
    this.searchController,
  });

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onClearFilters;

  final String? selectedStatus;
  final String? selectedRole;
  final List<StaffRoleFilterOption> roles;
  final TextEditingController? searchController;

  static const List<DropdownMenuItem<String?>> _statusItems = [
    DropdownMenuItem<String?>(value: null, child: Text('All statuses')),
    DropdownMenuItem<String?>(value: 'active', child: Text('Active')),
    DropdownMenuItem<String?>(value: 'suspended', child: Text('Suspended')),
    DropdownMenuItem<String?>(value: 'inactive', child: Text('Inactive')),
    DropdownMenuItem<String?>(value: 'deactivated', child: Text('Deactivated')),
    DropdownMenuItem<String?>(value: 'locked', child: Text('Locked')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        final searchField = TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search name, email or phone...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        );

        final statusDropdown = DropdownButtonFormField<String?>(
          value: selectedStatus,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: _statusItems,
          onChanged: onStatusChanged,
        );

        final roleDropdown = DropdownButtonFormField<String?>(
          value: selectedRole,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All roles'),
            ),
            ...roles.map(
              (role) => DropdownMenuItem<String?>(
                value: role.code,
                child: Text(role.name),
              ),
            ),
          ],
          onChanged: onRoleChanged,
        );

        final clearButton = OutlinedButton.icon(
          onPressed: onClearFilters,
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 12),
              statusDropdown,
              const SizedBox(height: 12),
              roleDropdown,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: clearButton),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: statusDropdown),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: roleDropdown),
            const SizedBox(width: 12),
            Padding(padding: const EdgeInsets.only(top: 2), child: clearButton),
          ],
        );
      },
    );
  }
}

class StaffRoleFilterOption {
  const StaffRoleFilterOption({required this.code, required this.name});

  final String code;
  final String name;
}
