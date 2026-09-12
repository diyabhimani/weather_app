import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF2E6FF2);
  static const Color primaryDark = Color(0xFF1B4AB8);
  static const Color accent = Color(0xFF48C6EF);
  static const Color secondary = Color(0xFFFFB300);

  // Neutral colors
  static const Color cardDark = Color(0x2EFFFFFF);
  static const Color cardDarkBorder = Color(0x3DFFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x80FFFFFF);

  // Dynamic Weather Gradients (List of LinearGradients)
  static const LinearGradient sunnyDayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3A88E9),
      Color(0xFF6FBAFF),
      Color(0xFF90D5FF),
    ],
  );

  static const LinearGradient clearNightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F2027),
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
  );

  static const LinearGradient cloudyDayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5D748A),
      Color(0xFF7E97AD),
      Color(0xFFA5B9CA),
    ],
  );

  static const LinearGradient cloudyNightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E272C),
      Color(0xFF2E3D49),
      Color(0xFF3F5161),
    ],
  );

  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2C3E50),
      Color(0xFF3E5871),
      Color(0xFF4B6B88),
    ],
  );

  static const LinearGradient thunderstormGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141E30),
      Color(0xFF243B55),
      Color(0xFF3D2C55),
    ],
  );

  static const LinearGradient snowyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF607D8B),
      Color(0xFF8BA5B5),
      Color(0xFFB0C7D6),
    ],
  );

  static const LinearGradient foggyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4B5D67),
      Color(0xFF6B7E8A),
      Color(0xFF8899A6),
    ],
  );
}
