import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Periodically sends technician GPS position to the backend
/// while active on a job. Call [start] when a job becomes active,
/// [stop] when the job is completed or cancelled.
class LocationPushService {
  static final LocationPushService _instance = LocationPushService._internal();
  factory LocationPushService() => _instance;
  LocationPushService._internal();

  Timer? _timer;
  final Dio _dio = Dio();
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Starts pushing location every [intervalSeconds] seconds (default 20).
  Future<void> start({int intervalSeconds = 20}) async {
    if (_isRunning) return;

    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      debugPrint('LocationPushService: location permission denied');
      return;
    }

    _isRunning = true;
    // Push immediately then on interval
    await _pushLocation();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      await _pushLocation();
    });
    debugPrint('LocationPushService: started (every ${intervalSeconds}s)');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('LocationPushService: stopped');
  }

 Future<void> _pushLocation() async {
  try {
    // ✅ FIX - Use this syntax for geolocator ^10.1.0
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    await _dio.post(
      '${ApiConfig.baseUrl}/technicians/update-location',
      data: {'latitude': position.latitude, 'longitude': position.longitude},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    debugPrint(
      'LocationPushService: pushed (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})',
    );
  } catch (e) {
    debugPrint('LocationPushService: push failed – $e');
  }
}

}
