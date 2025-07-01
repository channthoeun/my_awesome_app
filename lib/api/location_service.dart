import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for defaultTargetPlatform
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:my_awesome_app/models/location_data_model.dart';

/// A service dedicated to fetching device and network location information.
class LocationService {
  final _log = Logger('LocationService');
  final _ipApiUrl = Uri.parse('http://ip-api.com/json');

  /// Fetches both IP-based and GPS-based location data and combines them.
  ///
  /// This is the main public method to be called from other parts of the app.
  /// It gracefully handles failures in either IP or GPS fetching.
  Future<LocationData> getCurrentLocationData() async {
    _log.info('Fetching current location data...');

    // 1. Get IP-based Geolocation first. This doesn't require user permission.
    LocationData locationData;
    try {
      final response = await http.get(_ipApiUrl);
      if (response.statusCode == 200) {
        final ipJson = json.decode(response.body);
        locationData = LocationData.fromIpApiJson(ipJson);
        _log.info('IP Geolocation successful: ${locationData.ipAddress}');
      } else {
        throw Exception('Failed to get IP data. Status: ${response.statusCode}');
      }
    } catch (e, s) {
      _log.warning('Could not get IP geolocation data.', e, s);
      // Create a fallback object if the IP API fails, so the app can continue.
      locationData = LocationData(ipAddress: 'Unknown');
    }

    // 2. Get GPS Geolocation. This requires user permission.
    Position? gpsPosition;
    try {
      gpsPosition = await _getGpsPosition();
      if (gpsPosition != null) {
        _log.info('GPS Position successful: Lat ${gpsPosition.latitude}, Lon ${gpsPosition.longitude}');
      }
    } catch (e) {
      // It's okay if this fails (e.g., user denies permission). We log it and move on.
      _log.warning('Could not get GPS position: $e');
    }

    // 3. Combine the data using the `copyWith` method to add GPS data to our object.
    return locationData.copyWith(gpsPosition: gpsPosition);
  }

  /// Private helper method to handle the logic of checking permissions
  /// and getting the GPS position from the device using the modern API.
  Future<Position?> _getGpsPosition() async {
    // Step A: Check if location services are enabled on the device.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log.warning('Location services are disabled on the device.');
      return null;
    }

    // Step B: Check and request location permissions.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _log.info('Location permission is denied, requesting permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _log.warning('User denied location permission request.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log.severe('Location permissions are permanently denied by the user.');
      return null;
    }

    // Step C: When permissions are granted, proceed to get the location.
    _log.info('Location permission granted, fetching current position.');

    // --- NEW, UPDATED LOGIC TO AVOID DEPRECATION ---

    // 1. Define platform-specific location settings.
    final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Optional: receive updates only when moved by 100 meters
        // You can also add settings for when the app is in the background
        // foregroundNotificationConfig: const ForegroundNotificationConfig(
        //   notificationText: "App is using your location",
        //   notificationTitle: "Location Running",
        //   enableWakeLock: true,
        // )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // pauseAutomatically: true, // Let iOS manage when to pause location updates
      );
    } else {
      // Default settings for other platforms like Web.
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    // 2. Use `getPositionStream` with the settings and take the first event.
    // This is the modern equivalent of `getCurrentPosition`.
    try {
      // We add a timeout to prevent the app from waiting indefinitely if
      // the GPS signal is poor.
      return await Geolocator.getPositionStream(locationSettings: locationSettings)
          .timeout(const Duration(seconds: 15)) // Wait for 15 seconds max
          .first;
    } on TimeoutException {
      _log.severe('Getting GPS location timed out.');
      return null;
    } catch (e, s) {
      _log.severe('Could not get position stream.', e, s);
      return null;
    }
  }
}