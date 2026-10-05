import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/layouts/admin_shell.dart';
import '../features/authentication/presentation/pages/admin_login_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // =========================================================
    // AUTHENTICATION
    // =========================================================

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const AdminLoginPage();
      },
    ),

    // =========================================================
    // DASHBOARD
    // =========================================================

    GoRoute(
      path: '/',
      builder: (context, state) {
        return const AdminShell(
          title: 'Dashboard',
          subtitle: 'Platform operations and performance',
          child: _AdminPlaceholderPage(
            title: 'Dashboard',
            description:
                'Your AssetCoin administration dashboard will be built here.',
            icon: Icons.dashboard_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // USERS
    // =========================================================

    GoRoute(
      path: '/users',
      builder: (context, state) {
        return const AdminShell(
          title: 'Users',
          subtitle: 'Manage AssetCoin customer accounts',
          child: _AdminPlaceholderPage(
            title: 'Users',
            description:
                'User management, account status, activity, and customer information will appear here.',
            icon: Icons.people_outline_rounded,
          ),
        );
      },
    ),

    // =========================================================
    // KYC
    // =========================================================

    GoRoute(
      path: '/kyc',
      builder: (context, state) {
        return const AdminShell(
          title: 'KYC & Verification',
          subtitle: 'Review and manage customer verification',
          child: _AdminPlaceholderPage(
            title: 'KYC & Verification',
            description:
                'KYC submissions, verification reviews, identity checks, and approval workflows will appear here.',
            icon: Icons.verified_user_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // ASSETS
    // =========================================================

    GoRoute(
      path: '/assets',
      builder: (context, state) {
        return const AdminShell(
          title: 'Assets',
          subtitle: 'Review and manage real-world assets',
          child: _AdminPlaceholderPage(
            title: 'Assets',
            description:
                'Asset submissions, documents, valuations, reviews, approvals, and asset status management will appear here.',
            icon: Icons.account_balance_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // TOKENIZATION
    // =========================================================

    GoRoute(
      path: '/tokenization',
      builder: (context, state) {
        return const AdminShell(
          title: 'Tokenization',
          subtitle: 'Manage approved asset tokenization',
          child: _AdminPlaceholderPage(
            title: 'Tokenization',
            description:
                'Approved assets, token issuance, token supply, pricing, and tokenization workflows will appear here.',
            icon: Icons.token_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // TRADING
    // =========================================================

    GoRoute(
      path: '/trading',
      builder: (context, state) {
        return const AdminShell(
          title: 'Trading',
          subtitle: 'Monitor the AssetCoin marketplace',
          child: _AdminPlaceholderPage(
            title: 'Trading',
            description:
                'Listings, buy and sell orders, transactions, holdings, and marketplace activity will appear here.',
            icon: Icons.swap_horiz_rounded,
          ),
        );
      },
    ),

    // =========================================================
    // FINANCE
    // =========================================================

    GoRoute(
      path: '/finance',
      builder: (context, state) {
        return const AdminShell(
          title: 'Finance',
          subtitle: 'Monitor platform financial operations',
          child: _AdminPlaceholderPage(
            title: 'Finance',
            description:
                'Wallet activity, deposits, withdrawals, conversions, balances, and financial transactions will appear here.',
            icon: Icons.account_balance_wallet_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // LEDGER
    // =========================================================

    GoRoute(
      path: '/ledger',
      builder: (context, state) {
        return const AdminShell(
          title: 'Ledger',
          subtitle: 'Review the centralized AssetCoin ledger',
          child: _AdminPlaceholderPage(
            title: 'Ledger',
            description:
                'Immutable transaction records, hashes, audit trails, timestamps, and ledger verification will appear here.',
            icon: Icons.receipt_long_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // NOTIFICATIONS
    // =========================================================

    GoRoute(
      path: '/notifications',
      builder: (context, state) {
        return const AdminShell(
          title: 'Notifications',
          subtitle: 'Manage administrator notifications',
          child: _AdminPlaceholderPage(
            title: 'Notifications',
            description:
                'System notifications, security alerts, workflow notifications, and staff alerts will appear here.',
            icon: Icons.notifications_none_rounded,
          ),
        );
      },
    ),

    // =========================================================
    // CONTENT
    // =========================================================

    GoRoute(
      path: '/content',
      builder: (context, state) {
        return const AdminShell(
          title: 'Content',
          subtitle: 'Manage platform announcements and news',
          child: _AdminPlaceholderPage(
            title: 'Content',
            description:
                'Announcements, platform news, educational content, and customer-facing information will appear here.',
            icon: Icons.article_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // STAFF
    // =========================================================

    GoRoute(
      path: '/staff',
      builder: (context, state) {
        return const AdminShell(
          title: 'Staff',
          subtitle: 'Manage AssetCoin administrators and permissions',
          child: _AdminPlaceholderPage(
            title: 'Staff',
            description:
                'Administrator accounts, roles, permissions, assignments, sessions, and staff activity will appear here.',
            icon: Icons.admin_panel_settings_outlined,
          ),
        );
      },
    ),

    // =========================================================
    // SETTINGS
    // =========================================================

    GoRoute(
      path: '/settings',
      builder: (context, state) {
        return const AdminShell(
          title: 'Settings',
          subtitle: 'Configure AssetCoin administration',
          child: _AdminPlaceholderPage(
            title: 'Settings',
            description:
                'Administrative settings, security configuration, system preferences, and platform controls will appear here.',
            icon: Icons.settings_outlined,
          ),
        );
      },
    ),
  ],
);

// =============================================================
// ADMIN PLACEHOLDER PAGE
// =============================================================

class _AdminPlaceholderPage extends StatelessWidget {
  const _AdminPlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 80,
            horizontal: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: const Color(0xFF1565C0),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Module under development',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}