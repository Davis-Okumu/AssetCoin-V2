import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layouts/admin_shell.dart';
import '../../data/models/admin_staff_model.dart';
import '../../data/models/admin_staff_role_model.dart';
import '../../data/repositories/admin_staff_repository.dart';
import '../controllers/staff_controller.dart';
import '../widgets/staff_filter_bar.dart';
import '../widgets/staff_form_dialog.dart';
import '../widgets/staff_overview_cards.dart';
import '../widgets/staff_table.dart';

import 'staff_details_page.dart';

class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  final TextEditingController _searchController = TextEditingController();

  List<AdminStaffRoleModel> _roles = [];
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRoles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffControllerProvider);
    final controller = ref.read(staffControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refresh();
            await _loadRoles();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (state.overview != null)
                  StaffOverviewCards(overview: state.overview!),
                if (state.overview != null) const SizedBox(height: 24),
                _buildSectionHeader(context),
                const SizedBox(height: 16),
                StaffFilterBar(
                  searchController: _searchController,
                  selectedStatus: state.statusFilter,
                  selectedRole: state.roleFilter,
                  roles: _roleFilterOptions(_roles),
                  onSearchChanged: controller.searchStaff,
                  onStatusChanged: controller.filterByStatus,
                  onRoleChanged: controller.filterByRole,
                  onClearFilters: () {
                    _searchController.clear();
                    controller.clearFilters();
                  },
                ),
                const SizedBox(height: 20),
                if (_isLoadingRoles) const LinearProgressIndicator(),
                if (state.errorMessage != null)
                  _buildError(context, state.errorMessage!, controller),
                StaffTable(
                  staff: state.staff,
                  isLoading: state.isLoading,
                  onView: _viewStaff,
                  onEdit: _editStaff,
                  onChangeStatus: _changeStaffStatus,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Management',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage staff accounts, roles, access, and account status.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );

        final addButton = FilledButton.icon(
          onPressed: _createStaff,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Staff'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 16), addButton],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            addButton,
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Platform Staff',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          tooltip: 'Refresh staff',
          onPressed: () async {
            await ref.read(staffControllerProvider.notifier).refresh();
            await _loadRoles();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    StaffController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: controller.refresh, child: const Text('Retry')),
        ],
      ),
    );
  }

  List<StaffRoleFilterOption> _roleFilterOptions(
    List<AdminStaffRoleModel> roles,
  ) {
    return roles
        .map((role) => StaffRoleFilterOption(code: role.code, name: role.name))
        .toList();
  }

  Future<void> _loadRoles() async {
    if (_isLoadingRoles || !mounted) return;

    setState(() => _isLoadingRoles = true);

    try {
      final roles = await ref.read(adminStaffRepositoryProvider).getRoles();

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoadingRoles = false);
      _showMessage('Unable to load staff roles: ${_friendlyError(error)}');
    }
  }

  Future<void> _createStaff() async {
    final roles = _roles.isNotEmpty ? _roles : await _getRolesForDialog();

    if (!mounted) return;

    if (roles.isEmpty) {
      _showMessage('No staff roles are available. Check the staff roles API.');
      return;
    }

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StaffFormDialog(
        roles: roles,
        onSubmit: (values) async {
          try {
            await ref.read(adminStaffRepositoryProvider).createStaff(values);

            return true;
          } catch (error) {
            _showMessage(_friendlyError(error));
            return false;
          }
        },
      ),
    );

    if (created == true && mounted) {
      await ref.read(staffControllerProvider.notifier).refresh();
      _showMessage('Staff account created successfully.');
    }
  }

  Future<void> _editStaff(AdminStaffModel staff) async {
    final roles = _roles.isNotEmpty ? _roles : await _getRolesForDialog();

    if (!mounted) return;

    if (roles.isEmpty) {
      _showMessage('No staff roles are available.');
      return;
    }

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StaffFormDialog(
        staff: staff,
        roles: roles,
        onSubmit: (values) async {
          try {
            await ref
                .read(adminStaffRepositoryProvider)
                .updateStaff(staffId: staff.id, body: values);

            return true;
          } catch (error) {
            _showMessage(_friendlyError(error));
            return false;
          }
        },
      ),
    );

    if (updated == true && mounted) {
      await ref.read(staffControllerProvider.notifier).refresh();
      _showMessage('Staff account updated successfully.');
    }
  }

  Future<List<AdminStaffRoleModel>> _getRolesForDialog() async {
    try {
      final roles = await ref.read(adminStaffRepositoryProvider).getRoles();

      if (mounted) {
        setState(() => _roles = roles);
      }

      return roles;
    } catch (error) {
      if (mounted) {
        _showMessage(_friendlyError(error));
      }

      return [];
    }
  }

  void _viewStaff(AdminStaffModel staff) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StaffDetailsPage(staffId: staff.id),
      ),
    );
  }

  Future<void> _changeStaffStatus(AdminStaffModel staff) async {
    final currentStatus = staff.accountStatus.toLowerCase();
    final isActive = currentStatus == 'active' || staff.isAccountActive;

    final nextStatus = isActive ? 'suspended' : 'active';
    final actionLabel = isActive ? 'Suspend account' : 'Activate account';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(actionLabel),
        content: Text(
          isActive
              ? 'Suspend ${staff.fullName}? Their access to the admin dashboard should be restricted.'
              : 'Activate ${staff.fullName}? They will be able to sign in if their other account requirements are satisfied.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isActive ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(staffControllerProvider.notifier)
          .updateStatus(staffId: staff.id, status: nextStatus);

      if (!mounted) return;

      final error = ref.read(staffControllerProvider).errorMessage;

      if (error != null) {
        _showMessage(error);
        return;
      }

      _showMessage(
        isActive ? 'Staff account suspended.' : 'Staff account activated.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage(_friendlyError(error));
      }
    }
  }

  String _friendlyError(Object error) {
    final value = error.toString();

    return value.startsWith('Exception: ')
        ? value.substring('Exception: '.length)
        : value;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StaffDetailsRoutePlaceholder extends StatelessWidget {
  const _StaffDetailsRoutePlaceholder({required this.staff});

  final AdminStaffModel staff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(staff.fullName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Staff details page will be connected next.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
