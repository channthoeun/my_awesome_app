import 'package:geolocator/geolocator.dart';

/// A data model to hold combined IP and GPS location information.
class LocationData {
  final String ipAddress;
  final String? city;
  final String? country;
  final String? isp;
  final Position? gpsPosition; // The object from the 'geolocator' package

  LocationData({
    required this.ipAddress,
    this.city,
    this.country,
    this.isp,
    this.gpsPosition,
  });

  /// A factory constructor to create a [LocationData] instance
  /// from the JSON response of the ip-api.com service.
  factory LocationData.fromIpApiJson(Map<String, dynamic> json) {
    return LocationData(
      ipAddress: json['query'] ?? 'Unknown',
      city: json['city'],
      country: json['country'],
      isp: json['isp'],
      // Note: gpsPosition is not available from this API, so it's null by default.
    );
  }

  /// Creates a new [LocationData] instance with updated values.
  ///
  /// This is an implementation of the common 'copyWith' pattern, which is
  /// useful for working with immutable objects. It allows you to create a
  /// 'modified copy' of an object without changing the original.
  /// If a parameter is not provided, the value from the current instance is used.
  LocationData copyWith({
    String? ipAddress,
    String? city,
    String? country,
    String? isp,
    Position? gpsPosition,
  }) {
    return LocationData(
      ipAddress: ipAddress ?? this.ipAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      isp: isp ?? this.isp,
      gpsPosition: gpsPosition ?? this.gpsPosition,
    );
  }

  /// Provides a readable string representation of the location data,
  /// useful for logging.
  @override
  String toString() {
    String gpsInfo = gpsPosition != null
        ? 'Lat: ${gpsPosition!.latitude.toStringAsFixed(4)}, Lon: ${gpsPosition!.longitude.toStringAsFixed(4)}'
        : 'GPS: Not available';

    return 'IP: $ipAddress (City: ${city ?? 'N/A'}, Country: ${country ?? 'N/A'}) - ISP: ${isp ?? 'N/A'} - $gpsInfo';
  }
}