import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum WeatherConditionCategory {
  clear,
  cloudy,
  rainy,
  snowy,
  thunderstorm,
  foggy,
}

class WeatherCodeMapper {
  /// Maps WMO code to human-readable description
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing Rime Fog';
      case 51:
        return 'Light Drizzle';
      case 53:
        return 'Moderate Drizzle';
      case 55:
        return 'Dense Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
        return 'Slight Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
        return 'Slight Snow';
      case 73:
        return 'Moderate Snow';
      case 75:
        return 'Heavy Snow';
      case 77:
        return 'Snow Grains';
      case 80:
        return 'Slight Rain Showers';
      case 81:
        return 'Moderate Rain Showers';
      case 82:
        return 'Violent Rain Showers';
      case 85:
        return 'Slight Snow Showers';
      case 86:
        return 'Heavy Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Partly Cloudy';
    }
  }

  /// Maps WMO code to category
  static WeatherConditionCategory getCategory(int code) {
    switch (code) {
      case 0:
      case 1:
        return WeatherConditionCategory.clear;
      case 2:
      case 3:
        return WeatherConditionCategory.cloudy;
      case 45:
      case 48:
        return WeatherConditionCategory.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return WeatherConditionCategory.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherConditionCategory.snowy;
      case 95:
      case 96:
      case 99:
        return WeatherConditionCategory.thunderstorm;
      default:
        return WeatherConditionCategory.cloudy;
    }
  }

  /// Gets dynamic background gradient based on condition category and day/night
  static LinearGradient getGradient(int code, {bool isDay = true}) {
    final category = getCategory(code);
    switch (category) {
      case WeatherConditionCategory.clear:
        return isDay ? AppColors.sunnyDayGradient : AppColors.clearNightGradient;
      case WeatherConditionCategory.cloudy:
        return isDay ? AppColors.cloudyDayGradient : AppColors.cloudyNightGradient;
      case WeatherConditionCategory.rainy:
        return AppColors.rainyGradient;
      case WeatherConditionCategory.thunderstorm:
        return AppColors.thunderstormGradient;
      case WeatherConditionCategory.snowy:
        return AppColors.snowyGradient;
      case WeatherConditionCategory.foggy:
        return AppColors.foggyGradient;
    }
  }

  /// Gets IconData for weather condition
  static IconData getIcon(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case 1:
      case 2:
        return isDay ? Icons.wb_cloudy_rounded : Icons.nightlight_round;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.blur_on_rounded;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  /// Gets primary icon accent color
  static Color getIconColor(int code, {bool isDay = true}) {
    switch (getCategory(code)) {
      case WeatherConditionCategory.clear:
        return isDay ? const Color(0xFFFFC107) : const Color(0xFFE0E6ED);
      case WeatherConditionCategory.cloudy:
        return const Color(0xFFCFD8DC);
      case WeatherConditionCategory.rainy:
        return const Color(0xFF64B5F6);
      case WeatherConditionCategory.thunderstorm:
        return const Color(0xFFFFD54F);
      case WeatherConditionCategory.snowy:
        return const Color(0xFFE1F5FE);
      case WeatherConditionCategory.foggy:
        return const Color(0xFFB0BEC5);
    }
  }
}
