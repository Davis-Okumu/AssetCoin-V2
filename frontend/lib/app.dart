
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/connectivity_provider.dart';
import 'core/widgets/connectivity_banner.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

import 'features/authentication/presentation/controllers/auth_controller.dart';
import 'features/profile/presentation/providers/profile_providers.dart';

class AssetCoinApp extends ConsumerStatefulWidget {
  const AssetCoinApp({super.key});

  @override
  ConsumerState<AssetCoinApp> createState() => _AssetCoinAppState();
}

class _AssetCoinAppState extends ConsumerState<AssetCoinApp>
    with WidgetsBindingObserver {
  bool? _previousConnectionStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(authControllerProvider.notifier).refreshSession(),
      );
    }
  }

  ThemeMode _getThemeMode(String preference) {
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

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final connectivity = ref.watch(connectivityStatusProvider);

    // The saved backend preference.
    final profileSettings = ref.watch(profileSettingsProvider);

    // A local override applies immediately when the user changes the theme.
    final themeOverride = ref.watch(appThemeModeProvider);

    final savedThemeMode = profileSettings.maybeWhen(
      data: (settings) => _getThemeMode(settings.theme),
      orElse: () => ThemeMode.light,
    );

    final themeMode = themeOverride ?? savedThemeMode;

    ref.listen(connectivityStatusProvider, (previous, next) {
      next.whenData((results) {
        final isConnected = hasNetworkConnection(results);

        if (_previousConnectionStatus == null) {
          _previousConnectionStatus = isConnected;
          return;
        }

        if (_previousConnectionStatus != isConnected) {
          _previousConnectionStatus = isConnected;

          if (isConnected) {
            unawaited(
              ref
                  .read(authControllerProvider.notifier)
                  .refreshSession(),
            );
          }
        }
      });
    });

    return MaterialApp.router(
      title: 'AssetCoin',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      routerConfig: router,

      builder: (context, child) {
        final isConnected = connectivity.maybeWhen(
          data: (results) => hasNetworkConnection(results),
          orElse: () => true,
        );

        return ConnectivityBanner(
          isConnected: isConnected,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
