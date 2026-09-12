import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/errors/failures.dart';
import 'package:weather_app/data/models/location_model.dart';
import 'package:weather_app/data/models/weather_data.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/logic/cubit/weather_cubit.dart';
import 'package:weather_app/presentation/screens/weather_screen.dart';
import 'package:weather_app/presentation/widgets/current_weather_display.dart';
import 'package:weather_app/presentation/widgets/daily_forecast_list.dart';
import 'package:weather_app/presentation/widgets/hourly_forecast_list.dart';
import 'package:weather_app/presentation/widgets/weather_details_grid.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class FakeLocationModel extends Fake implements LocationModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLocationModel());
  });

  late MockWeatherRepository mockRepository;
  late WeatherCubit cubit;

  const testLocation = LocationModel(
    name: 'San Francisco',
    latitude: 37.7749,
    longitude: -122.4194,
    country: 'United States',
  );

  final testWeather = WeatherData(
    location: testLocation,
    current: CurrentWeather(
      temperature: 19.4,
      feelsLike: 18.8,
      humidity: 65,
      windSpeed: 14.2,
      pressure: 1014.0,
      precipitation: 0.0,
      weatherCode: 2,
      isDay: true,
      time: DateTime.now(),
    ),
    hourly: [
      HourlyForecast(
        time: DateTime.now(),
        temperature: 19.0,
        weatherCode: 2,
      ),
    ],
    daily: [
      DailyForecast(
        date: DateTime.now(),
        minTemp: 13.0,
        maxTemp: 22.0,
        weatherCode: 2,
      ),
    ],
    fetchedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockWeatherRepository();
    when(() => mockRepository.getLastLocation()).thenAnswer((_) async => testLocation);
  });

  tearDown(() {
    cubit.close();
  });

  Widget createWidgetUnderTest(WeatherCubit cubitInstance) {
    return RepositoryProvider<WeatherRepository>.value(
      value: mockRepository,
      child: BlocProvider<WeatherCubit>.value(
        value: cubitInstance,
        child: const MaterialApp(
          home: WeatherScreen(),
        ),
      ),
    );
  }

  testWidgets('WeatherScreen displays all core weather components when loaded',
      (WidgetTester tester) async {
    when(() => mockRepository.getCachedWeather()).thenAnswer((_) async => testWeather);
    when(() => mockRepository.getWeatherForLocation(any())).thenAnswer((_) async => testWeather);

    cubit = WeatherCubit(repository: mockRepository);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    // Expect core components
    expect(find.byType(CurrentWeatherDisplay), findsOneWidget);
    expect(find.byType(HourlyForecastList), findsOneWidget);
    expect(find.byType(WeatherDetailsGrid), findsOneWidget);
    expect(find.byType(DailyForecastList), findsOneWidget);

    // Expect values
    expect(find.text('San Francisco'), findsWidgets);
    expect(find.text('19°'), findsWidgets);
    expect(find.text('Partly Cloudy'), findsWidgets);
  });

  testWidgets(
      'WeatherScreen displays SnackBar on refresh error while keeping weather visible',
      (WidgetTester tester) async {
    // Initial cache is returned
    when(() => mockRepository.getCachedWeather()).thenAnswer((_) async => testWeather);
    // Refresh fails with NetworkFailure
    when(() => mockRepository.getWeatherForLocation(any()))
        .thenThrow(const NetworkFailure('No internet connection'));

    cubit = WeatherCubit(repository: mockRepository);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Weather is still rendered! (Requirement: data remains visible)
    expect(find.text('San Francisco'), findsWidgets);
    expect(find.text('19°'), findsWidgets);

    // SnackBar error notification is displayed
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('No internet connection'), findsOneWidget);
  });
}
