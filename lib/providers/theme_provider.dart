import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:life_hub/core/constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox('settingsBox');
    final isDark = box.get('isDarkMode', defaultValue: true);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = await Hive.openBox('settingsBox');
    await box.put('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.purpleGradientStart,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      
      // AppBar theme for light mode
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1a1a2e),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1a1a2e)),
      ),
      
      // Card theme for light mode
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Text theme for light mode
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF1a1a2e),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF1a1a2e),
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF1a1a2e),
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1a1a2e),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1a1a2e),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Color(0xFF1a1a2e)),
        bodyMedium: TextStyle(color: Color(0xFF424242)),
        bodySmall: TextStyle(color: Color(0xFF757575)),
      ),
      
      // Icon theme for light mode
      iconTheme: const IconThemeData(
        color: Color(0xFF1a1a2e),
      ),
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.purpleGradientStart,
        secondary: AppColors.pinkGradientStart,
        surface: Colors.white,
        background: Color(0xFFF5F5F7),
        error: AppColors.highPriority,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1a1a2e),
        onBackground: Color(0xFF1a1a2e),
        onError: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.purpleGradientStart,
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      // AppBar theme for dark mode
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card theme for dark mode
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      
      // Text theme for dark mode
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: AppColors.textGrey),
        bodySmall: TextStyle(color: AppColors.textGrey),
      ),
      
      // Icon theme for dark mode
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purpleGradientStart,
        secondary: AppColors.pinkGradientStart,
        surface: AppColors.darkCard,
        background: AppColors.darkBackground,
        error: AppColors.highPriority,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}