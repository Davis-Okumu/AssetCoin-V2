import 'package:flutter/material.dart';

import '../../data/models/user_details_model.dart';

class UserDetailsPanel extends StatelessWidget {
  const UserDetailsPanel({super.key, required this.user});

  final UserDetailsModel user;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 900;

        final children = [
          _buildPersonalInformation(context),
          _buildAccountInformation(context),
          _buildWalletInformation(context),
          _buildPlatformSummary(context),
        ];

        if (twoColumns) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: children
                .map(
                  (child) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  // =========================================================
  // PERSONAL INFORMATION
  // =========================================================

  Widget _buildPersonalInformation(BuildContext context) {
    return _SectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _InfoRow(
            label: 'Full name',
            value: user.fullName.isEmpty ? 'Not provided' : user.fullName,
          ),
          _InfoRow(label: 'Email', value: user.email ?? 'Not provided'),
          _InfoRow(label: 'Phone', value: user.phone ?? 'Not provided'),
          _InfoRow(
            label: 'National ID',
            value: user.nationalId ?? 'Not available',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACCOUNT INFORMATION
  // =========================================================

  Widget _buildAccountInformation(BuildContext context) {
    return _SectionCard(
      title: 'Account Information',
      icon: Icons.manage_accounts_outlined,
      child: Column(
        children: [
          _InfoRow(label: 'User ID', value: '#${user.id}'),
          _InfoRow(label: 'Role', value: _formatStatus(user.role)),
          _InfoRow(label: 'KYC status', value: _formatStatus(user.kycStatus)),
          _InfoRow(
            label: 'Account status',
            value: _formatStatus(user.accountStatus),
          ),
          _InfoRow(label: 'Last login', value: _formatDate(user.lastLoginAt)),
          _InfoRow(label: 'Created', value: _formatDate(user.createdAt)),
        ],
      ),
    );
  }

  // =========================================================
  // WALLET INFORMATION
  // =========================================================

  Widget _buildWalletInformation(BuildContext context) {
    final wallet = user.wallet;

    if (wallet == null) {
      return const _SectionCard(
        title: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        child: Text('This user does not have a wallet.'),
      );
    }

    return _SectionCard(
      title: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          _InfoRow(
            label: 'Wallet address',
            value: wallet.walletAddress ?? 'Not available',
          ),
          _InfoRow(
            label: 'Balance',
            value: '${wallet.currency} ${wallet.fiatBalance}',
          ),
          _InfoRow(
            label: 'Locked balance',
            value: '${wallet.currency} ${wallet.lockedFiatBalance}',
          ),
          _InfoRow(label: 'Status', value: _formatStatus(wallet.status)),
        ],
      ),
    );
  }

  // =========================================================
  // PLATFORM SUMMARY
  // =========================================================

  Widget _buildPlatformSummary(BuildContext context) {
    final summary = user.summary;

    return _SectionCard(
      title: 'Platform Summary',
      icon: Icons.analytics_outlined,
      child: Column(
        children: [
          _InfoRow(label: 'Total assets', value: '${summary.assets.total}'),
          _InfoRow(label: 'Pending assets', value: '${summary.assets.pending}'),
          _InfoRow(
            label: 'Approved assets',
            value: '${summary.assets.approved}',
          ),
          _InfoRow(
            label: 'Tokenized assets',
            value: '${summary.assets.tokenized}',
          ),
          _InfoRow(label: 'Token quantity', value: summary.holdings.quantity),
          _InfoRow(
            label: 'Total invested',
            value: 'KES ${summary.holdings.totalInvested}',
          ),
          _InfoRow(
            label: 'Support tickets',
            value: '${summary.support.totalTickets}',
          ),
          _InfoRow(
            label: 'Open tickets',
            value: '${summary.support.openTickets}',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FORMATTERS
  // =========================================================

  String _formatStatus(String value) {
    if (value.trim().isEmpty) {
      return 'Not available';
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

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Never';
    }

    final local = value.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// =========================================================
// SECTION CARD
// =========================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
                Icon(icon, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

// =========================================================
// INFORMATION ROW
// =========================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
