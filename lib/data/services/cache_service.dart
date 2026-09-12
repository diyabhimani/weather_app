import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';

class CacheService {
  CacheService({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;

  static const String _keyWeatherData = 'cached_weather_data';
  static const String _keyLastLocation = 'last_location';

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Cache the latest successful weather data
  Future<bool> saveWeatherData(WeatherData data) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = json.encode(data.toJson());
      await prefs.setString(_keyWeatherData, jsonString);
      await saveLastLocation(data.location);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve the cached weather data
  Future<WeatherData?> getCachedWeatherData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyWeatherData);
      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return WeatherData.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  /// Save last active location
  Future<bool> saveLastLocation(LocationModel location) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = json.encode(location.toJson());
      return await prefs.setString(_keyLastLocation, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Retrieve last active location
  Future<LocationModel?> getLastLocation() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyLastLocation);
      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LocationModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyWeatherData);
    await prefs.remove(_keyLastLocation);
  }
}
