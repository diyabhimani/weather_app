/// Base exception class for data-layer errors
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Weather service is temporarily unavailable.']);
}

class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Request limit exceeded. Please try again shortly.']);
}

class CityNotFoundException extends AppException {
  const CityNotFoundException([super.message = 'City not found. Please verify the spelling.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Failed to load local cached weather data.']);
}

class LocationPermissionException extends AppException {
  const LocationPermissionException([super.message = 'Location permission was denied.']);
}

class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException([super.message = 'Location services are disabled on your device.']);
}
