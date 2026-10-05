import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/admin_auth_controller.dart';
import '../../data/models/admin_user_list_model.dart';
import '../../domain/admin_user_record.dart';
import '../controllers/users_controller.dart';
import '../widgets/user_filter_bar.dart';
import '../widgets/user_summary_cards.dart';
import '../widgets/users_table.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersControllerProvider);
    final authState = ref.watch(adminAuthControllerProvider);

    final admin = authState.value;

    final canUpdate =
        admin?.isSuperAdministrator == true ||
        admin?.hasPermission('users.update') == true;

    final canSuspend =
        admin?.isSuperAdministrator == true ||
        admin?.hasPermission('users.suspend') == true;

    final canDeactivate =
        admin?.isSuperAdministrator == true ||
        admin?.hasPermission('users.deactivate') == true;

    return usersState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return _UsersErrorState(
          message: error.toString(),
          onRetry: () {
            ref.read(usersControllerProvider.notifier).refreshUsers();
          },
        );
      },
      data: (result) {
        final controller = ref.read(usersControllerProvider.notifier);

        return RefreshIndicator(
          onRefresh: controller.refreshUsers,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // =================================================
              // SUMMARY
              // =================================================

              UserSummaryCards(
                totalUsers: result.pagination.total,
                currentPage: result.pagination.page,
                totalPages: result.pagination.totalPages,
                showingCount: result.items.length,
              ),

              const SizedBox(height: 20),

              // =================================================
              // FILTERS
              // =================================================
              UserFilterBar(
                filters: result.filters,
                loading: usersState.isLoading,
                onChanged: (filters) {
                  _applyFilters(controller, filters);
                },
                onClear: controller.clearFilters,
                onRefresh: controller.refreshUsers,
              ),

              const SizedBox(height: 20),

              // =================================================
              // USERS TABLE
              // =================================================
              UsersTable(
                users: result.items,
                loading: usersState.isLoading,
                onUserTap: (user) {
                  _openUserDetails(context, user);
                },
                onEdit: canUpdate
                    ? (user) {
                        _editUser(context, user);
                      }
                    : null,
                onChangeStatus: (user) {
                  _handleStatusChange(
                    context,
                    ref,
                    user,
                    canUpdate: canUpdate,
                    canSuspend: canSuspend,
                    canDeactivate: canDeactivate,
                  );
                },
              ),

              const SizedBox(height: 16),

              // =================================================
              // PAGINATION
              // =================================================
              _PaginationBar(
                pagination: result.pagination,
                onPrevious: controller.previousPage,
                onNext: controller.nextPage,
                onPageSelected: controller.goToPage,
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // APPLY FILTERS
  // =========================================================

  void _applyFilters(UsersController controller, UserListFilters filters) {
    _applyFiltersAsync(controller, filters);
  }

  Future<void> _applyFiltersAsync(
    UsersController controller,
    UserListFilters filters,
  ) async {
    await controller.search(filters.search ?? '');

    await controller.setAccountStatus(filters.accountStatus);

    await controller.setKycStatus(filters.kycStatus);

    await controller.setRole(filters.role);

    await controller.setSorting(
      sortBy: filters.sortBy ?? 'createdAt',
      sortOrder: filters.sortOrder ?? 'DESC',
    );
  }

  // =========================================================
  // USER DETAILS
  // =========================================================

  void _openUserDetails(BuildContext context, AdminUserRecord user) {
    // Navigation will be connected when the user details route
    // is finalized.
    //
    // Example:
    // context.go('/users/${user.id}');
  }

  // =========================================================
  // EDIT USER
  // =========================================================

  void _editUser(BuildContext context, AdminUserRecord user) {
    // User editing will be connected to the edit dialog/page.
  }

  // =========================================================
  // STATUS PERMISSION CHECK
  // =========================================================

  bool _canChangeStatus(
    AdminUserRecord user, {
    required bool canUpdate,
    required bool canSuspend,
    required bool canDeactivate,
  }) {
    switch (user.accountStatus.toLowerCase()) {
      case 'active':
        return canSuspend || canDeactivate;

      case 'suspended':
        return canUpdate;

      case 'deactivated':
        return canUpdate;

      default:
        return canUpdate;
    }
  }

  // =========================================================
  // STATUS CHANGE
  // =========================================================

  void _handleStatusChange(
    BuildContext context,
    WidgetRef ref,
    AdminUserRecord user, {
    required bool canUpdate,
    required bool canSuspend,
    required bool canDeactivate,
  }) {
    if (!_canChangeStatus(
      user,
      canUpdate: canUpdate,
      canSuspend: canSuspend,
      canDeactivate: canDeactivate,
    )) {
      return;
    }

    _handleStatusChangeAsync(
      context,
      ref,
      user,
      canUpdate: canUpdate,
      canSuspend: canSuspend,
      canDeactivate: canDeactivate,
    );
  }

  Future<void> _handleStatusChangeAsync(
    BuildContext context,
    WidgetRef ref,
    AdminUserRecord user, {
    required bool canUpdate,
    required bool canSuspend,
    required bool canDeactivate,
  }) async {
    final status = await _showStatusSelectionDialog(
      context,
      user,
      canUpdate: canUpdate,
      canSuspend: canSuspend,
      canDeactivate: canDeactivate,
    );

    if (status == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final reason = await _showStatusDialog(context, user, status);

    if (reason == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    try {
      await ref
          .read(usersControllerProvider.notifier)
          .changeUserStatus(
            userId: user.id,
            accountStatus: status,
            reason: reason,
          );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User account status updated successfully.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // =========================================================
  // STATUS SELECTION
  // =========================================================

  Future<String?> _showStatusSelectionDialog(
    BuildContext context,
    AdminUserRecord user, {
    required bool canUpdate,
    required bool canSuspend,
    required bool canDeactivate,
  }) {
    final currentStatus = user.accountStatus.toLowerCase();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Account Status'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Active'),
                  subtitle: const Text(
                    'Allow the user to access the platform.',
                  ),
                  enabled: canUpdate && currentStatus != 'active',
                  onTap: canUpdate && currentStatus != 'active'
                      ? () {
                          Navigator.of(dialogContext).pop('active');
                        }
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.pause_circle_outline),
                  title: const Text('Suspended'),
                  subtitle: const Text(
                    'Temporarily restrict the user account.',
                  ),
                  enabled: canSuspend && currentStatus != 'suspended',
                  onTap: canSuspend && currentStatus != 'suspended'
                      ? () {
                          Navigator.of(dialogContext).pop('suspended');
                        }
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined),
                  title: const Text('Deactivated'),
                  subtitle: const Text('Deactivate the user account.'),
                  enabled: canDeactivate && currentStatus != 'deactivated',
                  onTap: canDeactivate && currentStatus != 'deactivated'
                      ? () {
                          Navigator.of(dialogContext).pop('deactivated');
                        }
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // STATUS REASON DIALOG
  // =========================================================

  Future<String?> _showStatusDialog(
    BuildContext context,
    AdminUserRecord user,
    String status,
  ) async {
    final reasonController = TextEditingController();

    final requiresReason = status == 'suspended' || status == 'deactivated';

    final title = switch (status) {
      'suspended' => 'Suspend User',
      'deactivated' => 'Deactivate User',
      _ => 'Reactivate User',
    };

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are changing the account status for '
                    '${user.fullName}.',
                  ),
                  if (requiresReason) ...[
                    const SizedBox(height: 18),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Enter the reason for this action.',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (requiresReason && reasonController.text.trim().isEmpty) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(reasonController.text.trim());
                },
                child: Text(title),
              ),
            ],
          );
        },
      );
    } finally {
      reasonController.dispose();
    }
  }
}

// =========================================================
// PAGINATION BAR
// =========================================================

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.pagination,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSelected,
  });

  final UserPagination pagination;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    if (pagination.total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(
              'Page ${pagination.page} of '
              '${pagination.totalPages}',
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Previous page',
              onPressed: pagination.hasPreviousPage ? onPrevious : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: pagination.hasNextPage ? onNext : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// ERROR STATE
// =========================================================

class _UsersErrorState extends StatelessWidget {
  const _UsersErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to load users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
