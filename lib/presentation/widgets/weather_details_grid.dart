import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/weather_data.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({
    super.key,
    required this.current,
  });

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final details = [
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${current.windSpeed.toStringAsFixed(1)} km/h',
      ),
      _DetailItem(
        icon: Icons.water_drop_rounded,
        label: 'Humidity',
        value: '${current.humidity}%',
      ),
      _DetailItem(
        icon: Icons.compress_rounded,
        label: 'Pressure',
        value: '${current.pressure.round()} hPa',
      ),
      _DetailItem(
        icon: Icons.umbrella_rounded,
        label: 'Precipitation',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
      ),
      _DetailItem(
        icon: Icons.thermostat_rounded,
        label: 'Feels Like',
        value: '${current.feelsLike.round()}°C',
      ),
      _DetailItem(
        icon: current.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        label: 'Cycle',
        value: current.isDay ? 'Daytime' : 'Nighttime',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final item = details[index];
        return _buildCard(item);
      },
    );
  }

  Widget _buildCard(_DetailItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardDarkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 22,
            color: AppColors.accent,
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
