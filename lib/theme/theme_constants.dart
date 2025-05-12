// lib/theme/theme_constants.dart

import 'package:flutter/material.dart';

class DLColors {
  // Primary colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8A7EF2);
  static const Color primaryDark = Color(0xFF4A3BD9);

  // Secondary colors
  static const Color secondary = Color(0xFF00D2D3);
  static const Color secondaryLight = Color(0xFF5AEBEC);
  static const Color secondaryDark = Color(0xFF00A0A1);

  // Accent colors
  static const Color accent = Color(0xFFFD79A8);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);

  // Background colors
  static const Color bgDark = Color(0xFF121212);
  static const Color bgDarkElevated = Color(0xFF1E1E1E);
  static const Color bgDarkCard = Color(0xFF252525);

  // Text colors
  static const Color textPrimary = Color(0xFFFEFEFE);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF757575);

  // Gradient colors
  static const List<Color> primaryGradient = [primary, Color(0xFF8E2DE2)];
  static const List<Color> successGradient = [success, Color(0xFF26D0CE)];
  static const List<Color> errorGradient = [error, Color(0xFFFF4757)];

  // Special elements
  static const Color divider = Color(0xFF2A2A2A);
  static const Color cardBorder = Color(0xFF333333);
  static const Color shimmer = Color(0xFF3A3A3A);
}

class DLGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: DLColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [DLColors.secondary, Color(0xFF00C9C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF252525), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: DLColors.successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: DLColors.errorGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient routeGradient(Color color) {
    return LinearGradient(
      colors: [color, color.withOpacity(0.7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

class DLShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    )
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    )
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    )
  ];

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.6),
        blurRadius: 8,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: 16,
        spreadRadius: -4,
      )
    ];
  }
}

class DLAnimations {
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve bounceOut = Curves.elasticOut;
}

class DLRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
  static const double card = 16.0;
  static const double button = 12.0;
  static const double chip = 20.0;
}

class DLSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}