import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Search cities via Open-Meteo Geocoding API
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.parse(
      '${ApiConstants.geocodingBaseUrl}?name=${Uri.encodeComponent(trimmedQuery)}&count=6&language=en&format=json',
    );

    try {
      final response = await _client.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 429) {
        throw const RateLimitException();
      } else {
        throw ServerException('Geocoding server error: ${response.statusCode}');
      }
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Connection timed out. Please try again.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Fetch weather forecast via Open-Meteo Forecast API
  Future<WeatherData> fetchWeather({
    required LocationModel location,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.forecastBaseUrl}?'
      'latitude=${location.latitude}&'
      'longitude=${location.longitude}&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,surface_pressure&'
      'hourly=temperature_2m,weather_code&'
      'daily=weather_code,temperature_2m_max,temperature_2m_min&'
      'timezone=auto&'
      'forecast_days=7',
    );

    try {
      final response = await _client.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherData.fromApiResponse(
          json: data,
          location: location,
        );
      } else if (response.statusCode == 429) {
        throw const RateLimitException();
      } else {
        throw ServerException('Forecast server error: ${response.statusCode}');
      }
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Connection timed out. Please try again.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  void dispose() {
    _client.close();
  }
}
