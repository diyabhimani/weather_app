import 'dart:async';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;
import '../../core/errors/exceptions.dart';
import '../models/location_model.dart';

class LocationService {
  /// Queries device GPS position and returns a LocationModel
  Future<LocationModel> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionException(
          'Location permission denied. Please allow location access or search for a city.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Location permission permanently denied. Please enable it in device settings or search for a city.',
      );
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LocationModel(
        name: 'Current Location',
        country: 'GPS Detected',
        latitude: position.latitude,
        longitude: position.longitude,
        isCurrentLocation: true,
      );
    } on TimeoutException {
      throw const LocationPermissionException(
        'Location request timed out. Please try again or search by city name.',
      );
    } catch (e) {
      throw LocationPermissionException('Could not determine current location: $e');
    }
  }
}
