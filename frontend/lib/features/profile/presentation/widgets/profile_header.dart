import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import 'verification_status_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onPhotoTap,
  });

  final ProfileModel profile;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: 0.22,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface,
                backgroundImage: _profileImage(profile),
                child: _profileImage(profile) == null
                    ? Text(
                        _initials(profile),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
            Material(
              color: colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPhotoTap,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (profile.email != null)
          Text(
            profile.email!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          profile.phone,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        VerificationStatusBadge(
          status: profile.kycStatus,
        ),
      ],
    );
  }

  ImageProvider<Object>? _profileImage(ProfileModel profile) {
    final url = profile.profilePhotoUrl?.trim();

    if (url == null || url.isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }

  String _initials(ProfileModel profile) {
    final first = profile.firstName.trim();
    final last = profile.lastName.trim();

    final firstInitial =
        first.isNotEmpty ? first[0].toUpperCase() : '';

    final lastInitial =
        last.isNotEmpty ? last[0].toUpperCase() : '';

    final initials = '$firstInitial$lastInitial';

    return initials.isEmpty ? 'U' : initials;
  }
}