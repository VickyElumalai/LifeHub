
import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Background Colors
  static const darkBackground = Color(0xFF0f0f1e);
  static const darkCard = Color(0xFF1a1a2e);
  
  // Light Theme Background Colors
  static const lightBackground = Color(0xFFF5F5F7);
  static const lightCard = Colors.white;
  
  // Gradient Colors
  static const purpleGradientStart = Color(0xFF667eea);
  static const purpleGradientEnd = Color(0xFF764ba2);
  
  static const pinkGradientStart = Color(0xFFf093fb);
  static const pinkGradientEnd = Color(0xFFf5576c);
  
  static const blueGradientStart = Color(0xFF4facfe);
  static const blueGradientEnd = Color(0xFF00f2fe);
  
  static const greenGradientStart = Color(0xFF43e97b);
  static const greenGradientEnd = Color(0xFF38f9d7);
  
  static const yellowGradientStart = Color(0xFFfa709a);
  static const yellowGradientEnd = Color(0xFFfee140);
  
  // Text Colors - Dark Mode
  static const textWhite = Colors.white;
  static const textGrey = Color(0xFF8b92b8);
  
  // Text Colors - Light Mode
  static const textDark = Color(0xFF1a1a2e);
  static const textLightGrey = Color(0xFF757575);
  
  // Status Colors
  static const highPriority = Color(0xFFf5576c);
  static const mediumPriority = Color(0xFFfab1a0);
  static const lowPriority = Color(0xFF43e97b);
  
  static const pending = Color(0xFF4facfe);
  static const completed = Color(0xFF43e97b);
  static const overdue = Color(0xFFf5576c);
  
  // Helper method to get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textWhite
        : textDark;
  }
  
  static Color getSubtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textGrey
        : textLightGrey;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }
} 