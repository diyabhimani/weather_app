import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_data.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({
    super.key,
    required this.hourly,
  });

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                'HOURLY FORECAST (24H)',
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
        SizedBox(
          height: 115,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = hourly[index];
              final isFirst = index == 0;
              final hourText = isFirst ? 'Now' : DateTimeUtils.formatHour(item.time);
              final icon = WeatherCodeMapper.getIcon(item.weatherCode);
              final iconColor = WeatherCodeMapper.getIconColor(item.weatherCode);

              return Container(
                width: 68,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isFirst
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFirst
                        ? Colors.white.withOpacity(0.4)
                        : AppColors.cardDarkBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hourText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
                    Text(
                      '${item.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
