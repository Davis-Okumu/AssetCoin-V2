
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../profile/data/models/profile_settings.dart';
import '../providers/profile_providers.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(profileSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 54,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load privacy settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(profileSettingsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (settings) => _PrivacySettingsForm(
          settings: settings,
        ),
      ),
    );
  }
}

class _PrivacySettingsForm extends ConsumerStatefulWidget {
  const _PrivacySettingsForm({
    required this.settings,
  });

  final ProfileSettings settings;

  @override
  ConsumerState<_PrivacySettingsForm> createState() =>
      _PrivacySettingsFormState();
}

class _PrivacySettingsFormState
    extends ConsumerState<_PrivacySettingsForm> {
  late ProfileSettings _settings;

  bool _saving = false;

  bool get _hasChanges =>
      _settings.profileVisibility !=
          widget.settings.profileVisibility ||
      _settings.showEmail != widget.settings.showEmail ||
      _settings.showPhone != widget.settings.showPhone;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(covariant _PrivacySettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  void _updateVisibility(String visibility) {
    setState(() {
      _settings = _settings.copyWith(
        profileVisibility: visibility,
      );
    });
  }

  void _updateShowEmail(bool value) {
    setState(() {
      _settings = _settings.copyWith(
        showEmail: value,
      );
    });
  }

  void _updateShowPhone(bool value) {
    setState(() {
      _settings = _settings.copyWith(
        showPhone: value,
      );
    });
  }

  Future<void> _saveSettings() async {
    if (!_hasChanges || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final updatedSettings = await ref
          .read(profileRepositoryProvider)
          .updateProfileSettings(_settings);

      if (!mounted) return;

      setState(() {
        _settings = updatedSettings;
      });

      ref.invalidate(profileSettingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy settings updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save privacy settings. Please try again.',
          ),
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

  void _discardChanges() {
    setState(() {
      _settings = widget.settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPublic = _settings.profileVisibility == 'public';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildIntroduction(),
              const SizedBox(height: 24),
              _buildVisibilitySection(isPublic),
              const SizedBox(height: 20),
              _buildInformationSection(isPublic),
              const SizedBox(height: 20),
              _buildPrivacyNotice(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_hasChanges) _buildSaveBar(),
      ],
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF2FF),
            Color(0xFFFFF0F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFF2457C5),
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B75),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Choose how your profile information may be '
                  'displayed to other AssetCoin users.',
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildVisibilitySection(bool isPublic) {
    return _sectionCard(
      title: 'Profile visibility',
      subtitle: 'Control who can view your profile.',
      icon: Icons.visibility_outlined,
      children: [
        _visibilityOption(
          title: 'Private',
          subtitle: 'Keep your profile information private.',
          value: 'private',
          icon: Icons.lock_outline,
        ),
        const Divider(height: 1),
        _visibilityOption(
          title: 'Public',
          subtitle: 'Allow other users to view your permitted profile information.',
          value: 'public',
          icon: Icons.public,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPublic
                ? const Color(0xFFEAF2FF)
                : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isPublic
                    ? Icons.public
                    : Icons.lock_outline,
                color: isPublic
                    ? const Color(0xFF2457C5)
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isPublic
                      ? 'Your profile is set to public.'
                      : 'Your profile is set to private.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _visibilityOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final selected = _settings.profileVisibility == value;

    return InkWell(
      onTap: () => _updateVisibility(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF2457C5)
                  : Colors.grey,
              size: 23,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _settings.profileVisibility,
              activeColor: const Color(0xFF2457C5),
              onChanged: (selectedValue) {
                if (selectedValue != null) {
                  _updateVisibility(selectedValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection(bool isPublic) {
    return _sectionCard(
      title: 'Profile information',
      subtitle: 'Choose which contact details may be displayed.',
      icon: Icons.person_outline,
      children: [
        _privacySwitch(
          title: 'Show email address',
          subtitle: 'Allow your email address to appear on your public profile.',
          value: _settings.showEmail,
          onChanged: _updateShowEmail,
          enabled: isPublic,
          icon: Icons.email_outlined,
        ),
        const Divider(height: 1),
        _privacySwitch(
          title: 'Show phone number',
          subtitle: 'Allow your phone number to appear on your public profile.',
          value: _settings.showPhone,
          onChanged: _updateShowPhone,
          enabled: isPublic,
          icon: Icons.phone_outlined,
        ),
        if (!isPublic) ...[
          const SizedBox(height: 12),
          Text(
            'Set your profile to Public to configure these display options. '
            'Your saved choices will be preserved.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _privacySwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool enabled,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? const Color(0xFF2457C5)
                : Colors.grey,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: const Color(0xFF2457C5),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD9A3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB66A00),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your identity documents, National ID, passwords, '
              'and private KYC information must never be displayed '
              'on a public profile.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF76501D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF2457C5),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _discardChanges,
                child: const Text('Discard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveSettings,
                icon: _saving
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _saving ? 'Saving...' : 'Save Changes',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2457C5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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