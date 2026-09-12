import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/errors/failures.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository(),
        super(const WeatherInitial());

  final WeatherRepository _repository;

  /// Loads initial weather by checking offline cache first, then refreshing in background
  Future<void> loadInitialWeather() async {
    try {
      final cachedWeather = await _repository.getCachedWeather();
      if (cachedWeather != null) {
        // Immediately show cached data so user sees something instantly
        emit(WeatherLoaded(
          weather: cachedWeather,
          isFromCache: true,
        ));
        // Silently refresh in the background
        await refreshWeather();
        return;
      }

      // No cache, fetch default location
      emit(const WeatherLoading(message: 'Loading current weather...'));
      final defaultLoc = await _repository.getLastLocation() ?? WeatherRepository.defaultLocation;
      final weather = await _repository.getWeatherForLocation(defaultLoc);
      emit(WeatherLoaded(weather: weather));
    } on Failure catch (e) {
      emit(WeatherError(message: e.message));
    } catch (e) {
      emit(WeatherError(message: 'Failed to load weather: $e'));
    }
  }

  /// Fetches weather for a newly selected location (e.g. from city search)
  Future<void> fetchWeatherForLocation(LocationModel location) async {
    emit(WeatherLoading(message: 'Loading weather for ${location.name}...'));
    try {
      final weather = await _repository.getWeatherForLocation(location);
      emit(WeatherLoaded(weather: weather, isFromCache: false));
    } on Failure catch (e) {
      emit(WeatherError(message: e.message));
    } catch (e) {
      emit(WeatherError(message: 'Could not fetch weather: $e'));
    }
  }

  /// Manually refreshes current weather data.
  /// REQUIREMENT: On failure, previous data remains completely visible!
  Future<void> refreshWeather() async {
    final currentState = state;

    if (currentState is WeatherLoaded) {
      // Mark as refreshing while retaining existing data on screen
      emit(currentState.copyWith(
        isRefreshing: true,
        clearRefreshError: true,
      ));

      try {
        final updatedWeather = await _repository.getWeatherForLocation(
          currentState.weather.location,
        );
        emit(WeatherLoaded(
          weather: updatedWeather,
          isRefreshing: false,
          isFromCache: false,
        ));
      } on Failure catch (e) {
        // RETAIN PREVIOUS WEATHER! Set refreshError so UI can display a SnackBar
        emit(currentState.copyWith(
          isRefreshing: false,
          refreshError: 'Could not update weather: ${e.message}',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isRefreshing: false,
          refreshError: 'Could not update weather: $e',
        ));
      }
    } else {
      // If we don't have existing weather, show loading and fetch default
      emit(const WeatherLoading(message: 'Refreshing weather...'));
      try {
        final loc = await _repository.getLastLocation() ?? WeatherRepository.defaultLocation;
        final weather = await _repository.getWeatherForLocation(loc);
        emit(WeatherLoaded(weather: weather));
      } on Failure catch (e) {
        emit(WeatherError(message: e.message));
      } catch (e) {
        emit(WeatherError(message: 'Could not update weather: $e'));
      }
    }
  }

  /// Fetches weather using device GPS location
  Future<void> fetchWeatherForCurrentGpsLocation() async {
    final currentState = state;
    if (currentState is WeatherLoaded) {
      emit(currentState.copyWith(isRefreshing: true, clearRefreshError: true));
    } else {
      emit(const WeatherLoading(message: 'Acquiring GPS location...'));
    }

    try {
      final location = await _repository.getCurrentGpsLocation();
      final weather = await _repository.getWeatherForLocation(location);
      emit(WeatherLoaded(weather: weather, isFromCache: false));
    } on Failure catch (e) {
      if (currentState is WeatherLoaded) {
        emit(currentState.copyWith(
          isRefreshing: false,
          refreshError: e.message,
        ));
      } else {
        emit(WeatherError(message: e.message));
      }
    } catch (e) {
      if (currentState is WeatherLoaded) {
        emit(currentState.copyWith(
          isRefreshing: false,
          refreshError: 'Location error: $e',
        ));
      } else {
        emit(WeatherError(message: 'Location error: $e'));
      }
    }
  }

  /// Clears the refresh error message after user views it
  void clearRefreshError() {
    if (state is WeatherLoaded) {
      final current = state as WeatherLoaded;
      emit(current.copyWith(clearRefreshError: true));
    }
  }
}
