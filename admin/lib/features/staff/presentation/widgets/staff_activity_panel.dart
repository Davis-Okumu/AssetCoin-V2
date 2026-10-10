import 'package:flutter/material.dart';

class StaffActivityPanel extends StatelessWidget {
  const StaffActivityPanel({
    super.key,
    required this.activities,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> activities;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Administrative Activity',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Refresh activity',
                    onPressed: isLoading ? null : onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Review actions recorded for this staff account.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ActivityMessage(
                icon: Icons.error_outline,
                message: errorMessage!,
                action: onRefresh,
                actionLabel: 'Retry',
              )
            else if (activities.isEmpty)
              const _ActivityMessage(
                icon: Icons.history_toggle_off,
                message: 'No activity records were found.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _ActivityTile(activity: activities[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final Map<String, dynamic> activity;

  @override
  Widget build(BuildContext context) {
    final action = _read(activity, [
      'action',
      'actionType',
      'eventType',
      'event',
    ], fallback: 'Activity recorded');

    final module = _read(activity, [
      'module',
      'resource',
      'entityType',
    ], fallback: 'Platform');

    final description = _read(activity, [
      'description',
      'details',
      'message',
      'summary',
    ]);

    final actor = _read(activity, [
      'actorName',
      'performedBy',
      'staffName',
      'userName',
    ]);

    final timestamp = _read(activity, [
      'createdAt',
      'timestamp',
      'created_at',
      'occurredAt',
    ]);

    final ipAddress = _read(activity, ['ipAddress', 'ip_address', 'ip']);

    final icon = _iconForAction(action);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatLabel(action),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description.isNotEmpty
                      ? description
                      : 'Module: ${_formatLabel(module)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (actor.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Performed by: $actor',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'IP address: $ipAddress',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatTimestamp(timestamp),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ModuleLabel(module: module),
        ],
      ),
    );
  }

  String _read(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  IconData _iconForAction(String action) {
    final normalized = action.toLowerCase();

    if (normalized.contains('login')) {
      return Icons.login;
    }
    if (normalized.contains('logout')) {
      return Icons.logout;
    }
    if (normalized.contains('permission') || normalized.contains('role')) {
      return Icons.admin_panel_settings_outlined;
    }
    if (normalized.contains('create') || normalized.contains('invite')) {
      return Icons.person_add_alt_1_outlined;
    }
    if (normalized.contains('delete') || normalized.contains('remove')) {
      return Icons.delete_outline;
    }
    if (normalized.contains('suspend') || normalized.contains('revoke')) {
      return Icons.block_outlined;
    }
    if (normalized.contains('update') || normalized.contains('edit')) {
      return Icons.edit_outlined;
    }
    if (normalized.contains('approve')) {
      return Icons.check_circle_outline;
    }

    return Icons.receipt_long_outlined;
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _formatTimestamp(String value) {
    if (value.isEmpty) return 'Time unavailable';

    final parsed = DateTime.tryParse(value);

    if (parsed == null) return value;

    final local = parsed.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _ModuleLabel extends StatelessWidget {
  const _ModuleLabel({required this.module});

  final String module;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        module.replaceAll('_', ' '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({
    required this.icon,
    required this.message,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: action,
                child: Text(actionLabel ?? 'Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
