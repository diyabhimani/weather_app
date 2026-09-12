import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/errors/failures.dart';
import 'package:weather_app/data/models/location_model.dart';
import 'package:weather_app/data/models/weather_data.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/logic/cubit/weather_cubit.dart';
import 'package:weather_app/logic/cubit/weather_state.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;
  late WeatherCubit cubit;

  const testLocation = LocationModel(
    name: 'London',
    latitude: 51.50853,
    longitude: -0.12574,
    country: 'United Kingdom',
  );

  final testWeather = WeatherData(
    location: testLocation,
    current: CurrentWeather(
      temperature: 21.0,
      feelsLike: 20.0,
      humidity: 60,
      windSpeed: 11.0,
      pressure: 1013.0,
      precipitation: 0.0,
      weatherCode: 0,
      isDay: true,
      time: DateTime.now(),
    ),
    hourly: const [],
    daily: const [],
    fetchedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockWeatherRepository();
    cubit = WeatherCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be WeatherInitial', () {
    expect(cubit.state, const WeatherInitial());
  });

  group('loadInitialWeather', () {
    blocTest<WeatherCubit, WeatherState>(
      'emits cached WeatherLoaded first if available, then triggers background refresh',
      build: () {
        when(() => mockRepository.getCachedWeather())
            .thenAnswer((_) async => testWeather);
        when(() => mockRepository.getWeatherForLocation(testLocation))
            .thenAnswer((_) async => testWeather);
        return cubit;
      },
      act: (c) => c.loadInitialWeather(),
      expect: () => [
        WeatherLoaded(weather: testWeather, isFromCache: true),
        WeatherLoaded(weather: testWeather, isRefreshing: true, isFromCache: true),
        WeatherLoaded(weather: testWeather, isRefreshing: false, isFromCache: false),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [WeatherLoading, WeatherLoaded] when no cache exists and fetch succeeds',
      build: () {
        when(() => mockRepository.getCachedWeather())
            .thenAnswer((_) async => null);
        when(() => mockRepository.getLastLocation())
            .thenAnswer((_) async => null);
        when(() => mockRepository.getWeatherForLocation(WeatherRepository.defaultLocation))
            .thenAnswer((_) async => testWeather);
        return cubit;
      },
      act: (c) => c.loadInitialWeather(),
      expect: () => [
        const WeatherLoading(message: 'Loading current weather...'),
        WeatherLoaded(weather: testWeather),
      ],
    );
  });

  group('refreshWeather', () {
    blocTest<WeatherCubit, WeatherState>(
      'preserves previous weather data when refresh fails with NetworkFailure',
      seed: () => WeatherLoaded(weather: testWeather),
      build: () {
        when(() => mockRepository.getWeatherForLocation(testLocation))
            .thenThrow(const NetworkFailure('No internet connection'));
        return cubit;
      },
      act: (c) => c.refreshWeather(),
      expect: () => [
        WeatherLoaded(weather: testWeather, isRefreshing: true),
        WeatherLoaded(
          weather: testWeather,
          isRefreshing: false,
          refreshError: 'Could not update weather: No internet connection',
        ),
      ],
      verify: (c) {
        // Assert state still retains the previous weather data
        final current = c.state as WeatherLoaded;
        expect(current.weather, testWeather);
        expect(current.refreshError, contains('No internet connection'));
      },
    );

    blocTest<WeatherCubit, WeatherState>(
      'updates weather and sets isRefreshing to false on successful refresh',
      seed: () => WeatherLoaded(weather: testWeather),
      build: () {
        final updatedWeather = testWeather.copyWith(
          current: CurrentWeather(
            temperature: 24.0,
            feelsLike: 23.0,
            humidity: 50,
            windSpeed: 8.0,
            pressure: 1016.0,
            precipitation: 0.0,
            weatherCode: 1,
            isDay: true,
            time: DateTime.now(),
          ),
        );
        when(() => mockRepository.getWeatherForLocation(testLocation))
            .thenAnswer((_) async => updatedWeather);
        return cubit;
      },
      act: (c) => c.refreshWeather(),
      expect: () => [
        WeatherLoaded(weather: testWeather, isRefreshing: true),
        isA<WeatherLoaded>()
            .having((s) => s.weather.current.temperature, 'temperature', 24.0)
            .having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );
  });
}
