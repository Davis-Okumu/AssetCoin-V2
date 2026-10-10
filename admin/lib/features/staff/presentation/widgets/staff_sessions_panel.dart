import 'package:flutter/material.dart';

class StaffSessionsPanel extends StatelessWidget {
  const StaffSessionsPanel({
    super.key,
    required this.sessions,
    required this.onRevokeSession,
    this.isLoading = false,
    this.revokingSessionId,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> sessions;
  final Future<void> Function(int sessionId) onRevokeSession;
  final bool isLoading;
  final int? revokingSessionId;
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
                const Icon(Icons.devices_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Login Sessions',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Refresh sessions',
                    onPressed: isLoading ? null : onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Review devices and revoke sessions that should no longer have access.',
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
              _SessionsMessage(
                icon: Icons.error_outline,
                message: errorMessage!,
                action: onRefresh,
              )
            else if (sessions.isEmpty)
              const _SessionsMessage(
                icon: Icons.devices_other_outlined,
                message: 'No login sessions were found.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _SessionTile(
                    session: sessions[index],
                    onRevokeSession: onRevokeSession,
                    revokingSessionId: revokingSessionId,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onRevokeSession,
    required this.revokingSessionId,
  });

  final Map<String, dynamic> session;
  final Future<void> Function(int sessionId) onRevokeSession;
  final int? revokingSessionId;

  @override
  Widget build(BuildContext context) {
    final id = _readInt(session, ['id', 'sessionId', 'session_id']);

    final device = _read(session, [
      'deviceName',
      'device_name',
      'deviceType',
      'device_type',
    ], fallback: 'Unknown device');

    final browser = _read(session, ['browser', 'browserName', 'browser_name']);

    final operatingSystem = _read(session, [
      'operatingSystem',
      'operating_system',
      'os',
    ]);

    final ipAddress = _read(session, ['ipAddress', 'ip_address', 'ip']);

    final createdAt = _read(session, [
      'createdAt',
      'created_at',
      'startedAt',
      'started_at',
    ]);

    final lastActivity = _read(session, [
      'lastActivityAt',
      'last_activity_at',
      'lastSeenAt',
      'last_seen_at',
      'lastUsedAt',
    ]);

    final expiresAt = _read(session, ['expiresAt', 'expires_at']);

    final isRevoked = _readBool(session, [
      'isRevoked',
      'is_revoked',
      'revoked',
    ]);

    final isActive = _readBool(session, [
      'isActive',
      'is_active',
      'active',
    ], fallback: !isRevoked);

    final isCurrent = _readBool(session, [
      'isCurrent',
      'is_current',
      'current',
    ]);

    final isBusy = id != null && revokingSessionId == id;
    final canRevoke = id != null && isActive && !isRevoked && !isCurrent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: Icon(
              _deviceIcon(device, operatingSystem),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      device,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (isCurrent) const _SessionBadge(label: 'Current'),
                    _SessionBadge(
                      label: isRevoked
                          ? 'Revoked'
                          : isActive
                          ? 'Active'
                          : 'Expired / inactive',
                      isActive: isActive && !isRevoked,
                      isRevoked: isRevoked,
                    ),
                  ],
                ),
                if (browser.isNotEmpty || operatingSystem.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    [
                      if (browser.isNotEmpty) browser,
                      if (operatingSystem.isNotEmpty) operatingSystem,
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'IP address: $ipAddress',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Started: ${_formatDate(createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (lastActivity.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last activity: ${_formatDate(lastActivity)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (expiresAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expires: ${_formatDate(expiresAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (id == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Session ID unavailable; revocation is disabled.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canRevoke)
            IconButton(
              tooltip: 'Revoke session',
              onPressed: isBusy ? null : () => _confirmRevoke(context, id!),
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_outlined),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke login session?'),
        content: const Text(
          'This action will terminate the selected session if the server '
          'supports revocation for it. The staff member may need to sign in '
          'again on that device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Revoke session'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onRevokeSession(sessionId);
    }
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

  int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;

      if (value is int) return value;

      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }

    return null;
  }

  bool _readBool(
    Map<String, dynamic> data,
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) return value;
      if (value is num) return value != 0;

      if (value != null) {
        final normalized = value.toString().toLowerCase();

        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }

        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }

    return fallback;
  }

  IconData _deviceIcon(String device, String os) {
    final value = '$device $os'.toLowerCase();

    if (value.contains('mobile') ||
        value.contains('android') ||
        value.contains('iphone') ||
        value.contains('ios')) {
      return Icons.smartphone_outlined;
    }

    if (value.contains('tablet') || value.contains('ipad')) {
      return Icons.tablet_outlined;
    }

    return Icons.computer_outlined;
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) return value;

    final date = parsed.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({
    required this.label,
    this.isActive = false,
    this.isRevoked = false,
  });

  final String label;
  final bool isActive;
  final bool isRevoked;

  @override
  Widget build(BuildContext context) {
    final Color color;

    if (label == 'Current') {
      color = Colors.blue.shade700;
    } else if (isRevoked) {
      color = Colors.red.shade700;
    } else if (isActive) {
      color = Colors.green.shade700;
    } else {
      color = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SessionsMessage extends StatelessWidget {
  const _SessionsMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final VoidCallback? action;

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
              TextButton(onPressed: action, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
