import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_details_controller.dart';
import '../widgets/user_details_panel.dart';

class UserDetailsPage extends ConsumerStatefulWidget {
  const UserDetailsPage({super.key, required this.userId});

  final int userId;

  @override
  ConsumerState<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends ConsumerState<UserDetailsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref.read(userDetailsControllerProvider.notifier).loadUser(widget.userId);
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailsControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return _ErrorView(
          message: error.toString(),
          onRetry: () {
            ref
                .read(userDetailsControllerProvider.notifier)
                .loadUser(widget.userId);
          },
        );
      },
      data: (details) {
        return _buildContent(context, details);
      },
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent(BuildContext context, UserDetailsState details) {
    final user = details.user;

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(userDetailsControllerProvider.notifier).refreshUser();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          _buildHeader(context, user),
          const SizedBox(height: 24),
          UserDetailsPanel(user: user),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            _buildAvatar(context, user),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName.isEmpty ? 'Unnamed User' : user.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? 'No email address',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(label: _formatStatus(user.accountStatus)),
                      _StatusChip(
                        label: 'KYC: ${_formatStatus(user.kycStatus)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // AVATAR
  // =========================================================

  Widget _buildAvatar(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    final photoUrl = user.profilePhotoUrl;

    if (photoUrl != null && photoUrl.toString().trim().isNotEmpty) {
      return CircleAvatar(
        radius: 34,
        backgroundImage: NetworkImage(photoUrl.toString()),
      );
    }

    final name = user.fullName.toString().trim();
    final parts = name.split(' ');

    String initials = '?';

    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      initials = name[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 34,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String _formatStatus(String value) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    return value
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                    '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

// =========================================================
// STATUS CHIP
// =========================================================

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =========================================================
// ERROR VIEW
// =========================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to load user',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
