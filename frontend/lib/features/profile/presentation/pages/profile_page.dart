
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/profile_providers.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_menu_tile.dart';

import 'personal_information_page.dart';
import 'kyc_verification_page.dart';
import 'security_page.dart';
import 'settings_page.dart';
import 'privacy_settings_page.dart';
import 'help_education_page.dart';
import 'account_management_page.dart';

import '../../../notifications/presentations/pages/notification_preference_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _photoUploading = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          await ref.read(profileProvider.future);
        },
        child: profileAsync.when(
          loading: () => const _ProfileLoadingView(),
          error: (error, stackTrace) => _ProfileErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(profileProvider);
            },
          ),
          data: (profile) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                32,
              ),
              children: [
                ProfileHeader(
                  profile: profile,
                  onPhotoTap: _showPhotoOptions,
                ),

                if (_photoUploading) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],

                const SizedBox(height: 32),

                // =========================================
                // ACCOUNT
                // =========================================

                ProfileMenuSection(
                  title: 'Account',
                  children: [
                    ProfileMenuTile(
                      title: 'Personal Information',
                      subtitle:
                          'Manage your name, email, phone and personal details.',
                      icon: Icons.person_outline_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PersonalInformationPage(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuTile(
                      icon: Icons.verified_user_rounded,
                      title: 'KYC & Verification',
                      subtitle:
                          'Verify your identity and view verification status.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const KycVerificationPage(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuTile(
                      icon: Icons.security_outlined,
                      title: 'Security',
                      subtitle:
                          'Password, 2FA, sessions and login activity.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecurityPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =========================================
                // PREFERENCES
                // =========================================

                ProfileMenuSection(
                  title: 'Preferences',
                  children: [
                    ProfileMenuTile(
                      title: 'Settings',
                      subtitle:
                          'Appearance, language, currency and preferences.',
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuTile(
                      title: 'Notifications',
                      subtitle:
                          'Manage notification categories and delivery channels.',
                      icon: Icons.notifications_none_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const NotificationPreferencesPage(),
                          ),
                        );
                      },
                    ),

                    // =====================================
                    // PRIVACY SETTINGS
                    // =====================================

                    ProfileMenuTile(
                      title: 'Privacy',
                      subtitle:
                          'Control your profile visibility and privacy.',
                      icon: Icons.lock_outline_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PrivacySettingsPage(),
                          ),
                        );
                      },
                    ),

                    // =====================================
                    // ACCOUNT MANAGEMENT
                    // =====================================

                    ProfileMenuTile(
                      title: 'Account Management',
                      subtitle:
                          'Manage your AssetCoin account.',
                      icon: Icons.manage_accounts_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AccountManagementPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =========================================
                // SUPPORT
                // =========================================

                ProfileMenuSection(
                  title: 'Support',
                  children: [
                    ProfileMenuTile(
                      title: 'Help & Education',
                      subtitle:
                          'Learn how AssetCoin, assets, tokens and wallets work.',
                      icon: Icons.school_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const HelpEducationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =========================================
                // LOGOUT
                // =========================================

                LogoutButton(
                  onLoggedOut: () {
                    // Existing authentication/router state
                    // will handle navigation.
                  },
                ),

                const SizedBox(height: 20),

                // =========================================
                // APP VERSION
                // =========================================

                Center(
                  child: Text(
                    'AssetCoin v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================
  // PROFILE PHOTO OPTIONS
  // =========================================

  Future<void> _showPhotoOptions() async {
    if (_photoUploading) {
      return;
    }

    final profile = ref.read(profileProvider).value;

    if (!mounted) {
      return;
    }

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(
                      context,
                      _PhotoAction.gallery,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(
                      context,
                      _PhotoAction.camera,
                    );
                  },
                ),

                if (profile?.profilePhotoUrl != null &&
                    profile!.profilePhotoUrl!.isNotEmpty)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        _PhotoAction.remove,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _PhotoAction.gallery:
        await _pickPhoto(ImageSource.gallery);
        break;

      case _PhotoAction.camera:
        await _pickPhoto(ImageSource.camera);
        break;

      case _PhotoAction.remove:
        await _removePhoto();
        break;
    }
  }

  // =========================================
  // PICK AND UPLOAD PROFILE PHOTO
  // =========================================

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _photoUploading = true;
      });

      final actions = ref.read(profileActionsProvider);

      await actions.uploadProfilePhoto(
        pickedFile.path,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update profile photo: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoUploading = false;
        });
      }
    }
  }

  // =========================================
  // REMOVE PROFILE PHOTO
  // =========================================

  Future<void> _removePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove profile photo?'),
          content: const Text(
            'Your current profile photo will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      setState(() {
        _photoUploading = true;
      });

      final actions = ref.read(profileActionsProvider);

      await actions.removeProfilePhoto();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo removed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to remove profile photo: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoUploading = false;
        });
      }
    }
  }
}

// =============================================
// PROFILE PHOTO ACTIONS
// =============================================

enum _PhotoAction {
  gallery,
  camera,
  remove,
}

// =============================================
// PROFILE LOADING VIEW
// =============================================

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// =============================================
// PROFILE ERROR VIEW
// =============================================

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                color: colorScheme.error,
                size: 30,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load your profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
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