import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/cache_service.dart';
import 'data/services/location_service.dart';
import 'data/services/weather_api_service.dart';
import 'logic/cubit/weather_cubit.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation and transparent system overlay
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final weatherRepository = WeatherRepository(
    apiService: WeatherApiService(),
    cacheService: CacheService(),
    locationService: LocationService(),
  );

  runApp(WeatherApp(weatherRepository: weatherRepository));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    super.key,
    required this.weatherRepository,
  });

  final WeatherRepository weatherRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>.value(value: weatherRepository),
      ],
      child: BlocProvider<WeatherCubit>(
        create: (context) => WeatherCubit(repository: weatherRepository),
        child: MaterialApp(
          title: 'Anglara Weather',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
