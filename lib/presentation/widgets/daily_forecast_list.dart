import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_data.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.daily,
  });

  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                '7-DAY FORECAST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardDarkBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white.withOpacity(0.08),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final item = daily[index];
              final dayName = DateTimeUtils.formatDayName(item.date);
              final icon = WeatherCodeMapper.getIcon(item.weatherCode);
              final iconColor = WeatherCodeMapper.getIconColor(item.weatherCode);
              final desc = WeatherCodeMapper.getDescription(item.weatherCode);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Day of week
                    SizedBox(
                      width: 70,
                      child: Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              dayName == 'Today' ? FontWeight.bold : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Weather Icon & condition
                    Icon(
                      icon,
                      size: 20,
                      color: iconColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Min & Max temperatures
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.minTemp.round()}°',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Small temperature bar
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.maxTemp.round()}°',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
