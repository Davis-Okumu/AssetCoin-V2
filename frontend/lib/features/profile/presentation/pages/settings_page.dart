
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../data/models/profile_settings.dart';
import '../providers/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(profileSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _SettingsError(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileSettingsProvider),
        ),
        data: (settings) => _SettingsForm(
          settings: settings,
        ),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({
    required this.settings,
  });

  final ProfileSettings settings;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late ProfileSettings _settings;

  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  // =========================================
  // UPDATE SETTINGS
  // =========================================

  void _updateSettings(ProfileSettings updated) {
    final themeChanged = updated.theme != _settings.theme;

    setState(() {
      _settings = updated;
      _hasChanges = _settings.theme != widget.settings.theme ||
          _settings.language != widget.settings.language ||
          _settings.displayCurrency != widget.settings.displayCurrency ||
          _settings.marketingNotificationsEnabled !=
              widget.settings.marketingNotificationsEnabled ||
          _settings.emailUpdatesEnabled !=
              widget.settings.emailUpdatesEnabled;
    });

    if (themeChanged) {
      ref.read(appThemeModeProvider.notifier).updateTheme(
            _themeModeFromPreference(updated.theme),
          );
    }
  }

  // =========================================
  // SAVE SETTINGS
  // =========================================

  Future<void> _saveSettings() async {
    if (_saving || !_hasChanges) return;

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);

      final savedSettings =
          await repository.updateProfileSettings(_settings);

      if (!mounted) return;

      setState(() {
        _settings = savedSettings;
        _hasChanges = false;
      });

      ref.invalidate(profileSettingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your settings have been saved successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save settings: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // =========================================
  // RESET SETTINGS
  // =========================================

  void _resetChanges() {
    setState(() {
      _settings = widget.settings;
      _hasChanges = false;
    });

    ref.read(appThemeModeProvider.notifier).updateTheme(
          _themeModeFromPreference(widget.settings.theme),
        );
  }

  // =========================================
  // THEME MODE CONVERSION
  // =========================================

  ThemeMode _themeModeFromPreference(String preference) {
    switch (preference) {
      case 'dark':
        return ThemeMode.dark;

      case 'system':
        return ThemeMode.system;

      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  // =========================================
  // BUILD SETTINGS FORM
  // =========================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            children: [
              _buildIntroduction(),

              const SizedBox(height: 24),

              // =====================================
              // APPEARANCE
              // =====================================

              _buildSection(
                title: 'Appearance',
                subtitle: 'Customize how AssetCoin looks.',
                icon: Icons.palette_outlined,
                children: [
                  _buildThemeSelector(),
                ],
              ),

              const SizedBox(height: 18),

              // =====================================
              // REGIONAL PREFERENCES
              // =====================================

              _buildSection(
                title: 'Regional preferences',
                subtitle: 'Choose your language and display currency.',
                icon: Icons.language_outlined,
                children: [
                  _buildDropdown<String>(
                    title: 'Language',
                    subtitle: 'Application display language',
                    icon: Icons.translate_rounded,
                    value: _settings.language,
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'sw',
                        child: Text('Kiswahili'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      _updateSettings(
                        _settings.copyWith(language: value),
                      );
                    },
                  ),

                  const Divider(height: 24),

                  _buildDropdown<String>(
                    title: 'Display currency',
                    subtitle: 'Currency used to display asset values',
                    icon: Icons.currency_exchange_rounded,
                    value: _settings.displayCurrency,
                    items: const [
                      DropdownMenuItem(
                        value: 'KES',
                        child: Text('KES - Kenyan Shilling'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD - US Dollar'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR - Euro'),
                      ),
                      DropdownMenuItem(
                        value: 'GBP',
                        child: Text('GBP - British Pound'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      _updateSettings(
                        _settings.copyWith(displayCurrency: value),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =====================================
              // NOTIFICATIONS
              // =====================================

              _buildSection(
                title: 'Notifications',
                subtitle: 'Manage the updates you receive from AssetCoin.',
                icon: Icons.notifications_none_rounded,
                children: [
                  _buildSwitch(
                    title: 'Marketing notifications',
                    subtitle:
                        'Receive product announcements and promotional updates.',
                    icon: Icons.campaign_outlined,
                    value: _settings.marketingNotificationsEnabled,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(
                          marketingNotificationsEnabled: value,
                        ),
                      );
                    },
                  ),

                  const Divider(height: 24),

                  _buildSwitch(
                    title: 'Email updates',
                    subtitle:
                        'Receive important platform updates through email.',
                    icon: Icons.mark_email_unread_outlined,
                    value: _settings.emailUpdatesEnabled,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(
                          emailUpdatesEnabled: value,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =====================================
              // PRIVACY NAVIGATION INFORMATION
              // =====================================

              _buildPrivacyInformation(),

              const SizedBox(height: 18),

              _buildInformationCard(),
            ],
          ),
        ),

        _buildSaveBar(),
      ],
    );
  }

  // =========================================
  // INTRODUCTION
  // =========================================

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalize your experience',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: Color(0xFF17233D),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Manage your application appearance, regional preferences '
          'and communication settings.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // =========================================
  // SETTINGS SECTION
  // =========================================

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17233D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // =========================================
  // THEME SELECTOR
  // =========================================

  Widget _buildThemeSelector() {
    final themes = [
      (
        value: 'light',
        title: 'Light',
        subtitle: 'Bright appearance',
        icon: Icons.light_mode_outlined,
      ),
      (
        value: 'dark',
        title: 'Dark',
        subtitle: 'Dark appearance',
        icon: Icons.dark_mode_outlined,
      ),
      (
        value: 'system',
        title: 'System',
        subtitle: 'Follow device settings',
        icon: Icons.settings_suggest_outlined,
      ),
    ];

    return Column(
      children: themes.map((theme) {
        final selected = _settings.theme == theme.value;

        return GestureDetector(
          onTap: () {
            _updateSettings(
              _settings.copyWith(theme: theme.value),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.07)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : Colors.grey.shade200,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  theme.icon,
                  color: selected
                      ? AppColors.primary
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        theme.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? AppColors.primary
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================================
  // DROPDOWN FIELD
  // =========================================

  Widget _buildDropdown<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final availableValues = items.map((item) => item.value).toList();

    final selectedValue =
        availableValues.contains(value) ? value : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _leadingIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF17233D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<T>(
                initialValue: selectedValue,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                items: items,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================
  // SWITCH FIELD
  // =========================================

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _leadingIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF17233D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // =========================================
  // LEADING ICON
  // =========================================

  Widget _leadingIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        icon,
        size: 19,
        color: Colors.blue.shade700,
      ),
    );
  }

  // =========================================
  // PRIVACY INFORMATION
  // =========================================

  Widget _buildPrivacyInformation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFD3E2FF),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFF2457C5),
            size: 25,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183B75),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your profile visibility, email visibility '
                  'and phone visibility from the dedicated Privacy page.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF52627A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // INFORMATION CARD
  // =========================================

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your preferences are saved to your AssetCoin account. '
              'Some changes, such as language and theme, may require '
              'additional application-level integration before they '
              'change the entire app.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // SAVE BAR
  // =========================================

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_hasChanges) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _resetChanges,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: _hasChanges ? 2 : 1,
              child: ElevatedButton(
                onPressed: _saving || !_hasChanges
                    ? null
                    : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(0, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
// SETTINGS ERROR VIEW
// =============================================

class _SettingsError extends StatelessWidget {
  const _SettingsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load settings',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}