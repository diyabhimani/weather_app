import 'package:flutter/material.dart';
import '../../core/utils/weather_code_mapper.dart';

class WeatherIconWidget extends StatelessWidget {
  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.isDay = true,
    this.size = 80,
    this.animate = true,
  });

  final int weatherCode;
  final bool isDay;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final icon = WeatherCodeMapper.getIcon(weatherCode, isDay: isDay);
    final color = WeatherCodeMapper.getIconColor(weatherCode, isDay: isDay);

    return Container(
      width: size * 1.3,
      height: size * 1.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
