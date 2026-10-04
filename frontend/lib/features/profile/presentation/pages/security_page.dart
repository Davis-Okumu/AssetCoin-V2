import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/active_sessions.dart';
import '../../data/models/login_activity.dart';
import '../../data/models/security_settings.dart';
import '../providers/profile_providers.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({
    super.key,
  });

  @override
  ConsumerState<SecurityPage> createState() =>
      _SecurityPageState();
}

class _SecurityPageState
    extends ConsumerState<SecurityPage> {
  bool _changingPassword = false;
  bool _updatingBiometric = false;
  bool _updatingLoginNotifications = false;
  bool _revokingOthers = false;

  @override
  Widget build(BuildContext context) {
    final securityAsync =
        ref.watch(securitySettingsProvider);

    final sessionsAsync =
        ref.watch(activeSessionsProvider);

    final activityAsync =
        ref.watch(loginActivityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ),
          children: [
            _buildSecurityHeader(),

            const SizedBox(height: 20),

            securityAsync.when(
              loading: () => const _SectionLoading(),
              error: (error, _) => _ErrorCard(
                message:
                    'Unable to load your security settings.',
                onRetry: () {
                  ref.invalidate(
                    securitySettingsProvider,
                  );
                },
              ),
              data: _buildSecuritySettings,
            ),

            const SizedBox(height: 20),

            _buildPasswordSection(),

            const SizedBox(height: 20),

            sessionsAsync.when(
              loading: () => const _SectionLoading(),
              error: (error, _) => _ErrorCard(
                message:
                    'Unable to load active sessions.',
                onRetry: () {
                  ref.invalidate(
                    activeSessionsProvider,
                  );
                },
              ),
              data: _buildSessionsSection,
            ),

            const SizedBox(height: 20),

            activityAsync.when(
              loading: () => const _SectionLoading(),
              error: (error, _) => _ErrorCard(
                message:
                    'Unable to load login activity.',
                onRetry: () {
                  ref.invalidate(
                    loginActivityProvider,
                  );
                },
              ),
              data: _buildActivitySection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(
              alpha: 0.82,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.shield_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Protect your account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage your password, sessions and security preferences.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(
    SecuritySettings settings,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Security Preferences',
          Icons.security_outlined,
        ),
        const SizedBox(height: 10),
        _settingsCard(
          children: [
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric login',
              subtitle:
                  'Use biometric authentication when supported.',
              value: settings.biometricEnabled,
              enabled: !_updatingBiometric,
              onChanged: _updateBiometric,
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Login notifications',
              subtitle:
                  'Receive notifications when a new login is detected.',
              value:
                  settings.loginNotificationEnabled,
              enabled:
                  !_updatingLoginNotifications,
              onChanged:
                  _updateLoginNotifications,
            ),
            const Divider(height: 1),
            _buildTwoFactorTile(settings),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoFactorTile(
    SecuritySettings settings,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: _iconContainer(
        Icons.verified_user_outlined,
      ),
      title: const Text(
        'Two-factor authentication',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        settings.twoFactorEnabled
            ? settings.twoFactorLabel
            : 'Not enabled',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: settings.twoFactorEnabled
              ? Colors.green.withValues(
                  alpha: 0.10,
                )
              : Colors.orange.withValues(
                  alpha: 0.10,
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          settings.twoFactorEnabled
              ? 'Enabled'
              : 'Not enabled',
          style: TextStyle(
            color: settings.twoFactorEnabled
                ? Colors.green.shade700
                : Colors.orange.shade800,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Password',
          Icons.lock_outline,
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _iconContainer(
              Icons.password_outlined,
            ),
            title: const Text(
              'Change password',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'Update your account password.',
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: _changingPassword
                ? null
                : _showChangePasswordDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsSection(
    List<ActiveSession> sessions,
  ) {
    final activeSessions = sessions
        .where(
          (session) =>
              !session.isRevoked &&
              !session.isExpired,
        )
        .toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                'Active Sessions',
                Icons.devices_outlined,
              ),
            ),
            if (activeSessions.length > 1)
              TextButton(
                onPressed: _revokingOthers
                    ? null
                    : _confirmRevokeOthers,
                child: _revokingOthers
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Log out others',
                      ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (activeSessions.isEmpty)
          _emptyCard(
            icon: Icons.devices_other_outlined,
            title: 'No active sessions',
            message:
                'There are currently no active device sessions.',
          )
        else
          ...activeSessions.map(
            _buildSessionCard,
          ),
      ],
    );
  }

  Widget _buildSessionCard(
    ActiveSession session,
  ) {
    final deviceName =
        _sessionDeviceName(session);

    final subtitleParts = <String>[];

    if (session.ipAddress != null &&
        session.ipAddress!.isNotEmpty) {
      subtitleParts.add(
        session.ipAddress!,
      );
    }

    if (session.lastActiveAt != null) {
      subtitleParts.add(
        'Active ${_formatDateTime(session.lastActiveAt!)}',
      );
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _deviceIcon(session.deviceType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          deviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Text(
                            'This device',
                            style: TextStyle(
                              color:
                                  AppColors.primary,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleParts.isEmpty
                        ? 'Active session'
                        : subtitleParts.join(' • '),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!session.isCurrent)
              IconButton(
                tooltip: 'Log out this device',
                onPressed: () =>
                    _confirmRevokeSession(session),
                icon: const Icon(
                  Icons.logout_outlined,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(
    List<LoginActivity> activity,
  ) {
    final visibleActivity =
        activity.take(10).toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Login Activity',
          Icons.history,
        ),
        const SizedBox(height: 10),
        if (visibleActivity.isEmpty)
          _emptyCard(
            icon: Icons.history_toggle_off,
            title: 'No login activity',
            message:
                'Your recent security activity will appear here.',
          )
        else
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                for (int index = 0;
                    index < visibleActivity.length;
                    index++) ...[
                  _buildActivityTile(
                    visibleActivity[index],
                  ),
                  if (index !=
                      visibleActivity.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityTile(
    LoginActivity activity,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      leading: _activityIcon(
        activity.eventType,
      ),
      title: Text(
        activity.readableEventType,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        [
          if (activity.description != null &&
              activity.description!
                  .trim()
                  .isNotEmpty)
            activity.description!,
          if (activity.ipAddress != null &&
              activity.ipAddress!
                  .trim()
                  .isNotEmpty)
            'IP: ${activity.ipAddress}',
        ].join(' • '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: activity.createdAt == null
          ? null
          : Text(
              _formatDateTime(
                activity.createdAt!,
              ),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
    );
  }

  Future<void> _updateBiometric(
    bool enabled,
  ) async {
    setState(() {
      _updatingBiometric = true;
    });

    try {
      await ref
          .read(profileActionsProvider)
          .updateSecuritySettings(
            biometricEnabled: enabled,
          );

      if (!mounted) return;

      _showMessage(
        enabled
            ? 'Biometric preference enabled.'
            : 'Biometric preference disabled.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _errorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingBiometric = false;
        });
      }
    }
  }

  Future<void> _updateLoginNotifications(
    bool enabled,
  ) async {
    setState(() {
      _updatingLoginNotifications = true;
    });

    try {
      await ref
          .read(profileActionsProvider)
          .updateSecuritySettings(
            loginNotificationEnabled:
                enabled,
          );

      if (!mounted) return;

      _showMessage(
        enabled
            ? 'Login notifications enabled.'
            : 'Login notifications disabled.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _errorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingLoginNotifications =
              false;
        });
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController =
        TextEditingController();
    final newController =
        TextEditingController();
    final confirmController =
        TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final formKey =
        GlobalKey<FormState>();

    final changed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Change password',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller:
                            currentController,
                        obscureText:
                            obscureCurrent,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Current password',
                          prefixIcon:
                              const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrent =
                                    !obscureCurrent;
                              });
                            },
                            icon: Icon(
                              obscureCurrent
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter your current password.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller:
                            newController,
                        obscureText:
                            obscureNew,
                        decoration:
                            InputDecoration(
                          labelText:
                              'New password',
                          prefixIcon:
                              const Icon(
                            Icons.lock_reset_outlined,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureNew =
                                    !obscureNew;
                              });
                            },
                            icon: Icon(
                              obscureNew
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter a new password.';
                          }

                          if (value.length < 8) {
                            return 'Use at least 8 characters.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller:
                            confirmController,
                        obscureText:
                            obscureConfirm,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Confirm new password',
                          prefixIcon:
                              const Icon(
                            Icons.lock_reset_outlined,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm =
                                    !obscureConfirm;
                              });
                            },
                            icon: Icon(
                              obscureConfirm
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Confirm your new password.';
                          }

                          if (value !=
                              newController.text) {
                            return 'Passwords do not match.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                    false,
                  ),
                  child:
                      const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _changingPassword
                      ? null
                      : () async {
                          if (!formKey
                              .currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            _changingPassword =
                                true;
                          });

                          try {
                            await ref
                                .read(
                                  profileActionsProvider,
                                )
                                .changePassword(
                                  currentPassword:
                                      currentController
                                          .text,
                                  newPassword:
                                      newController
                                          .text,
                                );

                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          } catch (error) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              _changingPassword =
                                  false;
                            });

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _errorMessage(
                                    error,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  child: _changingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update password',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (changed == true && mounted) {
      _showMessage(
        'Password changed successfully.',
      );
    }
  }

  Future<void> _confirmRevokeSession(
    ActiveSession session,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Log out this device?',
          ),
          content: Text(
            'This will end the session on ${_sessionDeviceName(session)}.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(profileActionsProvider)
          .revokeSession(session.id);

      if (!mounted) return;

      _showMessage(
        'The device session was logged out.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _errorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _confirmRevokeOthers() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Log out other devices?',
          ),
          content: const Text(
            'All other active device sessions will be logged out. Your current device will remain signed in.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text(
                'Log out others',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _revokingOthers = true;
    });

    try {
      await ref
          .read(profileActionsProvider)
          .revokeOtherSessions();

      if (!mounted) return;

      _showMessage(
        'Other device sessions have been logged out.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _errorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _revokingOthers = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(securitySettingsProvider);
    ref.invalidate(activeSessionsProvider);
    ref.invalidate(loginActivityProvider);

    await Future.wait([
      ref.read(securitySettingsProvider.future),
      ref.read(activeSessionsProvider.future),
      ref.read(loginActivityProvider.future),
    ]);
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      secondary: _iconContainer(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _iconContainer(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 21,
      ),
    );
  }

  Widget _deviceIcon(String? deviceType) {
    final type =
        deviceType?.toLowerCase() ?? '';

    IconData icon;

    if (type.contains('ios') ||
        type.contains('iphone')) {
      icon = Icons.phone_iphone;
    } else if (type.contains('android')) {
      icon = Icons.android;
    } else if (type.contains('tablet')) {
      icon = Icons.tablet_android;
    } else if (type.contains('web') ||
        type.contains('browser')) {
      icon = Icons.language;
    } else {
      icon = Icons.devices_outlined;
    }

    return _iconContainer(icon);
  }

  Widget _activityIcon(String eventType) {
    final normalized =
        eventType.toLowerCase();

    IconData icon;

    if (normalized.contains('login')) {
      icon = Icons.login_outlined;
    } else if (normalized.contains('logout')) {
      icon = Icons.logout_outlined;
    } else if (normalized.contains('password')) {
      icon = Icons.password_outlined;
    } else if (normalized.contains('session')) {
      icon = Icons.devices_outlined;
    } else if (normalized.contains('two_factor')) {
      icon = Icons.verified_user_outlined;
    } else {
      icon = Icons.security_outlined;
    }

    return _iconContainer(icon);
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 38,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sessionDeviceName(
    ActiveSession session,
  ) {
    if (session.deviceName != null &&
        session.deviceName!.trim().isNotEmpty) {
      return session.deviceName!;
    }

    if (session.deviceType != null &&
        session.deviceType!.trim().isNotEmpty) {
      return session.deviceType!;
    }

    return 'Unknown device';
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period =
        local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} '
        '$hour:$minute $period';
  }

  String _errorMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();

      if (message.startsWith(
        'ProfileRepositoryException:',
      )) {
        return message.replaceFirst(
          'ProfileRepositoryException:',
          '',
        ).trim();
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}