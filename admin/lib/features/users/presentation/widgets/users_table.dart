import 'package:flutter/material.dart';

import '../../domain/admin_user_record.dart';

class UsersTable extends StatelessWidget {
  const UsersTable({
    super.key,
    required this.users,
    this.loading = false,
    this.onUserTap,
    this.onEdit,
    this.onChangeStatus,
  });

  final List<AdminUserRecord> users;
  final bool loading;

  final ValueChanged<AdminUserRecord>? onUserTap;
  final ValueChanged<AdminUserRecord>? onEdit;
  final ValueChanged<AdminUserRecord>? onChangeStatus;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (loading && users.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (users.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 52,
                dataRowMinHeight: 68,
                dataRowMaxHeight: 82,
                horizontalMargin: 20,
                columnSpacing: 28,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Contact')),
                  DataColumn(label: Text('KYC')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Last Login')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users
                    .map((user) => _buildUserRow(context, user))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // USER ROW
  // =========================================================

  DataRow _buildUserRow(BuildContext context, AdminUserRecord user) {
    return DataRow(
      onSelectChanged: onUserTap == null ? null : (_) => onUserTap!(user),
      cells: [
        DataCell(_buildUserCell(context, user)),
        DataCell(_buildContactCell(user)),
        DataCell(
          _buildStatusBadge(
            context,
            user.kycStatus,
            _kycStatusColor(user.kycStatus),
          ),
        ),
        DataCell(_buildRoleBadge(context, user.role)),
        DataCell(
          _buildStatusBadge(
            context,
            user.accountStatus,
            _accountStatusColor(user.accountStatus),
          ),
        ),
        DataCell(
          Text(
            _formatDate(user.lastLoginAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        DataCell(
          Text(
            _formatDate(user.createdAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        DataCell(_buildActions(context, user)),
      ],
    );
  }

  // =========================================================
  // USER CELL
  // =========================================================

  Widget _buildUserCell(BuildContext context, AdminUserRecord user) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          _buildAvatar(context, user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isEmpty ? 'Unnamed User' : user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: ${user.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // AVATAR
  // =========================================================

  Widget _buildAvatar(BuildContext context, AdminUserRecord user) {
    final theme = Theme.of(context);

    final initials = _initials(user);

    if (user.profilePhotoUrl != null &&
        user.profilePhotoUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundImage: NetworkImage(user.profilePhotoUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 21,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  // =========================================================
  // CONTACT CELL
  // =========================================================

  Widget _buildContactCell(AdminUserRecord user) {
    return SizedBox(
      width: 210,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.email != null && user.email!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if ((user.email == null || user.email!.isEmpty) &&
              (user.phone == null || user.phone!.isEmpty))
            const Text('No contact information'),
        ],
      ),
    );
  }

  // =========================================================
  // ROLE BADGE
  // =========================================================

  Widget _buildRoleBadge(BuildContext context, String role) {
    final theme = Theme.of(context);
    final normalized = role.trim().toLowerCase();

    String label;

    switch (normalized) {
      case 'admin':
        label = 'Admin';
        break;
      case 'super_admin':
        label = 'Super Admin';
        break;
      case 'staff':
        label = 'Staff';
        break;
      case 'user':
      default:
        label = 'Customer';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================

  Widget _buildStatusBadge(BuildContext context, String status, Color color) {
    final label = _formatStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // ACTIONS
  // =========================================================

  Widget _buildActions(BuildContext context, AdminUserRecord user) {
    return PopupMenuButton<String>(
      tooltip: 'User actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onUserTap?.call(user);
            break;

          case 'edit':
            onEdit?.call(user);
            break;

          case 'status':
            onChangeStatus?.call(user);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility_outlined),
            title: Text('View details'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit user'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'status',
          child: ListTile(
            leading: Icon(Icons.manage_accounts_outlined),
            title: Text('Change status'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 52,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try adjusting your search or filters.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String _initials(AdminUserRecord user) {
    final first = user.firstName.trim();
    final last = user.lastName.trim();

    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }

    if (first.isNotEmpty) {
      return first.substring(0, 1).toUpperCase();
    }

    if (last.isNotEmpty) {
      return last.substring(0, 1).toUpperCase();
    }

    return '?';
  }

  String _formatStatus(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Never';
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day/$month/$year';
  }

  Color _kycStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'pending':
      case 'under_review':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  Color _accountStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;

      case 'suspended':
        return Colors.orange;

      case 'deactivated':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
