# Anglara Weather App

A production-grade, beautifully crafted Flutter Weather Application created for the **Anglara Digital Solutions LLP Flutter Intern Interview Task**.

Built with **Flutter**, **BLoC/Cubit** state management, **Clean Layered Architecture**, zero-key global weather data via the **Open-Meteo API**, offline local caching, and device GPS support.

---

## Features

### 1. Branded Splash Screen
- Smooth, creative launch experience featuring a glowing, animated weather icon and branding typography.
- Smooth `PageRouteBuilder` fade-and-scale transition into the main weather screen after pre-fetching cached weather.

### 2. Rich Weather Dashboard
- **Dynamic Theming & Gradients**: Automatically shifts color gradients based on time of day (day vs night) and atmospheric condition (Sunny, Clear Night, Cloudy, Rain, Thunderstorm, Snow, Fog).
- **Hero Metrics**: Large temperature display, weather condition description, feels-like temperature, and daily High/Low.
- **Hourly Forecast (24H)**: Horizontal sliding cards displaying temperature and condition icons for each upcoming hour.
- **Detailed Atmospheric Grid**: Translucent glassmorphism cards for Wind Speed, Humidity, Surface Pressure, Precipitation, Feels Like, and Day/Night cycle.
- **7-Day Daily Forecast**: Clean weekly cards featuring high/low temperature comparison bars and weather icons.

### 3. Manual Refresh & Error Resilience
- **Dual Refresh Actions**: Both intuitive **pull-to-refresh** (`RefreshIndicator`) and an **AppBar refresh button** with rotation animation.
- **Data Retention on Failure**: If a manual refresh fails (e.g. loss of network connectivity, timeout, or rate limiting), **the previous weather data remains completely visible on screen**, and a floating `SnackBar` notifies the user with a convenient "Retry" action.

### 4. Search & Location Management
- **Global City Search**: Live debounced search querying the Open-Meteo Geocoding API with city, country, and administrative region details.
- **Quick-Pick Chips**: Instant selection for major cities (London, New York, Tokyo, Paris, Sydney, Mumbai).
- **Device GPS Location (Bonus)**: 1-tap "Current Location" button leveraging device GPS via `geolocator` with runtime permission checks.

### 5. Local Caching & Offline Mode (Bonus)
- Persists the last successful weather response and active location to device storage (`SharedPreferences`).
- On app launch, cached weather data is immediately displayed without waiting for network requests.
- When operating offline, an **Offline Mode Banner** clearly communicates the cached timestamp and gives a 1-tap retry button.

---

## Clean Architecture & Folder Structure

The application strictly follows Clean Architecture and Separation of Concerns:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart          # Open-Meteo API endpoints & timeouts
│   │   └── app_colors.dart             # Dynamic weather gradients & palettes
│   ├── errors/
│   │   ├── exceptions.dart             # Typed data-layer exceptions
│   │   └── failures.dart               # Domain-level failure representations
│   ├── theme/
│   │   └── app_theme.dart              # Modern dark theme and typography
│   └── utils/
│       ├── date_time_utils.dart        # Formats times, dates, and days
│       └── weather_code_mapper.dart    # WMO code to descriptions, icons, and gradients
├── data/
│   ├── models/
│   │   ├── location_model.dart         # Location data and JSON serialization
│   │   └── weather_data.dart           # Current, Hourly, Daily models & caching JSON support
│   ├── services/
│   │   ├── weather_api_service.dart    # HTTP client for Geocoding & Forecast APIs
│   │   ├── cache_service.dart          # SharedPreferences caching service
│   │   └── location_service.dart       # Device GPS service with permission handling
│   └── repositories/
│       └── weather_repository.dart     # Single source of truth coordinating API, cache, & GPS
├── logic/
│   └── cubit/
│       ├── weather_cubit.dart          # State management & business logic
│       └── weather_state.dart          # Initial, Loading, Loaded (with refresh state), Error
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart          # Animated branded splash screen
│   │   ├── weather_screen.dart         # Main weather dashboard
│   │   └── search_city_sheet.dart      # City search modal with autocomplete
│   └── widgets/
│       ├── current_weather_display.dart# Main hero weather widget
│       ├── weather_details_grid.dart   # Atmospheric metrics grid
│       ├── hourly_forecast_list.dart   # 24-hour horizontal forecast cards
│       ├── daily_forecast_list.dart    # 7-day forecast cards
│       ├── weather_icon_widget.dart    # Condition-based icon with glow
│       ├── animated_refresh_button.dart# Appbar refresh button with spin animation
│       ├── offline_banner.dart         # Indicator for cached data mode
│       ├── error_state_widget.dart     # Full-screen error state with retry
│       └── weather_loading_shimmer.dart# Shimmer skeleton loader
└── main.dart                           # Entrypoint with Dependency Injection
```

---

## State Management (`flutter_bloc`)

UI states are strictly separated and managed using `WeatherCubit`:
- **`WeatherInitial`**: Prior to initial data load.
- **`WeatherLoading`**: Full-screen skeleton when fetching without any existing data.
- **`WeatherLoaded`**:
  - `weather`: Active `WeatherData`
  - `isRefreshing`: `bool` indicating an active pull-to-refresh or appbar refresh
  - `refreshError`: `String?` when refresh fails without dropping the visible weather data
  - `isFromCache`: `bool` indicating whether the active weather was loaded from local offline storage
- **`WeatherError`**: Rendered only when initial load fails and there is no cached weather available.

---

## Running the Project

### Prerequisites
- Flutter SDK 3.13.0+ / 3.47.0+
- Dart 3.13.0+

### Installation & Run
```bash
# 1. Clone the repository
cd weather_app

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Running Tests
Execute the complete unit and widget test suite:
```bash
flutter test
```
All 16 unit and widget tests will run and pass:
- LocationModel JSON serialization & formatting
- WeatherData API parsing and caching round-trip
- WeatherRepository data fetching, offline caching, and error mapping
- WeatherCubit states (including refresh failure data retention)
- SplashScreen branding and transition
- WeatherScreen component rendering and error notification SnackBar
