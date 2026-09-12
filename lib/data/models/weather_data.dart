import 'package:equatable/equatable.dart';
import '../../core/utils/date_time_utils.dart';
import 'location_model.dart';

class CurrentWeather extends Equatable {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.precipitation,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final double precipitation;
  final int weatherCode;
  final bool isDay;
  final DateTime time;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['apparent_temperature'] as num?)?.toDouble() ??
          (json['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      humidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['surface_pressure'] as num?)?.toDouble() ?? 1013.2,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      isDay: (json['is_day'] as num?)?.toInt() == 1,
      time: json['time'] != null
          ? DateTimeUtils.parseDateTime(json['time'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature_2m': temperature,
      'apparent_temperature': feelsLike,
      'relative_humidity_2m': humidity,
      'wind_speed_10m': windSpeed,
      'surface_pressure': pressure,
      'precipitation': precipitation,
      'weather_code': weatherCode,
      'is_day': isDay ? 1 : 0,
      'time': time.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        temperature,
        feelsLike,
        humidity,
        windSpeed,
        pressure,
        precipitation,
        weatherCode,
        isDay,
        time,
      ];
}

class HourlyForecast extends Equatable {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTimeUtils.parseDateTime(json['time'].toString()),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weather_code': weatherCode,
    };
  }

  @override
  List<Object?> get props => [time, temperature, weatherCode];
}

class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
  });

  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTimeUtils.parseDateTime(json['date'].toString()),
      minTemp: (json['min_temp'] as num).toDouble(),
      maxTemp: (json['max_temp'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'weather_code': weatherCode,
    };
  }

  @override
  List<Object?> get props => [date, minTemp, maxTemp, weatherCode];
}

class WeatherData extends Equatable {
  const WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  final LocationModel location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  factory WeatherData.fromApiResponse({
    required Map<String, dynamic> json,
    required LocationModel location,
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final currentWeather = CurrentWeather.fromJson(currentJson);

    // Hourly
    final hourlyList = <HourlyForecast>[];
    final hourlyJson = json['hourly'] as Map<String, dynamic>?;
    if (hourlyJson != null) {
      final times = hourlyJson['time'] as List<dynamic>? ?? [];
      final temps = hourlyJson['temperature_2m'] as List<dynamic>? ?? [];
      final codes = hourlyJson['weather_code'] as List<dynamic>? ?? [];

      final count = times.length;
      final now = DateTime.now();

      for (int i = 0; i < count; i++) {
        final time = DateTimeUtils.parseDateTime(times[i].toString());
        // Only include current hour and future hours (next 24 hours)
        if (time.isAfter(now.subtract(const Duration(hours: 1))) &&
            hourlyList.length < 24) {
          hourlyList.add(
            HourlyForecast(
              time: time,
              temperature: (temps[i] as num).toDouble(),
              weatherCode: (codes[i] as num).toInt(),
            ),
          );
        }
      }
    }

    // Daily
    final dailyList = <DailyForecast>[];
    final dailyJson = json['daily'] as Map<String, dynamic>?;
    if (dailyJson != null) {
      final dates = dailyJson['time'] as List<dynamic>? ?? [];
      final minTemps = dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
      final maxTemps = dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
      final codes = dailyJson['weather_code'] as List<dynamic>? ?? [];

      final count = dates.length;
      for (int i = 0; i < count; i++) {
        dailyList.add(
          DailyForecast(
            date: DateTimeUtils.parseDateTime(dates[i].toString()),
            minTemp: (minTemps[i] as num).toDouble(),
            maxTemp: (maxTemps[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
          ),
        );
      }
    }

    return WeatherData(
      location: location,
      current: currentWeather,
      hourly: hourlyList,
      daily: dailyList,
      fetchedAt: DateTime.now(),
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: (json['hourly'] as List<dynamic>?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      daily: (json['daily'] as List<dynamic>?)
              ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fetchedAt: json['fetched_at'] != null
          ? DateTimeUtils.parseDateTime(json['fetched_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'hourly': hourly.map((e) => e.toJson()).toList(),
      'daily': daily.map((e) => e.toJson()).toList(),
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  WeatherData copyWith({
    LocationModel? location,
    CurrentWeather? current,
    List<HourlyForecast>? hourly,
    List<DailyForecast>? daily,
    DateTime? fetchedAt,
  }) {
    return WeatherData(
      location: location ?? this.location,
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
      daily: daily ?? this.daily,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  List<Object?> get props => [location, current, hourly, daily, fetchedAt];
}
