import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Weather service is temporarily unavailable.']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Too many requests. Please wait a moment.']);
}

class LocationNotFoundFailure extends Failure {
  const LocationNotFoundFailure([super.message = 'Location not found. Please try another search.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No offline data available.']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([super.message = 'Location permission is required for GPS weather.']);
}

class GenericFailure extends Failure {
  const GenericFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
