import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layouts/admin_shell.dart';
import '../../data/models/admin_staff_model.dart';
import '../controllers/staff_details_controller.dart';
import '../controllers/staff_permissions_controller.dart';
import '../widgets/staff_activity_panel.dart';
import '../widgets/staff_permissions_panel.dart';
import '../widgets/staff_sessions_panel.dart';
import '../widgets/staff_status_badge.dart';

class StaffDetailsPage extends ConsumerWidget {
  const StaffDetailsPage({super.key, required this.staffId});

  final int staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(staffDetailsControllerProvider(staffId));
    final detailsController = ref.read(
      staffDetailsControllerProvider(staffId).notifier,
    );

    final permissionsState = ref.watch(
      staffPermissionsControllerProvider(staffId),
    );
    final permissionsController = ref.read(
      staffPermissionsControllerProvider(staffId).notifier,
    );

    final staff = detailsState.staff;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (detailsState.isLoading && staff == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (detailsState.errorMessage != null && staff == null)
                _buildError(
                  context,
                  detailsState.errorMessage!,
                  detailsController.loadDetails,
                )
              else if (staff == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('Staff account not found.'),
                  ),
                )
              else ...[
                _StaffProfileCard(staff: staff),
                const SizedBox(height: 24),
                _buildAccountInformation(context, staff),
                const SizedBox(height: 24),
                StaffPermissionsPanel(
                  permissions: permissionsState.permissions,
                  selectedPermissionCodes:
                      permissionsState.selectedPermissionCodes,
                  onPermissionChanged: permissionsController.togglePermission,
                  onSelectAll: permissionsController.selectAllPermissions,
                  onClearAll: permissionsController.clearSelectedPermissions,
                  onSave: () async {
                    try {
                      await permissionsController.savePermissions();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permission changes saved.'),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not save permissions: $error'),
                          ),
                        );
                      }
                    }
                  },
                  isLoading: permissionsState.isLoading,
                  isSaving: permissionsState.isSaving,
                ),
                if (permissionsState.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _InlineError(message: permissionsState.errorMessage!),
                ],
                const SizedBox(height: 24),
                StaffActivityPanel(
                  activities: detailsState.activity,
                  isLoading: detailsState.isLoading,
                  errorMessage: detailsState.errorMessage,
                  onRefresh: detailsController.loadDetails,
                ),
                const SizedBox(height: 24),
                StaffSessionsPanel(
                  sessions: detailsState.sessions,
                  isLoading: detailsState.isLoading,
                  errorMessage: detailsState.errorMessage,
                  onRefresh: detailsController.loadDetails,
                  onRevokeSession: (sessionId) async {
                    try {
                      await detailsController.revokeSession(sessionId);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session revocation requested.'),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not revoke session: $error'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back to staff management',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Details',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage account information, permissions, activity, and sessions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh details',
          onPressed: () {
            // The details controller refreshes its data through loadDetails.
            // Permission data is loaded by its own controller.
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildAccountInformation(BuildContext context, AdminStaffModel staff) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 750 ? 3 : 1;

                return Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  children: [
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Staff ID',
                      value: staff.id.toString(),
                    ),
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Role',
                      value: staff.roleName ?? staff.roleCode ?? 'Not assigned',
                    ),
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Email',
                      value: staff.email,
                    ),
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Phone',
                      value: staff.phone ?? 'Not provided',
                    ),
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Created',
                      value: _formatDate(staff.createdAt),
                    ),
                    _InfoItem(
                      width: _itemWidth(constraints.maxWidth, columns),
                      label: 'Last Login',
                      value: _formatDate(staff.lastLoginAt),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _itemWidth(double availableWidth, int columns) {
    if (columns == 1) return availableWidth;

    return (availableWidth - (columns - 1) * 24) / columns;
  }

  Widget _buildError(
    BuildContext context,
    String message,
    Future<void> Function() onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Never';

    final date = value.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }
}

class _StaffProfileCard extends StatelessWidget {
  const _StaffProfileCard({required this.staff});

  final AdminStaffModel staff;

  @override
  Widget build(BuildContext context) {
    final initials = [staff.firstName, staff.lastName]
        .where((name) => name.trim().isNotEmpty)
        .map((name) => name.trim()[0].toUpperCase())
        .join();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage:
                  staff.profilePhotoUrl != null &&
                      staff.profilePhotoUrl!.isNotEmpty
                  ? NetworkImage(staff.profilePhotoUrl!)
                  : null,
              child:
                  staff.profilePhotoUrl == null ||
                      staff.profilePhotoUrl!.isEmpty
                  ? Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.fullName,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(staff.email),
                  if (staff.roleName != null) ...[
                    const SizedBox(height: 4),
                    Text(staff.roleName!),
                  ],
                ],
              ),
            ),
            StaffStatusBadge(status: staff.accountStatus),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
