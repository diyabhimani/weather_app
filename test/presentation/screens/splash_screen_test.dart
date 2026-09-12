import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/data/models/location_model.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/logic/cubit/weather_cubit.dart';
import 'package:weather_app/presentation/screens/splash_screen.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}
class FakeLocationModel extends Fake implements LocationModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLocationModel());
  });

  late MockWeatherRepository mockRepository;
  late WeatherCubit cubit;

  setUp(() {
    mockRepository = MockWeatherRepository();
    when(() => mockRepository.getCachedWeather()).thenAnswer((_) async => null);
    when(() => mockRepository.getLastLocation()).thenAnswer((_) async => null);
    when(() => mockRepository.getWeatherForLocation(any()))
        .thenAnswer((_) async => throw Exception('test'));
    cubit = WeatherCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  testWidgets('SplashScreen renders title and branding elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      RepositoryProvider<WeatherRepository>.value(
        value: mockRepository,
        child: BlocProvider<WeatherCubit>.value(
          value: cubit,
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      ),
    );

    // Initial branding check
    expect(find.text('Anglara Weather'), findsOneWidget);
    expect(find.text('Real-time atmospheric insights & forecasts'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Settle transition
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
