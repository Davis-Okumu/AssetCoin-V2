import 'package:flutter/material.dart';

import '../../data/models/admin_staff_permission_model.dart';

class StaffPermissionsPanel extends StatelessWidget {
  const StaffPermissionsPanel({
    super.key,
    required this.permissions,
    required this.selectedPermissionCodes,
    required this.onPermissionChanged,
    required this.onSave,
    required this.onSelectAll,
    required this.onClearAll,
    this.isLoading = false,
    this.isSaving = false,
    this.readOnly = false,
  });

  final List<AdminStaffPermissionModel> permissions;
  final Set<String> selectedPermissionCodes;
  final void Function(String permissionCode, bool selected) onPermissionChanged;
  final VoidCallback onSave;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final bool isLoading;
  final bool isSaving;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (permissions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No permissions are available.'),
        ),
      );
    }

    final groupedPermissions = <String, List<AdminStaffPermissionModel>>{};

    for (final permission in permissions) {
      final rawModule = permission.module?.trim() ?? '';
      final String module = rawModule.isEmpty ? 'Other' : rawModule;

      groupedPermissions.putIfAbsent(module, () => []).add(permission);
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Management',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Review access permissions grouped by platform module.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.key_outlined, size: 16),
                  label: Text('${selectedPermissionCodes.length} selected'),
                ),
                if (!readOnly) ...[
                  OutlinedButton.icon(
                    onPressed: isSaving ? null : onSelectAll,
                    icon: const Icon(Icons.select_all),
                    label: const Text('Select all'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isSaving ? null : onClearAll,
                    icon: const Icon(Icons.deselect_outlined),
                    label: const Text('Clear selection'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            ...groupedPermissions.entries.map(
              (entry) => _PermissionGroup(
                module: entry.key,
                permissions: entry.value,
                selectedPermissionCodes: selectedPermissionCodes,
                onPermissionChanged: onPermissionChanged,
                readOnly: readOnly,
                disabled: isSaving,
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Saving...' : 'Save Permissions'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  const _PermissionGroup({
    required this.module,
    required this.permissions,
    required this.selectedPermissionCodes,
    required this.onPermissionChanged,
    required this.readOnly,
    required this.disabled,
  });

  final String module;
  final List<AdminStaffPermissionModel> permissions;
  final Set<String> selectedPermissionCodes;
  final void Function(String permissionCode, bool selected) onPermissionChanged;
  final bool readOnly;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      title: Text(
        _formatModule(module),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${permissions.length} permissions'),
      children: permissions.map((permission) {
        final selected = selectedPermissionCodes.contains(permission.code);

        return CheckboxListTile(
          value: selected,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(permission.name),
          subtitle: Text(
            [
              permission.code,
              if (permission.description?.isNotEmpty == true)
                permission.description!,
            ].join(' • '),
          ),
          secondary: _AccessTypeIndicator(permission: permission),
          onChanged: readOnly || disabled
              ? null
              : (value) {
                  onPermissionChanged(permission.code, value ?? false);
                },
        );
      }).toList(),
    );
  }

  String _formatModule(String value) {
    return value
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _AccessTypeIndicator extends StatelessWidget {
  const _AccessTypeIndicator({required this.permission});

  final AdminStaffPermissionModel permission;

  @override
  Widget build(BuildContext context) {
    final accessType = (permission.accessType ?? '').toLowerCase();
    final isDenied = accessType == 'deny' || accessType == 'denied';
    final isGrantedByRole = permission.isGrantedByRole == true;
    final isExplicitlyGranted = permission.isExplicitlyGranted == true;

    final Color color;
    final String label;
    final IconData icon;

    if (isDenied) {
      color = Colors.red.shade700;
      label = 'Denied';
      icon = Icons.block_outlined;
    } else if (isGrantedByRole) {
      color = Colors.blue.shade700;
      label = 'Role';
      icon = Icons.admin_panel_settings_outlined;
    } else if (isExplicitlyGranted) {
      color = Colors.green.shade700;
      label = 'Granted';
      icon = Icons.key_outlined;
    } else {
      color = Colors.grey.shade600;
      label = 'Available';
      icon = Icons.key_outlined;
    }

    return Tooltip(
      message: label,
      child: Icon(icon, color: color, size: 20),
    );
  }
}
