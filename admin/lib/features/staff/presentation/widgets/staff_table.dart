import 'package:flutter/material.dart';

import '../../data/models/admin_staff_model.dart';
import 'staff_status_badge.dart';

class StaffTable extends StatelessWidget {
  const StaffTable({
    super.key,
    required this.staff,
    required this.onView,
    required this.onEdit,
    required this.onChangeStatus,
    this.isLoading = false,
  });

  final List<AdminStaffModel> staff;
  final ValueChanged<AdminStaffModel> onView;
  final ValueChanged<AdminStaffModel> onEdit;
  final ValueChanged<AdminStaffModel> onChangeStatus;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && staff.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (staff.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 42,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 12),
            Text(
              'No staff members found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your search or filters.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 28,
                horizontalMargin: 20,
                headingRowHeight: 54,
                dataRowMinHeight: 68,
                dataRowMaxHeight: 76,
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columns: const [
                  DataColumn(label: Text('Staff Member')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Last Login')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: staff.map(_buildRow).toList(),
              ),
            ),
          ),
        ),
        if (isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  DataRow _buildRow(AdminStaffModel member) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 230,
            child: Row(
              children: [
                _StaffAvatar(member: member),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName.isEmpty
                            ? 'Unnamed staff'
                            : member.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              member.roleName ?? member.roleCode ?? 'Unassigned',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(StaffStatusBadge(status: member.accountStatus)),
        DataCell(
          SizedBox(width: 140, child: Text(_formatDate(member.lastLoginAt))),
        ),
        DataCell(_buildActions(member)),
      ],
    );
  }

  Widget _buildActions(AdminStaffModel member) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View details',
          onPressed: () => onView(member),
          icon: const Icon(Icons.visibility_outlined),
        ),
        IconButton(
          tooltip: 'Edit staff',
          onPressed: () => onEdit(member),
          icon: const Icon(Icons.edit_outlined),
        ),
        PopupMenuButton<String>(
          tooltip: 'More actions',
          onSelected: (action) {
            if (action == 'status') {
              onChangeStatus(member);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'status',
              child: Row(
                children: [
                  Icon(
                    member.isAccountActive
                        ? Icons.pause_circle_outline
                        : Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    member.isAccountActive
                        ? 'Change account status'
                        : 'Change account status',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Never';

    final date = value.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year\n$hour:$minute';
  }
}

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({required this.member});

  final AdminStaffModel member;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member.profilePhotoUrl;

    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: photoUrl != null && photoUrl.trim().isNotEmpty
          ? NetworkImage(photoUrl)
          : null,
      child: photoUrl == null || photoUrl.trim().isEmpty
          ? Text(
              _initials(member),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  String _initials(AdminStaffModel member) {
    final first = member.firstName.trim();
    final last = member.lastName.trim();

    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';

    final initials = '$firstInitial$lastInitial'.toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }
}
