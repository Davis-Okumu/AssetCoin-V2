
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notification_preference.dart';
import '../providers/notification_providers.dart';

class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: preferencesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(notificationPreferencesProvider);
          },
        ),
        data: (preferences) {
          return _NotificationPreferencesForm(
            key: ValueKey(
              preferences
                  .map(
                    (preference) =>
                        '${preference.notificationType}:'
                        '${preference.inAppEnabled}:'
                        '${preference.emailEnabled}:'
                        '${preference.smsEnabled}',
                  )
                  .join('|'),
            ),
            preferences: preferences,
          );
        },
      ),
    );
  }
}

class _NotificationPreferencesForm extends ConsumerStatefulWidget {
  final List<NotificationPreference> preferences;

  const _NotificationPreferencesForm({
    super.key,
    required this.preferences,
  });

  @override
  ConsumerState<_NotificationPreferencesForm> createState() =>
      _NotificationPreferencesFormState();
}

class _NotificationPreferencesFormState
    extends ConsumerState<_NotificationPreferencesForm> {
  late List<NotificationPreference> _preferences;

  bool _isSaving = false;

  static const List<String> _notificationTypes = [
    'security',
    'wallet',
    'trading',
    'asset',
    'kyc',
    'system',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = _completePreferences(widget.preferences);
  }

  List<NotificationPreference> _completePreferences(
    List<NotificationPreference> existing,
  ) {
    return _notificationTypes.map((type) {
      final matchingPreference = existing.where(
        (preference) => preference.notificationType == type,
      );

      if (matchingPreference.isNotEmpty) {
        return matchingPreference.first;
      }

      return NotificationPreference(
        notificationType: type,
        inAppEnabled: true,
        emailEnabled: false,
        smsEnabled: false,
      );
    }).toList();
  }

  NotificationPreference _getPreference(String type) {
    return _preferences.firstWhere(
      (preference) => preference.notificationType == type,
    );
  }

  void _updatePreference(
    String type, {
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    setState(() {
      _preferences = _preferences.map((preference) {
        if (preference.notificationType != type) {
          return preference;
        }

        return preference.copyWith(
          inAppEnabled: inAppEnabled,
          emailEnabled: emailEnabled,
          smsEnabled: smsEnabled,
        );
      }).toList();
    });
  }

  Future<void> _savePreferences() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedPreferences = await ref
          .read(notificationRepositoryProvider)
          .updateNotificationPreferences(_preferences);

      if (!mounted) return;

      setState(() {
        _preferences = _completePreferences(updatedPreferences);
        _isSaving = false;
      });

      ref.invalidate(notificationPreferencesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification preferences saved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save notification preferences. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetPreferences() {
    setState(() {
      _preferences = _completePreferences(widget.preferences);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildIntroduction(colorScheme),
              const SizedBox(height: 22),

              _buildChannelLegend(colorScheme),
              const SizedBox(height: 18),

              ..._notificationTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCategoryCard(
                    type,
                    colorScheme,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              _buildImportantNotice(colorScheme),
            ],
          ),
        ),

        _buildBottomActions(theme),
      ],
    );
  }

  Widget _buildIntroduction(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay informed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Choose how you would like to receive updates '
                  'about your AssetCoin account.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelLegend(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery channels',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Enable or disable each channel for every category.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            _ChannelLabel(
              icon: Icons.notifications_none_rounded,
              label: 'In-app',
            ),
            SizedBox(width: 18),
            _ChannelLabel(
              icon: Icons.email_outlined,
              label: 'Email',
            ),
            SizedBox(width: 18),
            _ChannelLabel(
              icon: Icons.sms_outlined,
              label: 'SMS',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String type,
    ColorScheme colorScheme,
  ) {
    final preference = _getPreference(type);
    final category = _categoryDetails(type);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              height: 1,
            ),

            _buildSwitch(
              title: 'In-app notifications',
              icon: Icons.notifications_none_rounded,
              value: preference.inAppEnabled,
              onChanged: (value) {
                _updatePreference(
                  type,
                  inAppEnabled: value,
                );
              },
            ),

            _buildSwitch(
              title: 'Email notifications',
              icon: Icons.email_outlined,
              value: preference.emailEnabled,
              onChanged: (value) {
                _updatePreference(
                  type,
                  emailEnabled: value,
                );
              },
            ),

            _buildSwitch(
              title: 'SMS notifications',
              icon: Icons.sms_outlined,
              value: preference.smsEnabled,
              onChanged: (value) {
                _updatePreference(
                  type,
                  smsEnabled: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      secondary: Icon(
        icon,
        size: 19,
        color: Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      onChanged: _isSaving ? null : onChanged,
    );
  }

  Widget _buildImportantNotice(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Some essential account or security notices may still '
              'be delivered when necessary to protect your account '
              'or meet platform requirements.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _resetPreferences,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Discard',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePreferences,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Preferences',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationCategory _categoryDetails(String type) {
    switch (type) {
      case 'security':
        return const _NotificationCategory(
          title: 'Security',
          description: 'Login activity and account protection.',
          icon: Icons.shield_outlined,
          color: Color(0xFFE53935),
        );

      case 'wallet':
        return const _NotificationCategory(
          title: 'Wallet',
          description: 'Deposits, withdrawals and wallet activity.',
          icon: Icons.account_balance_wallet_outlined,
          color: Color(0xFF1565D8),
        );

      case 'trading':
        return const _NotificationCategory(
          title: 'Trading',
          description: 'Buy orders, sell orders and transactions.',
          icon: Icons.swap_horiz_rounded,
          color: Color(0xFF00897B),
        );

      case 'asset':
        return const _NotificationCategory(
          title: 'Assets',
          description: 'Asset submissions, reviews and tokenization.',
          icon: Icons.real_estate_agent_outlined,
          color: Color(0xFF8E24AA),
        );

      case 'kyc':
        return const _NotificationCategory(
          title: 'KYC & Verification',
          description: 'Identity verification and document updates.',
          icon: Icons.verified_user_outlined,
          color: Color(0xFFEF6C00),
        );

      default:
        return const _NotificationCategory(
          title: 'System',
          description: 'Platform announcements and general updates.',
          icon: Icons.settings_outlined,
          color: Color(0xFF546E7A),
        );
    }
  }
}

class _ChannelLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChannelLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NotificationCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _NotificationCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 55,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not retrieve your notification settings. '
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
