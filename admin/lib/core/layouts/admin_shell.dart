import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/domain/admin_user.dart';
import '../../features/authentication/presentation/controllers/admin_auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

// =========================================================
// NAVIGATION ITEMS
// =========================================================

final mainNavigationItems = <_NavigationItem>[
  const _NavigationItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: '/',
    permission: 'dashboard.view',
  ),
  const _NavigationItem(
    label: 'Users',
    icon: Icons.people_outline,
    route: '/users',
    permission: 'users.view',
  ),
  const _NavigationItem(
    label: 'KYC',
    icon: Icons.verified_user_outlined,
    route: '/kyc',
    permission: 'kyc.view',
  ),
  const _NavigationItem(
    label: 'Assets',
    icon: Icons.inventory_2_outlined,
    route: '/assets',
    permission: 'assets.view',
  ),
  const _NavigationItem(
    label: 'Tokenization',
    icon: Icons.token_outlined,
    route: '/tokenization',
    permission: 'tokenization.view',
  ),
  const _NavigationItem(
    label: 'Trading',
    icon: Icons.swap_horiz_outlined,
    route: '/trading',
    permission: 'trading.view',
  ),
  const _NavigationItem(
    label: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    route: '/finance',
    permission: 'finance.view',
  ),
  const _NavigationItem(
    label: 'Ledger',
    icon: Icons.receipt_long_outlined,
    route: '/ledger',
    permission: 'ledger.view',
  ),
];

final communicationNavigationItems = <_NavigationItem>[
  const _NavigationItem(
    label: 'Notifications',
    icon: Icons.notifications_none_outlined,
    route: '/notifications',
    permission: 'notifications.view',
  ),
  const _NavigationItem(
    label: 'Content',
    icon: Icons.article_outlined,
    route: '/content',
    permission: 'content.view',
  ),
];

final administrationNavigationItems = <_NavigationItem>[
  const _NavigationItem(
    label: 'Staff',
    icon: Icons.admin_panel_settings_outlined,
    route: '/staff',
    permission: 'staff.view',
  ),
  const _NavigationItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    route: '/settings',
    permission: 'settings.view',
  ),
];

// =========================================================
// NAVIGATION ITEM MODEL
// =========================================================

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.permission,
  });

  final String label;
  final IconData icon;
  final String route;
  final String? permission;
}

// =========================================================
// ADMIN SHELL
// =========================================================

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({
    super.key,
    required this.child,
    this.title = 'Dashboard',
    this.subtitle,
  });

  final Widget child;

  final String title;

  final String? subtitle;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _isSidebarCollapsed = false;

  // =========================================================
  // RESPONSIVE BREAKPOINTS
  // =========================================================

  static const double _mobileBreakpoint = 700;

  static const double _desktopBreakpoint = 1100;

  bool _isMobile(double width) {
    return width < _mobileBreakpoint;
  }

  bool _isDesktop(double width) {
    return width >= _desktopBreakpoint;
  }

  // =========================================================
  // ADMIN USER
  // =========================================================

  AdminUser? get _currentAdmin {
    return ref.watch(adminAuthControllerProvider).value;
  }

  // =========================================================
  // PERMISSIONS
  // =========================================================

  bool _hasPermission(AdminUser? admin, String? permission) {
    if (permission == null || permission.isEmpty) {
      return true;
    }

    if (admin == null) {
      return false;
    }

    if (admin.isSuperAdministrator) {
      return true;
    }

    return admin.hasPermission(permission);
  }

  List<_NavigationItem> _visibleItems(
    List<_NavigationItem> items,
    AdminUser? admin,
  ) {
    return items
        .where((item) => _hasPermission(admin, item.permission))
        .toList();
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text(
            'Are you sure you want to sign out of the admin dashboard?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await ref.read(adminAuthControllerProvider.notifier).logout();
  }

  // =========================================================
  // NAVIGATION
  // =========================================================

  void _navigateTo(String route, {bool closeDrawer = false}) {
    if (closeDrawer && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    context.go(route);
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (_isMobile(width)) {
          return _buildMobileLayout(context);
        }

        return _buildDesktopLayout(context, isDesktop: _isDesktop(width));
      },
    );
  }

  // =========================================================
  // MOBILE LAYOUT
  // =========================================================

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildMobileAppBar(context),
      drawer: _buildDrawer(context),
      body: _buildContent(context),
    );
  }

  // =========================================================
  // DESKTOP / TABLET LAYOUT
  // =========================================================

  Widget _buildDesktopLayout(BuildContext context, {required bool isDesktop}) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, collapsed: !isDesktop || _isSidebarCollapsed),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOBILE APP BAR
  // =========================================================

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Builder(
        builder: (context) {
          return IconButton(
            tooltip: 'Open navigation',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTextStyles.titleMedium),
          if (widget.subtitle != null)
            Text(widget.subtitle!, style: AppTextStyles.bodySmall),
        ],
      ),
      actions: [
        _buildNotificationButton(context, compact: true),
        _buildProfileButton(context, compact: true),
      ],
    );
  }

  // =========================================================
  // SIDEBAR
  // =========================================================

  Widget _buildSidebar(BuildContext context, {required bool collapsed}) {
    final admin = _currentAdmin;

    final width = collapsed
        ? AppDimensions.sidebarCollapsedWidth
        : AppDimensions.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSidebarHeader(context, collapsed: collapsed),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavigationSection(
                      context,
                      items: _visibleItems(mainNavigationItems, admin),
                      collapsed: collapsed,
                    ),
                    _buildNavigationSection(
                      context,
                      items: _visibleItems(communicationNavigationItems, admin),
                      collapsed: collapsed,
                      title: 'COMMUNICATION',
                    ),
                    _buildNavigationSection(
                      context,
                      items: _visibleItems(
                        administrationNavigationItems,
                        admin,
                      ),
                      collapsed: collapsed,
                      title: 'ADMINISTRATION',
                    ),
                  ],
                ),
              ),
            ),
            _buildSidebarFooter(context, collapsed: collapsed, admin: admin),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SIDEBAR HEADER
  // =========================================================

  Widget _buildSidebarHeader(BuildContext context, {required bool collapsed}) {
    return SizedBox(
      height: AppDimensions.topBarHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: collapsed ? 14 : 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.token_outlined,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AssetCoin',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'ADMINISTRATION',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // NAVIGATION SECTION
  // =========================================================

  Widget _buildNavigationSection(
    BuildContext context, {
    required List<_NavigationItem> items,
    required bool collapsed,
    String? title,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!collapsed && title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ...items.map(
            (item) =>
                _buildNavigationItem(context, item: item, collapsed: collapsed),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // NAVIGATION ITEM
  // =========================================================

  Widget _buildNavigationItem(
    BuildContext context, {
    required _NavigationItem item,
    required bool collapsed,
  }) {
    final currentPath = GoRouterState.of(context).uri.path;

    final isActive = item.route == '/'
        ? currentPath == '/'
        : currentPath == item.route || currentPath.startsWith('${item.route}/');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: collapsed ? item.label : '',
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _navigateTo(item.route, closeDrawer: false);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 46,
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 14),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 21,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : Colors.grey.shade700,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 5,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SIDEBAR FOOTER
  // =========================================================

  Widget _buildSidebarFooter(
    BuildContext context, {
    required bool collapsed,
    required AdminUser? admin,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        collapsed ? 12 : 16,
        12,
        collapsed ? 12 : 16,
        16,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showProfileMenu(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildAvatar(admin, size: 40),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin?.fullName ?? 'Administrator',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatRole(admin?.role),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar(BuildContext context) {
    final admin = _currentAdmin;

    return Container(
      height: AppDimensions.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: _isSidebarCollapsed
                ? 'Expand sidebar'
                : 'Collapse sidebar',
            icon: Icon(
              _isSidebarCollapsed
                  ? Icons.menu_open_rounded
                  : Icons.menu_rounded,
            ),
            onPressed: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          _buildSearchButton(context),
          const SizedBox(width: 8),
          _buildNotificationButton(context),
          const SizedBox(width: 8),
          _buildProfileButton(context, admin: admin),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      tooltip: 'Search',
      icon: const Icon(Icons.search_rounded),
      onPressed: () {
        _showComingSoon(context, 'Global search is coming soon.');
      },
    );
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  Widget _buildNotificationButton(
    BuildContext context, {
    bool compact = false,
  }) {
    return IconButton(
      tooltip: 'Notifications',
      icon: Icon(Icons.notifications_none_rounded, size: compact ? 23 : 22),
      onPressed: () {
        context.go('/notifications');
      },
    );
  }

  // =========================================================
  // PROFILE BUTTON
  // =========================================================

  Widget _buildProfileButton(
    BuildContext context, {
    AdminUser? admin,
    bool compact = false,
  }) {
    admin ??= _currentAdmin;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _showProfileMenu(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(admin, size: compact ? 34 : 38),
            if (!compact) ...[
              const SizedBox(width: 9),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin?.fullName ?? 'Administrator',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _formatRole(admin?.role),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // AVATAR
  // =========================================================

  Widget _buildAvatar(AdminUser? admin, {required double size}) {
    final imageUrl = admin?.profilePhotoUrl;

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primary.withValues(alpha: 0.10),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary,
      child: Text(
        admin?.initials ?? 'AD',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =========================================================
  // DRAWER
  // =========================================================

  Widget _buildDrawer(BuildContext context) {
    final admin = _currentAdmin;

    final mainItems = _visibleItems(mainNavigationItems, admin);

    final communicationItems = _visibleItems(
      communicationNavigationItems,
      admin,
    );

    final administrationItems = _visibleItems(
      administrationNavigationItems,
      admin,
    );

    return Drawer(
      width: 290,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildMobileDrawerHeader(context, admin),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavigationSection(
                      context,
                      items: mainItems,
                      collapsed: false,
                    ),
                    _buildNavigationSection(
                      context,
                      items: communicationItems,
                      collapsed: false,
                      title: 'COMMUNICATION',
                    ),
                    _buildNavigationSection(
                      context,
                      items: administrationItems,
                      collapsed: false,
                      title: 'ADMINISTRATION',
                    ),
                  ],
                ),
              ),
            ),
            _buildMobileDrawerFooter(context, admin),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MOBILE DRAWER HEADER
  // =========================================================

  Widget _buildMobileDrawerHeader(BuildContext context, AdminUser? admin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(admin, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AssetCoin',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  admin?.fullName ?? 'Administrator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOBILE DRAWER FOOTER
  // =========================================================

  Widget _buildMobileDrawerFooter(BuildContext context, AdminUser? admin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildAvatar(admin, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin?.fullName ?? 'Administrator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatRole(admin?.role),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE MENU
  // =========================================================

  Future<void> _showProfileMenu(BuildContext context) async {
    final admin = _currentAdmin;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileSummary(admin),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Profile'),
                  subtitle: const Text('Manage your administrator profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showComingSoon(
                      this.context,
                      'Administrator profile management is coming soon.',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  subtitle: const Text('Manage admin preferences'),
                  onTap: () {
                    Navigator.of(context).pop();
                    this.context.go('/settings');
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // PROFILE SUMMARY
  // =========================================================

  Widget _buildProfileSummary(AdminUser? admin) {
    return Row(
      children: [
        _buildAvatar(admin, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin?.fullName ?? 'Administrator',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                admin?.email ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatRole(admin?.role),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CONTENT
  //
  // IMPORTANT:
  // DashboardPage already owns its scrolling.
  // Therefore AdminShell must NOT wrap widget.child
  // in another SingleChildScrollView.
  // =========================================================

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: widget.child,
        ),
      ),
    );
  }

  // =========================================================
  // ROLE FORMATTER
  // =========================================================

  String _formatRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'Administrator';
    }

    switch (role) {
      case 'super_admin':
        return 'Super Administrator';

      case 'asset_officer':
        return 'Asset Officer';

      case 'kyc_officer':
        return 'KYC Officer';

      case 'tokenization_officer':
        return 'Tokenization Officer';

      case 'finance_officer':
        return 'Finance Officer';

      case 'trading_officer':
        return 'Trading Officer';

      case 'support_officer':
        return 'Support Officer';

      case 'auditor':
        return 'Auditor';

      default:
        return role
            .split('_')
            .map(
              (part) => part.isEmpty
                  ? part
                  : '${part[0].toUpperCase()}${part.substring(1)}',
            )
            .join(' ');
    }
  }

  // =========================================================
  // COMING SOON
  // =========================================================

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
