// lib/theme/theme_config.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_constants.dart';

class DLTheme {
  static ThemeData darkTheme(BuildContext context) {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: DLColors.bgDark,
      primaryColor: DLColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: DLColors.primary,
        primaryContainer: DLColors.primaryDark,
        secondary: DLColors.secondary,
        secondaryContainer: DLColors.secondaryDark,
        surface: DLColors.bgDarkCard,
        background: DLColors.bgDark,
        error: DLColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DLColors.textPrimary,
        onBackground: DLColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DLRadius.card),
          side: const BorderSide(color: DLColors.cardBorder, width: 1.0),
        ),
        color: DLColors.bgDarkCard,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DLColors.bgDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: DLColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DLColors.bgDarkElevated,
        selectedItemColor: DLColors.primary,
        unselectedItemColor: DLColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DLColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DLSpacing.lg,
            vertical: DLSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DLRadius.button),
          ),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DLColors.primary,
          side: const BorderSide(color: DLColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: DLSpacing.lg,
            vertical: DLSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DLRadius.button),
          ),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DLColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DLSpacing.md,
            vertical: DLSpacing.sm,
          ),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DLColors.divider,
        thickness: 1,
        space: DLSpacing.md,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: DLColors.primary,
        unselectedLabelColor: DLColors.textSecondary,
        indicatorColor: DLColors.primary,
        labelStyle: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: base.textTheme.titleSmall,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: DLColors.textPrimary,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          color: DLColors.textPrimary,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: DLColors.textPrimary,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: DLColors.textSecondary,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: DLColors.textSecondary,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: DLColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(
        color: DLColors.textPrimary,
        size: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DLColors.bgDarkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DLRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DLRadius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DLRadius.medium),
          borderSide: const BorderSide(color: DLColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DLRadius.medium),
          borderSide: const BorderSide(color: DLColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DLRadius.medium),
          borderSide: const BorderSide(color: DLColors.error, width: 1.5),
        ),
        labelStyle: base.textTheme.titleMedium?.copyWith(
          color: DLColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DLSpacing.md,
          vertical: DLSpacing.md,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DLColors.primary,
        linearTrackColor: DLColors.bgDarkElevated,
        circularTrackColor: DLColors.bgDarkElevated,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return DLColors.primary;
          }
          return DLColors.textSecondary;
        }),
        side: const BorderSide(color: DLColors.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: DLColors.primary,
        inactiveTrackColor: DLColors.bgDarkElevated,
        thumbColor: DLColors.primary,
        overlayColor: DLColors.primary.withOpacity(0.2),
        valueIndicatorColor: DLColors.primary,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return DLColors.primary;
          }
          return DLColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return DLColors.primary.withOpacity(0.5);
          }
          return DLColors.bgDarkElevated;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return DLColors.primary;
          }
          return DLColors.textSecondary;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DLColors.bgDarkElevated,
          borderRadius: BorderRadius.circular(DLRadius.small),
        ),
        textStyle: base.textTheme.bodySmall?.copyWith(
          color: DLColors.textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DLColors.bgDarkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DLRadius.xl),
            topRight: Radius.circular(DLRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: DLColors.bgDarkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DLRadius.large),
        ),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DLColors.bgDarkElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DLRadius.small),
        ),
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: DLColors.textPrimary,
        ),
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    // For this app, we'll focus on the dark theme since it's specified
    // in the requirements, but we'll keep a basic light theme
    // implementation for completeness
    return darkTheme(context);
  }
}