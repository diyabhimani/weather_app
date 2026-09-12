import 'package:equatable/equatable.dart';
import '../../data/models/weather_data.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to any action
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Full loading state (e.g., first launch or switching to a new searched city)
class WeatherLoading extends WeatherState {
  const WeatherLoading({this.message = 'Fetching weather data...'});
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Successful weather state
/// [isRefreshing] is true when manual pull-to-refresh or refresh button is active
/// [refreshError] is non-null when a refresh fails, ensuring previous data stays visible!
/// [isFromCache] is true if the displayed data is restored from local cache (offline)
class WeatherLoaded extends WeatherState {
  const WeatherLoaded({
    required this.weather,
    this.isRefreshing = false,
    this.refreshError,
    this.isFromCache = false,
  });

  final WeatherData weather;
  final bool isRefreshing;
  final String? refreshError;
  final bool isFromCache;

  WeatherLoaded copyWith({
    WeatherData? weather,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
    bool? isFromCache,
  }) {
    return WeatherLoaded(
      weather: weather ?? this.weather,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError ? null : (refreshError ?? this.refreshError),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        weather,
        isRefreshing,
        refreshError,
        isFromCache,
      ];
}

/// Error state when initial weather cannot be loaded AND no cached data exists
class WeatherError extends WeatherState {
  const WeatherError({
    required this.message,
    this.canRetry = true,
  });

  final String message;
  final bool canRetry;

  @override
  List<Object?> get props => [message, canRetry];
}
