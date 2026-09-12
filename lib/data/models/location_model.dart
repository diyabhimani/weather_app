import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  const LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.isCurrentLocation = false,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final bool isCurrentLocation;

  String get displayName {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  String get shortDisplayName {
    if (country != null && country!.isNotEmpty) {
      return '$name, $country';
    }
    return name;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String? ?? 'Unknown Location',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      isCurrentLocation: json['is_current_location'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'is_current_location': isCurrentLocation,
    };
  }

  LocationModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? admin1,
    bool? isCurrentLocation,
  }) {
    return LocationModel(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  @override
  List<Object?> get props => [
        name,
        latitude,
        longitude,
        country,
        admin1,
        isCurrentLocation,
      ];
}
