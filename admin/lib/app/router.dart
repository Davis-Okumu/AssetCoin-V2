import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/layouts/admin_shell.dart';
import '../features/authentication/presentation/controllers/admin_auth_controller.dart';
import '../features/authentication/presentation/pages/admin_login_page.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/kyc/presentation/pages/kyc_page.dart';
import '../features/assets/presentation/pages/assets_page.dart';
import '../features/tokenization/presentation/pages/tokenization_page.dart';
import '../features/trading/presentation/pages/trading_page.dart';
import '../features/finance/presentation/pages/finance_page.dart';
import '../features/ledger/presentation/pages/ledger_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/content/presentation/pages/content_page.dart';
import '../features/staff/presentation/pages/staff_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/users/presentation/pages/user_details_page.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefreshNotifier(ref);

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',

    refreshListenable: refreshNotifier,

    redirect: (context, state) {
      final authState = ref.read(adminAuthControllerProvider);

      final isAuthenticated = authState.value != null;

      final isLoading = authState.isLoading;

      final isLoginPage = state.matchedLocation == '/login';

      // While the stored session is being restored,
      // don't redirect unnecessarily.
      if (isLoading) {
        return null;
      }

      // Not authenticated → login.
      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }

      // Already authenticated → don't allow access
      // to the login page.
      if (isAuthenticated && isLoginPage) {
        return '/';
      }

      return null;
    },

    routes: [
      // =====================================================
      // LOGIN
      // =====================================================

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const AdminLoginPage();
        },
      ),

      // =====================================================
      // PROTECTED ADMIN APPLICATION
      // =====================================================
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(
            title: _getPageTitle(state.uri.path),
            subtitle: _getPageSubtitle(state.uri.path),
            child: child,
          );
        },

        routes: [
          // ===================================================
          // DASHBOARD
          // ===================================================

          GoRoute(
            path: '/',
            builder: (context, state) {
              return const DashboardPage();
            },
          ),

          // ===================================================
          // USERS
          // ===================================================
          GoRoute(
            path: '/users',
            builder: (context, state) {
              return const UsersPage();
            },
          ),

          GoRoute(
            path: '/users/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');

              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('Invalid user ID.')),
                );
              }

              return UserDetailsPage(userId: id);
            },
          ),
          // ===================================================
          // KYC
          // ===================================================
          GoRoute(
            path: '/kyc',
            builder: (context, state) {
              // return const KycPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // ASSETS
          // ===================================================
          GoRoute(
            path: '/assets',
            builder: (context, state) {
              // return const AssetsPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // TOKENIZATION
          // ===================================================
          GoRoute(
            path: '/tokenization',
            builder: (context, state) {
              // return const TokenizationPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // TRADING
          // ===================================================
          GoRoute(
            path: '/trading',
            builder: (context, state) {
              // return const TradingPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // FINANCE
          // ===================================================
          GoRoute(
            path: '/finance',
            builder: (context, state) {
              // return const FinancePage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // LEDGER
          // ===================================================
          GoRoute(
            path: '/ledger',
            builder: (context, state) {
              // return const LedgerPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // NOTIFICATIONS
          // ===================================================
          GoRoute(
            path: '/notifications',
            builder: (context, state) {
              // return const NotificationsPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // CONTENT
          // ===================================================
          GoRoute(
            path: '/content',
            builder: (context, state) {
              // return const ContentPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // STAFF
          // ===================================================
          GoRoute(
            path: '/staff',
            builder: (context, state) {
              // return const StaffPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),

          // ===================================================
          // SETTINGS
          // ===================================================
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              // return const SettingsPage();
              return const Scaffold(
                body: Center(child: Text('Users Page - Coming Soon')),
              );
            },
          ),
        ],
      ),
    ],
  );
});

// ===========================================================
// AUTH ROUTER REFRESH
// ===========================================================

// ===========================================================
// AUTH ROUTER REFRESH
// ===========================================================
class _AuthRouterRefreshNotifier extends ChangeNotifier {
  _AuthRouterRefreshNotifier(this.ref) {
    _subscription = ref.listen(adminAuthControllerProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

// ===========================================================
// PAGE TITLES
// ===========================================================

String _getPageTitle(String path) {
  switch (path) {
    case '/':
      return 'Dashboard';

    case '/users':
      return 'Users';

    case '/kyc':
      return 'KYC & Verification';

    case '/assets':
      return 'Assets';

    case '/tokenization':
      return 'Tokenization';

    case '/trading':
      return 'Trading';

    case '/finance':
      return 'Finance';

    case '/ledger':
      return 'Ledger';

    case '/notifications':
      return 'Notifications';

    case '/content':
      return 'Content';

    case '/staff':
      return 'Staff';

    case '/settings':
      return 'Settings';

    default:
      if (path.startsWith('/users/')) {
        return 'User Details';
      }
      return 'AssetCoin Admin';
  }
}

// ===========================================================
// PAGE SUBTITLES
// ===========================================================

String _getPageSubtitle(String path) {
  switch (path) {
    case '/':
      return 'Platform operations and performance';

    case '/users':
      return 'Manage AssetCoin customer accounts';

    case '/kyc':
      return 'Review and manage identity verification';

    case '/assets':
      return 'Review and manage submitted assets';

    case '/tokenization':
      return 'Manage asset tokenization operations';

    case '/trading':
      return 'Monitor marketplace and trading activity';

    case '/finance':
      return 'Manage financial operations and wallets';

    case '/ledger':
      return 'Review immutable platform transaction records';

    case '/notifications':
      return 'Manage administrator notifications';

    case '/content':
      return 'Manage platform announcements and content';

    case '/staff':
      return 'Manage administrators and permissions';

    case '/settings':
      return 'Manage administration settings';

    default:
      return '';
  }
}
