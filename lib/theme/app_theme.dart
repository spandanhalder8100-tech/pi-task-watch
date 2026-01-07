import 'package:flutter/material.dart';

class AppTheme {
  // Primary Theme Colors
  static const Color primaryLight = Color(0xFFE91E63); // Pink
  static const Color primaryDark = Color(0xFFC2185B); // Dark Pink
  static const Color accentColor = Color(0xFFFF4081); // Pink Accent

  // Status Colors
  static const _active = Color(0xFF2ECC71);
  static const _paused = Color(0xFFF39C12);
  static const _error = Color(0xFFE74C3C);

  // Tracker States
  static TrackerStateColors active = TrackerStateColors(
    primary: _active,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
    ),
    text: Colors.white,
    border: _active.withOpacity(0.3),
    shadow: _active.withOpacity(0.2),
    background: _active.withOpacity(0.1),
  );

  static TrackerStateColors paused = TrackerStateColors(
    primary: _paused,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF39C12), Color(0xFFD35400)],
    ),
    text: Colors.white,
    border: _paused.withOpacity(0.3),
    shadow: _paused.withOpacity(0.2),
    background: _paused.withOpacity(0.1),
  );

  static TrackerStateColors error = TrackerStateColors(
    primary: _error,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
    ),
    text: Colors.white,
    border: _error.withOpacity(0.3),
    shadow: _error.withOpacity(0.2),
    background: _error.withOpacity(0.1),
  );

  // Stats Card Theme
  static List<StatsCardTheme> statsCards = [
    StatsCardTheme(
      color: const Color(0xFF3498DB),
      icon: Icons.task_alt,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
      ),
    ),
    StatsCardTheme(
      color: const Color(0xFF2ECC71),
      icon: Icons.timer,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
      ),
    ),
    StatsCardTheme(
      color: const Color(0xFFF1C40F),
      icon: Icons.psychology,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
      ),
    ),
  ];

  // Card Decorations
  static BoxDecoration cardDecoration({
    required TrackerStateColors state,
    double borderRadius = 12,
    bool elevated = true,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: state.border, width: 1),
      boxShadow:
          elevated
              ? [
                BoxShadow(
                  color: state.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
              : null,
    );
  }

  // Button Styles
  static ButtonStyle primaryButton({
    Color? backgroundColor,
    double borderRadius = 30,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryLight,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ButtonStyle secondaryButton({double borderRadius = 30}) {
    return TextButton.styleFrom(
      foregroundColor: Colors.grey.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Text Styles
  static TextStyle get headingStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get subheadingStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle get labelStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  static ThemeData compactTheme(BuildContext context, {Color? primaryColor}) {
    final Color primary = primaryColor ?? Colors.pink;

    return ThemeData(
      primaryColor: primary,
      primarySwatch: _getMaterialColorFromColor(primary),
      useMaterial3: false,

      // Typography - Reduced sizes for compact UI
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 12),
        bodyMedium: TextStyle(fontSize: 11),
        bodySmall: TextStyle(fontSize: 10),
        labelLarge: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        labelMedium: TextStyle(fontSize: 10),
        labelSmall: TextStyle(fontSize: 9),
      ),

      // Input Decorations
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // Increased
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Slightly increased roundness
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Slightly increased roundness
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Slightly increased roundness
          borderSide: BorderSide(color: primary),
        ),
        hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        labelStyle: const TextStyle(fontSize: 11),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Increased
          textStyle: const TextStyle(fontSize: 15), // Increased
          minimumSize: const Size(0, 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ), // Increased roundness
          elevation: 1,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          minimumSize: const Size(0, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: const TextStyle(fontSize: 11),
          minimumSize: const Size(0, 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),

      // Dialogs and Cards
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(fontSize: 11),
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 48,
      ),

      // Icons - Fixed implementation
      iconTheme: IconThemeData(size: 16, color: Colors.grey.shade700),

      // Visual Density for compact layouts
      visualDensity: VisualDensity.compact,
    );
  }

  // Helper method to convert Color to MaterialColor
  static MaterialColor _getMaterialColorFromColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }
}

class TrackerStateColors {
  final Color primary;
  final LinearGradient gradient;
  final Color text;
  final Color border;
  final Color shadow;
  final Color background;

  TrackerStateColors({
    required this.primary,
    required this.gradient,
    required this.text,
    required this.border,
    required this.shadow,
    required this.background,
  });
}

class StatsCardTheme {
  final Color color;
  final IconData icon;
  final LinearGradient gradient;

  StatsCardTheme({
    required this.color,
    required this.icon,
    required this.gradient,
  });
}
