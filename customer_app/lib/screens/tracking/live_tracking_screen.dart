// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String jobId;
  final double customerLat;
  final double customerLng;
  final String customerAddress;

  const LiveTrackingScreen({
    super.key,
    required this.jobId,
    required this.customerLat,
    required this.customerLng,
    required this.customerAddress,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _technicianLocation;
  Timer? _locationTimer;
  bool _isMapReady = false;
  bool _hasLocation = false;
  String _jobStatus = '';
  String _technicianName = 'Technician';
  double _technicianRating = 0;
  double? _distance;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Set<Marker> _markers = {};
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeCustomerMarker();
    _fetchTechnicianLocation();
    _startLocationPolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeCustomerMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: LatLng(widget.customerLat, widget.customerLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: widget.customerAddress,
        ),
      ),
    );
  }

  void _startLocationPolling() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchTechnicianLocation();
    });
  }

  Future<void> _fetchTechnicianLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/jobs/${widget.jobId}/technician-location',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final hasLoc = data['hasLocation'] == true;
        final status = data['status'] as String? ?? '';
        final name = data['technicianName'] as String? ?? 'Technician';
        final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;

        if (!mounted) return;

        setState(() {
          _jobStatus = status;
          _technicianName = name;
          _technicianRating = rating;
          _hasLocation = hasLoc;

          if (hasLoc) {
            final lat = (data['latitude'] as num).toDouble();
            final lng = (data['longitude'] as num).toDouble();
            _technicianLocation = LatLng(lat, lng);

            _markers.removeWhere((m) => m.markerId.value == 'technician');
            _markers.add(
              Marker(
                markerId: const MarkerId('technician'),
                position: _technicianLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: name,
                  snippet: _getStatusLabel(status),
                ),
              ),
            );

            _distance = Geolocator.distanceBetween(
              lat,
              lng,
              widget.customerLat,
              widget.customerLng,
            );
          }
        });

        if (hasLoc && _isMapReady) {
          _updateCamera();
        }
      }
    } catch (e) {
      debugPrint('LiveTracking: fetch failed – $e');
    }
  }

  void _updateCamera() {
    if (_mapController == null || _technicianLocation == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _technicianLocation!.latitude < widget.customerLat
            ? _technicianLocation!.latitude
            : widget.customerLat,
        _technicianLocation!.longitude < widget.customerLng
            ? _technicianLocation!.longitude
            : widget.customerLng,
      ),
      northeast: LatLng(
        _technicianLocation!.latitude > widget.customerLat
            ? _technicianLocation!.latitude
            : widget.customerLat,
        _technicianLocation!.longitude > widget.customerLng
            ? _technicianLocation!.longitude
            : widget.customerLng,
      ),
    );
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  String _getStatusLabel(String status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'TECHNICIAN_ASSIGNED':
        return l10n?.onTheWay ?? 'On the way';
      case 'JOB_STARTED':
        return l10n?.workingAtLocation ?? 'Working at your location';
      default:
        return status;
    }
  }

  String _formatDistance(double meters) {
    final l10n = AppLocalizations.of(context);
    if (meters < 1000) {
      return l10n?.metersAway(meters.toInt()) ?? '${meters.toInt()} m away';
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n?.kmAway(km) ?? '$km km away';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveTracking),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTechnicianLocation,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.customerLat, widget.customerLng),
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() => _isMapReady = true);
              if (_hasLocation) _updateCamera();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          if (!_hasLocation)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            l10n.waitingForLocation(_technicianName),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.locationUpdateMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF1976D2),
                        child: Icon(Icons.engineering,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _technicianName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  _technicianRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_distance != null)
                                  Text(
                                    _formatDistance(_distance!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (_, __) => Opacity(
                          opacity: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _hasLocation
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _hasLocation
                                        ? Colors.green
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _hasLocation ? l10n.live : l10n.waiting,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _hasLocation
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_jobStatus.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(_jobStatus),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}