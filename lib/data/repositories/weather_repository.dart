import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository({
    WeatherApiService? apiService,
    CacheService? cacheService,
    LocationService? locationService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _cacheService = cacheService ?? CacheService(),
        _locationService = locationService ?? LocationService();

  final WeatherApiService _apiService;
  final CacheService _cacheService;
  final LocationService _locationService;

  /// Default fallback location if no cache or GPS is available
  static const LocationModel defaultLocation = LocationModel(
    name: ApiConstants.defaultCityName,
    country: ApiConstants.defaultCountry,
    latitude: ApiConstants.defaultLatitude,
    longitude: ApiConstants.defaultLongitude,
  );

  /// Fetch weather for a specific location and update local cache
  Future<WeatherData> getWeatherForLocation(LocationModel location) async {
    try {
      final weather = await _apiService.fetchWeather(location: location);
      await _cacheService.saveWeatherData(weather);
      return weather;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on RateLimitException catch (e) {
      throw RateLimitFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on AppException catch (e) {
      throw GenericFailure(e.message);
    } catch (e) {
      throw GenericFailure(e.toString());
    }
  }

  /// Get cached weather data if available
  Future<WeatherData?> getCachedWeather() async {
    return await _cacheService.getCachedWeatherData();
  }

  /// Get last viewed location if available
  Future<LocationModel?> getLastLocation() async {
    return await _cacheService.getLastLocation();
  }

  /// Search cities by text query
  Future<List<LocationModel>> searchCities(String query) async {
    try {
      return await _apiService.searchCities(query);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on RateLimitException catch (e) {
      throw RateLimitFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw GenericFailure(e.toString());
    }
  }

  /// Fetch current GPS location
  Future<LocationModel> getCurrentGpsLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } on LocationServiceDisabledException catch (e) {
      throw LocationPermissionFailure(e.message);
    } on LocationPermissionException catch (e) {
      throw LocationPermissionFailure(e.message);
    } catch (e) {
      throw LocationPermissionFailure(e.toString());
    }
  }
}
