import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class AdminShell extends StatefulWidget {
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
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // =========================================================
  // ROUTE NAVIGATION
  // =========================================================

  void _navigateTo(String route) {
    if (GoRouterState.of(context).uri.path == route) {
      return;
    }

    context.go(route);
  }

  bool _isRouteActive(String route) {
    final currentPath = GoRouterState.of(context).uri.path;

    if (route == '/') {
      return currentPath == '/';
    }

    return currentPath == route ||
        currentPath.startsWith('$route/');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;

        if (isMobile) {
          return _buildMobileLayout(context);
        }

        return _buildDesktopLayout(
          context,
          isTablet: isTablet,
        );
      },
    );
  }

  // =========================================================
  // MOBILE LAYOUT
  // =========================================================

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: _buildMobileDrawer(context),

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),

        title: _buildBrand(),

        actions: [
          _buildNotificationButton(),

          const SizedBox(
            width: AppDimensions.spacing8,
          ),
        ],
      ),

      body: _buildContent(context),
    );
  }

  // =========================================================
  // DESKTOP / TABLET LAYOUT
  // =========================================================

  Widget _buildDesktopLayout(
    BuildContext context, {
    required bool isTablet,
  }) {
    final sidebarCollapsed =
        isTablet ? true : _isSidebarCollapsed;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Row(
        children: [
          _buildSidebar(
            context,
            collapsed: sidebarCollapsed,
          ),

          Expanded(
            child: Column(
              children: [
                _buildTopBar(
                  context,
                  isTablet: isTablet,
                ),

                Expanded(
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SIDEBAR
  // =========================================================

  Widget _buildSidebar(
    BuildContext context, {
    required bool collapsed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,

      width: collapsed
          ? AppDimensions.sidebarCollapsedWidth
          : AppDimensions.sidebarWidth,

      decoration: const BoxDecoration(
        color: AppColors.surface,

        border: Border(
          right: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      child: Column(
        children: [
          _buildSidebarHeader(collapsed),

          const SizedBox(
            height: AppDimensions.spacing16,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
              ),
              child: Column(
                children: [
                  _buildNavigationSection(
                    context,
                    title: 'MAIN',
                    collapsed: collapsed,
                    items: const [
                      _NavigationItem(
                        label: 'Dashboard',
                        icon: Icons.dashboard_outlined,
                        route: '/',
                      ),
                      _NavigationItem(
                        label: 'Users',
                        icon: Icons.people_outline_rounded,
                        route: '/users',
                      ),
                      _NavigationItem(
                        label: 'KYC',
                        icon: Icons.verified_user_outlined,
                        route: '/kyc',
                      ),
                      _NavigationItem(
                        label: 'Assets',
                        icon: Icons.account_balance_outlined,
                        route: '/assets',
                      ),
                      _NavigationItem(
                        label: 'Tokenization',
                        icon: Icons.token_outlined,
                        route: '/tokenization',
                      ),
                      _NavigationItem(
                        label: 'Trading',
                        icon: Icons.swap_horiz_rounded,
                        route: '/trading',
                      ),
                      _NavigationItem(
                        label: 'Finance',
                        icon: Icons.account_balance_wallet_outlined,
                        route: '/finance',
                      ),
                      _NavigationItem(
                        label: 'Ledger',
                        icon: Icons.receipt_long_outlined,
                        route: '/ledger',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacing24,
                  ),

                  _buildNavigationSection(
                    context,
                    title: 'COMMUNICATION',
                    collapsed: collapsed,
                    items: const [
                      _NavigationItem(
                        label: 'Notifications',
                        icon: Icons.notifications_none_rounded,
                        route: '/notifications',
                      ),
                      _NavigationItem(
                        label: 'Content',
                        icon: Icons.article_outlined,
                        route: '/content',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacing24,
                  ),

                  _buildNavigationSection(
                    context,
                    title: 'ADMINISTRATION',
                    collapsed: collapsed,
                    items: const [
                      _NavigationItem(
                        label: 'Staff',
                        icon: Icons.admin_panel_settings_outlined,
                        route: '/staff',
                      ),
                      _NavigationItem(
                        label: 'Settings',
                        icon: Icons.settings_outlined,
                        route: '/settings',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          _buildLogoutButton(collapsed),
        ],
      ),
    );
  }

  // =========================================================
  // SIDEBAR HEADER
  // =========================================================

  Widget _buildSidebarHeader(bool collapsed) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed
              ? AppDimensions.spacing12
              : AppDimensions.spacing20,
        ),
        child: Row(
          children: [
            _buildLogo(),

            if (!collapsed) ...[
              const SizedBox(
                width: AppDimensions.spacing12,
              ),

              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AssetCoin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ADMINISTRATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primaryBlue,
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
    required String title,
    required bool collapsed,
    required List<_NavigationItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.spacing12,
              bottom: AppDimensions.spacing8,
            ),
            child: Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ),

        ...items.map(
          (item) => _buildNavigationItem(
            context,
            item: item,
            collapsed: collapsed,
          ),
        ),
      ],
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
    final isActive = _isRouteActive(item.route);

    final backgroundColor = isActive
        ? AppColors.primaryBlueLight
        : Colors.transparent;

    final iconColor = isActive
        ? AppColors.primaryBlue
        : AppColors.textSecondary;

    final textColor = isActive
        ? AppColors.primaryBlue
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacing4,
      ),
      child: Tooltip(
        message: collapsed ? item.label : '',
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius8,
          ),
          onTap: () {
            _navigateTo(item.route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                AppDimensions.radius8,
              ),
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: iconColor,
                ),

                if (!collapsed) ...[
                  const SizedBox(
                    width: AppDimensions.spacing12,
                  ),

                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: textColor,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Widget _buildLogoutButton(bool collapsed) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacing12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Tooltip(
        message: collapsed ? 'Logout' : '',
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius8,
          ),
          onTap: () {
            // Logout will be connected to authentication.
          },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.danger,
                ),

                if (!collapsed) ...[
                  const SizedBox(
                    width: AppDimensions.spacing12,
                  ),
                  Text(
                    'Logout',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar(
    BuildContext context, {
    required bool isTablet,
  }) {
    return Container(
      height: AppDimensions.topBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isTablet)
            IconButton(
              tooltip: 'Collapse sidebar',
              onPressed: _toggleSidebar,
              icon: Icon(
                _isSidebarCollapsed
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
              ),
            ),

          if (!isTablet)
            const SizedBox(
              width: AppDimensions.spacing16,
            ),

          Expanded(
            child: _buildPageHeading(),
          ),

          _buildSearchButton(),

          const SizedBox(
            width: AppDimensions.spacing8,
          ),

          _buildNotificationButton(),

          const SizedBox(
            width: AppDimensions.spacing16,
          ),

          _buildAdminProfile(),
        ],
      ),
    );
  }

  // =========================================================
  // PAGE HEADING
  // =========================================================

  Widget _buildPageHeading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTextStyles.headingMedium,
        ),

        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }

  // =========================================================
  // MOBILE DRAWER
  // =========================================================

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildSidebarHeader(false),

            const Divider(
              color: AppColors.divider,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(
                  AppDimensions.spacing12,
                ),
                children: [
                  _buildMobileNavigationItem(
                    context,
                    'Dashboard',
                    Icons.dashboard_outlined,
                    '/',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Users',
                    Icons.people_outline_rounded,
                    '/users',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'KYC',
                    Icons.verified_user_outlined,
                    '/kyc',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Assets',
                    Icons.account_balance_outlined,
                    '/assets',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Tokenization',
                    Icons.token_outlined,
                    '/tokenization',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Trading',
                    Icons.swap_horiz_rounded,
                    '/trading',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Finance',
                    Icons.account_balance_wallet_outlined,
                    '/finance',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Ledger',
                    Icons.receipt_long_outlined,
                    '/ledger',
                  ),

                  const Divider(
                    height: 32,
                    color: AppColors.divider,
                  ),

                  _buildMobileNavigationItem(
                    context,
                    'Notifications',
                    Icons.notifications_none_rounded,
                    '/notifications',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Content',
                    Icons.article_outlined,
                    '/content',
                  ),

                  const Divider(
                    height: 32,
                    color: AppColors.divider,
                  ),

                  _buildMobileNavigationItem(
                    context,
                    'Staff',
                    Icons.admin_panel_settings_outlined,
                    '/staff',
                  ),
                  _buildMobileNavigationItem(
                    context,
                    'Settings',
                    Icons.settings_outlined,
                    '/settings',
                  ),
                ],
              ),
            ),

            const Divider(
              color: AppColors.divider,
            ),

            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                'Logout',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.danger,
                ),
              ),
              onTap: () {
                // Logout will be connected to authentication.
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MOBILE NAVIGATION ITEM
  // =========================================================

  Widget _buildMobileNavigationItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    final isActive = _isRouteActive(route);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacing4,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? AppColors.primaryBlue
              : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.textPrimary,
            fontWeight: isActive
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.primaryBlueLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius8,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();

          if (!isActive) {
            _navigateTo(route);
          }
        },
      ),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(
        AppDimensions.pageHorizontalPadding,
      ),
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
  // BRAND
  // =========================================================

  Widget _buildBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),

        const SizedBox(
          width: AppDimensions.spacing8,
        ),

        const Text(
          'AssetCoin',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOGO
  // =========================================================

  Widget _buildLogo() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryRed,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius8,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.account_balance_rounded,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _buildSearchButton() {
    return IconButton(
      tooltip: 'Search',
      onPressed: () {
        // Global search will be implemented later.
      },
      icon: const Icon(
        Icons.search_rounded,
      ),
    );
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            _navigateTo('/notifications');
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),

        Positioned(
          top: 7,
          right: 7,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ADMIN PROFILE
  // =========================================================

  Widget _buildAdminProfile() {
    return PopupMenuButton<String>(
      tooltip: 'Administrator account',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            _showProfileMessage();
            break;

          case 'settings':
            _navigateTo('/settings');
            break;

          case 'logout':
            // Logout will be connected to authentication.
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'profile',
          child: Text('My Profile'),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Text('Settings'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryBlueLight,
            child: const Text(
              'AD',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacing8,
          ),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Super Administrator',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(
            width: AppDimensions.spacing8,
          ),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE MESSAGE
  // =========================================================

  void _showProfileMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Administrator profile will be connected to the admin account.',
        ),
      ),
    );
  }
}

// =============================================================
// NAVIGATION ITEM MODEL
// =============================================================

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}