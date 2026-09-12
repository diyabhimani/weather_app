import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/errors/exceptions.dart';
import 'package:weather_app/core/errors/failures.dart';
import 'package:weather_app/data/models/location_model.dart';
import 'package:weather_app/data/models/weather_data.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/data/services/cache_service.dart';
import 'package:weather_app/data/services/location_service.dart';
import 'package:weather_app/data/services/weather_api_service.dart';

class MockWeatherApiService extends Mock implements WeatherApiService {}
class MockCacheService extends Mock implements CacheService {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockWeatherApiService mockApiService;
  late MockCacheService mockCacheService;
  late MockLocationService mockLocationService;
  late WeatherRepository repository;

  setUp(() {
    mockApiService = MockWeatherApiService();
    mockCacheService = MockCacheService();
    mockLocationService = MockLocationService();
    repository = WeatherRepository(
      apiService: mockApiService,
      cacheService: mockCacheService,
      locationService: mockLocationService,
    );
  });

  const testLocation = LocationModel(
    name: 'London',
    latitude: 51.50853,
    longitude: -0.12574,
  );

  final testWeather = WeatherData(
    location: testLocation,
    current: CurrentWeather(
      temperature: 20.0,
      feelsLike: 19.5,
      humidity: 65,
      windSpeed: 10.0,
      pressure: 1015.0,
      precipitation: 0.0,
      weatherCode: 0,
      isDay: true,
      time: DateTime.now(),
    ),
    hourly: const [],
    daily: const [],
    fetchedAt: DateTime.now(),
  );

  group('WeatherRepository', () {
    test('should fetch weather from API and cache it on success', () async {
      when(() => mockApiService.fetchWeather(location: testLocation))
          .thenAnswer((_) async => testWeather);
      when(() => mockCacheService.saveWeatherData(testWeather))
          .thenAnswer((_) async => true);

      final result = await repository.getWeatherForLocation(testLocation);

      expect(result, testWeather);
      verify(() => mockApiService.fetchWeather(location: testLocation)).called(1);
      verify(() => mockCacheService.saveWeatherData(testWeather)).called(1);
    });

    test('should map NetworkException to NetworkFailure', () async {
      when(() => mockApiService.fetchWeather(location: testLocation))
          .thenThrow(const NetworkException());

      expect(
        () => repository.getWeatherForLocation(testLocation),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('should retrieve cached weather from CacheService', () async {
      when(() => mockCacheService.getCachedWeatherData())
          .thenAnswer((_) async => testWeather);

      final result = await repository.getCachedWeather();

      expect(result, testWeather);
      verify(() => mockCacheService.getCachedWeatherData()).called(1);
    });

    test('should search cities through WeatherApiService', () async {
      when(() => mockApiService.searchCities('London'))
          .thenAnswer((_) async => [testLocation]);

      final result = await repository.searchCities('London');

      expect(result, [testLocation]);
      verify(() => mockApiService.searchCities('London')).called(1);
    });
  });
}
