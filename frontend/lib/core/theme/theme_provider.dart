import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemeModeNotifier extends Notifier<ThemeMode?> {
  @override
  ThemeMode? build() => null;

  void updateTheme(ThemeMode? themeMode) {
    state = themeMode;
  }

  void resetTheme() {
    state = null;
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, ThemeMode?>(
  AppThemeModeNotifier.new,
);