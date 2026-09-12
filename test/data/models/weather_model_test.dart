import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/models/location_model.dart';
import 'package:weather_app/data/models/weather_data.dart';

void main() {
  group('LocationModel', () {
    const jsonSample = {
      'name': 'London',
      'latitude': 51.50853,
      'longitude': -0.12574,
      'country': 'United Kingdom',
      'admin1': 'England',
      'is_current_location': false,
    };

    test('should parse from json correctly', () {
      final model = LocationModel.fromJson(jsonSample);

      expect(model.name, 'London');
      expect(model.latitude, 51.50853);
      expect(model.longitude, -0.12574);
      expect(model.country, 'United Kingdom');
      expect(model.admin1, 'England');
      expect(model.displayName, 'London, England, United Kingdom');
      expect(model.shortDisplayName, 'London, United Kingdom');
    });

    test('should serialize to json correctly', () {
      final model = LocationModel.fromJson(jsonSample);
      final json = model.toJson();

      expect(json['name'], 'London');
      expect(json['latitude'], 51.50853);
      expect(json['country'], 'United Kingdom');
    });
  });

  group('WeatherData', () {
    final sampleApiResponse = {
      'current': {
        'time': '2026-09-12T04:30',
        'temperature_2m': 18.5,
        'relative_humidity_2m': 72,
        'apparent_temperature': 17.8,
        'is_day': 1,
        'precipitation': 0.0,
        'weather_code': 1,
        'wind_speed_10m': 12.4,
        'surface_pressure': 1018.5,
      },
      'hourly': {
        'time': [
          '2026-09-12T05:00',
          '2026-09-12T06:00',
        ],
        'temperature_2m': [18.0, 19.2],
        'weather_code': [1, 2],
      },
      'daily': {
        'time': ['2026-09-12', '2026-09-13'],
        'weather_code': [1, 3],
        'temperature_2m_max': [23.0, 21.5],
        'temperature_2m_min': [14.0, 13.5],
      },
    };

    const testLocation = LocationModel(
      name: 'London',
      latitude: 51.50853,
      longitude: -0.12574,
      country: 'United Kingdom',
    );

    test('should parse from API response correctly', () {
      final weatherData = WeatherData.fromApiResponse(
        json: sampleApiResponse,
        location: testLocation,
      );

      expect(weatherData.location.name, 'London');
      expect(weatherData.current.temperature, 18.5);
      expect(weatherData.current.humidity, 72);
      expect(weatherData.current.weatherCode, 1);
      expect(weatherData.current.isDay, true);
      expect(weatherData.daily.length, 2);
      expect(weatherData.daily[0].maxTemp, 23.0);
    });

    test('should support round-trip json serialization for caching', () {
      final weatherData = WeatherData.fromApiResponse(
        json: sampleApiResponse,
        location: testLocation,
      );

      final jsonMap = weatherData.toJson();
      final restored = WeatherData.fromJson(jsonMap);

      expect(restored.location.name, weatherData.location.name);
      expect(restored.current.temperature, weatherData.current.temperature);
      expect(restored.current.humidity, weatherData.current.humidity);
      expect(restored.daily.length, weatherData.daily.length);
    });
  });
}
