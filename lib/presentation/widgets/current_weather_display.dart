import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_data.dart';
import 'weather_icon_widget.dart';

class CurrentWeatherDisplay extends StatelessWidget {
  const CurrentWeatherDisplay({
    super.key,
    required this.weather,
  });

  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final location = weather.location;
    final conditionText = WeatherCodeMapper.getDescription(current.weatherCode);

    // Get today's high and low from daily forecast if available
    String highLowText = '';
    if (weather.daily.isNotEmpty) {
      final todayDaily = weather.daily.first;
      highLowText =
          'H: ${todayDaily.maxTemp.round()}°  L: ${todayDaily.minTemp.round()}°';
    }

    return Column(
      children: [
        const SizedBox(height: 8),

        // Location Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (location.isCurrentLocation) ...[
              const Icon(
                Icons.near_me_rounded,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        if (location.country != null && location.country!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            location.shortDisplayName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 6),

        // Date
        Text(
          DateTimeUtils.formatFullDate(current.time),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 20),

        // Hero Weather Icon
        WeatherIconWidget(
          weatherCode: current.weatherCode,
          isDay: current.isDay,
          size: 96,
        ),

        const SizedBox(height: 12),

        // Temperature
        Text(
          '${current.temperature.round()}°',
          style: const TextStyle(
            fontSize: 84,
            fontWeight: FontWeight.w200,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),

        // Condition Text
        Text(
          conditionText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        // Feels like & High/Low
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Feels like ${current.feelsLike.round()}°',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (highLowText.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                highLowText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
