import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository.dart';

class SearchCitySheet extends StatefulWidget {
  const SearchCitySheet({
    super.key,
    required this.repository,
    required this.onLocationSelected,
    required this.onGpsSelected,
  });

  final WeatherRepository repository;
  final ValueChanged<LocationModel> onLocationSelected;
  final VoidCallback onGpsSelected;

  @override
  State<SearchCitySheet> createState() => _SearchCitySheetState();
}

class _SearchCitySheetState extends State<SearchCitySheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<LocationModel> _searchResults = [];

  // Popular quick-pick locations
  static const List<LocationModel> _popularCities = [
    LocationModel(
      name: 'London',
      country: 'United Kingdom',
      latitude: 51.50853,
      longitude: -0.12574,
    ),
    LocationModel(
      name: 'New York',
      country: 'United States',
      latitude: 40.71427,
      longitude: -74.00597,
    ),
    LocationModel(
      name: 'Tokyo',
      country: 'Japan',
      latitude: 35.6895,
      longitude: 139.69171,
    ),
    LocationModel(
      name: 'Paris',
      country: 'France',
      latitude: 48.85341,
      longitude: 2.3488,
    ),
    LocationModel(
      name: 'Sydney',
      country: 'Australia',
      latitude: -33.86785,
      longitude: 151.20732,
    ),
    LocationModel(
      name: 'Mumbai',
      country: 'India',
      latitude: 19.07283,
      longitude: 72.88261,
    ),
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.repository.searchCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = 'No cities found matching "$query".';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Search error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & GPS shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onGpsSelected();
                },
                icon: const Icon(Icons.my_location_rounded, size: 16, color: AppColors.accent),
                label: const Text(
                  'GPS Location',
                  style: TextStyle(color: AppColors.accent, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search city or region (e.g. Paris)...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Popular cities chips
          const Text(
            'POPULAR CITIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularCities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(city.name),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onLocationSelected(city);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Search Results or Loading
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.06),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: item.country != null
                        ? Text(
                            item.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white38,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onLocationSelected(item);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
