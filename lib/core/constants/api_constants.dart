class ApiConstants {
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration timeout = Duration(seconds: 12);

  // Default initial location if no cache and no GPS (London)
  static const String defaultCityName = 'London';
  static const String defaultCountry = 'United Kingdom';
  static const double defaultLatitude = 51.50853;
  static const double defaultLongitude = -0.12574;
}
