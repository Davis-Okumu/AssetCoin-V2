import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class AssetCoinAdminApp extends StatelessWidget {
  const AssetCoinAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AssetCoin Admin',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      routerConfig: appRouter,
    );
  }
}