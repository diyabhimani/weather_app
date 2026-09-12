import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../logic/cubit/weather_cubit.dart';
import '../../logic/cubit/weather_state.dart';
import '../widgets/animated_refresh_button.dart';
import '../widgets/current_weather_display.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/offline_banner.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_loading_shimmer.dart';
import 'search_city_sheet.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Load cached weather or fetch default location
    context.read<WeatherCubit>().loadInitialWeather();
  }

  void _openSearchSheet(BuildContext context) {
    final cubit = context.read<WeatherCubit>();
    final repository = RepositoryProvider.of<WeatherRepository>(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchCitySheet(
        repository: repository,
        onLocationSelected: (LocationModel location) {
          cubit.fetchWeatherForLocation(location);
        },
        onGpsSelected: () {
          cubit.fetchWeatherForCurrentGpsLocation();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state is WeatherLoaded && state.refreshError != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFE53935),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.refreshError!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<WeatherCubit>().refreshWeather();
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          // Clear the error in the cubit so it doesn't fire again
          context.read<WeatherCubit>().clearRefreshError();
        }
      },
      builder: (context, state) {
        // Compute dynamic gradient based on weather condition
        LinearGradient backgroundGradient = AppColors.cloudyNightGradient;
        bool isRefreshing = false;

        if (state is WeatherLoaded) {
          backgroundGradient = WeatherCodeMapper.getGradient(
            state.weather.current.weatherCode,
            isDay: state.weather.current.isDay,
          );
          isRefreshing = state.isRefreshing;
        }

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(context, state, isRefreshing),

                  // Main Content
                  Expanded(
                    child: _buildBody(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WeatherState state,
    bool isRefreshing,
  ) {
    final cubit = context.read<WeatherCubit>();
    String title = 'Weather';
    if (state is WeatherLoaded) {
      title = state.weather.location.name;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS Location Button
          IconButton(
            tooltip: 'My GPS Location',
            icon: const Icon(Icons.near_me_rounded, color: Colors.white),
            onPressed: isRefreshing
                ? null
                : () => cubit.fetchWeatherForCurrentGpsLocation(),
          ),

          // Title / City Switcher
          InkWell(
            onTap: () => _openSearchSheet(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Actions: Search & Refresh
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Search City',
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () => _openSearchSheet(context),
              ),
              AnimatedRefreshButton(
                isRefreshing: isRefreshing,
                onPressed: () => cubit.refreshWeather(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherState state) {
    if (state is WeatherLoading) {
      return WeatherLoadingShimmer(message: state.message);
    }

    if (state is WeatherError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<WeatherCubit>().refreshWeather(),
        onSearchCity: () => _openSearchSheet(context),
      );
    }

    if (state is WeatherLoaded) {
      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: () => context.read<WeatherCubit>().refreshWeather(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Offline Cached Banner if loaded from cache
              if (state.isFromCache)
                OfflineBanner(
                  cachedAt: state.weather.fetchedAt,
                  onTapRefresh: () =>
                      context.read<WeatherCubit>().refreshWeather(),
                ),

              // Current Weather Hero Display
              CurrentWeatherDisplay(weather: state.weather),
              const SizedBox(height: 24),

              // Hourly 24-hour Forecast
              HourlyForecastList(hourly: state.weather.hourly),
              const SizedBox(height: 24),

              // Weather Details Metric Grid
              WeatherDetailsGrid(current: state.weather.current),
              const SizedBox(height: 24),

              // 7-Day Forecast
              DailyForecastList(daily: state.weather.daily),
              const SizedBox(height: 24),

              // Footer / Last Updated & Attribution
              Text(
                'Last updated at ${DateTimeUtils.formatTime(state.weather.fetchedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Data provided by Open-Meteo',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    // Default placeholder
    return const SizedBox.shrink();
  }
}
