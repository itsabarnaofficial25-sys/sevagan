import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;

  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  Future<bool> requestPermission() async {
    // Location not supported on web
    if (kIsWeb) {
      return false;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getAddressFromCoordinates();
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void setManualLocation(double latitude, double longitude) {
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude, String address) {
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    _currentAddress = address;
    notifyListeners();
  }
}
