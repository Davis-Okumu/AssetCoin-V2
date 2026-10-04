import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      // ==========================================================
      // CORE
      // ==========================================================

      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.background,

      visualDensity: VisualDensity.standard,

      // ==========================================================
      // TYPOGRAPHY
      // ==========================================================

      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodySecondary,
      ),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ==========================================================
      // CARDS
      // ==========================================================

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),

      // ==========================================================
      // INPUT FIELDS
      // ==========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        prefixIconColor: AppColors.textSecondary,

        suffixIconColor: AppColors.textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.8,
          ),
        ),
      ),

      // ==========================================================
      // ELEVATED BUTTON
      // ==========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,

          minimumSize: const Size(double.infinity, 54),

          elevation: 0,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w700,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
        ),
      ),

      // ==========================================================
      // OUTLINED BUTTON
      // ==========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,

          minimumSize: const Size(double.infinity, 54),

          side: const BorderSide(
            color: AppColors.primary,
            width: 1.3,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // TEXT BUTTON
      // ==========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ==========================================================
      // NAVIGATION BAR
      // ==========================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,

        elevation: 0,

        height: 72,

        indicatorColor: AppColors.primaryLight,

        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(
              WidgetState.selected,
            );

            return TextStyle(
              fontSize: 11,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            );
          },
        ),

        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(
              WidgetState.selected,
            );

            return IconThemeData(
              size: 23,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            );
          },
        ),
      ),

      // ==========================================================
      // FLOATING ACTION BUTTON
      // ==========================================================

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ==========================================================
      // DIVIDERS
      // ==========================================================

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ==========================================================
      // PROGRESS INDICATORS
      // ==========================================================

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primaryLight,
      ),

      // ==========================================================
      // CHECKBOXES
      // ==========================================================

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
      ),

      // ==========================================================
      // SWITCHES
      // ==========================================================

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return AppColors.textMuted;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return AppColors.border;
          },
        ),
      ),

      // ==========================================================
      // SNACKBAR
      // ==========================================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.navy,

        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        elevation: 4,
      ),
    );
  }
  
static ThemeData get dark {
  final base = light;

  const darkBackground = Color(0xFF0B1220);
  const darkSurface = Color(0xFF151F32);
  const darkSurfaceVariant = Color(0xFF1D2A40);
  const darkTextPrimary = Color(0xFFF4F7FC);
  const darkTextSecondary = Color(0xFFB0BDD0);
  const darkBorder = Color(0xFF2B3A52);

  final colorScheme = base.colorScheme.copyWith(
    brightness: Brightness.dark,

    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: Colors.white,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: Colors.white,

    surface: darkSurface,
    onSurface: darkTextPrimary,

    error: AppColors.error,
    onError: Colors.white,
  );

  return base.copyWith(
    brightness: Brightness.dark,

    colorScheme: colorScheme,

    scaffoldBackgroundColor: darkBackground,

    canvasColor: darkBackground,

    cardColor: darkSurface,

    dividerColor: darkBorder,

    textTheme: base.textTheme.apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),

    primaryTextTheme: base.primaryTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),

    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        color: darkTextPrimary,
      ),
      iconTheme: const IconThemeData(
        color: darkTextPrimary,
      ),
    ),

cardTheme: base.cardTheme.copyWith(
  color: darkSurface,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: const BorderSide(
      color: darkBorder,
      width: 1,
    ),
  ),
),

    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: darkSurfaceVariant,

      hintStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
      ),

      labelStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
      ),

      prefixIconColor: darkTextSecondary,
      suffixIconColor: darkTextSecondary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: darkBorder,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: darkBorder,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.8,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
    ),

    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryDark,
    ),

    dividerTheme: base.dividerTheme.copyWith(
      color: darkBorder,
    ),

    iconTheme: const IconThemeData(
      color: darkTextSecondary,
    ),

    listTileTheme: const ListTileThemeData(
      textColor: darkTextPrimary,
      iconColor: darkTextSecondary,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
    ),

    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: darkSurfaceVariant,
      contentTextStyle: const TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    switchTheme: base.switchTheme,

    checkboxTheme: base.checkboxTheme,
  );
}


}