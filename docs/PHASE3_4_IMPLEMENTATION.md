# Phase 3 & 4 Implementation Guide

## Phase 3: Final Steps (15 minutes)

### Step 1: Add Navigation Button to Active Jobs Screen

**File**: `technician_app/lib/screens/jobs/active_jobs_screen.dart`

**Add after line 176** (after the description section):

```dart
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _launchMaps(job.latitude, job.longitude),
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate to Customer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
```

**Add this method before the closing brace of the class** (around line 184):

```dart
  Future<void> _launchMaps(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
```

---

### Step 2: Add Backend Earnings Endpoint

**File**: `backend/src/technicians/technicians.controller.ts`

**Add after line 83** (after the toggleOnline method):

```typescript
    @Get('earnings')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Get technician earnings and wallet balance' })
    async getEarnings(@GetUser() user: User) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.techniciansService.getEarnings(technician.id);
    }
```

**File**: `backend/src/technicians/technicians.service.ts`

**Add after line 122** (after the updateWalletBalance method):

```typescript
    async getEarnings(technicianId: string) {
        const technician = await this.findById(technicianId);
        
        // Import ServiceRequest entity at the top if not already imported
        const { ServiceRequest } = await import('../jobs/entities/service-request.entity');
        const { getRepository } = await import('typeorm');
        
        // Get completed jobs with payments
        const serviceRequestRepo = getRepository(ServiceRequest);
        const completedJobs = await serviceRequestRepo
            .createQueryBuilder('request')
            .leftJoinAndSelect('request.serviceCategory', 'category')
            .leftJoinAndSelect('request.payment', 'payment')
            .where('request.technicianId = :technicianId', { technicianId })
            .andWhere('request.status = :status', { status: 'COMPLETED' })
            .andWhere('payment.id IS NOT NULL')
            .getMany();
        
        let totalEarnings = 0;
        let totalCommission = 0;
        
        const jobsWithEarnings = completedJobs.map(job => {
            const serviceCharge = job.finalPrice || 0;
            const commission = job.payment?.commissionAmount || 0;
            totalEarnings += serviceCharge;
            totalCommission += commission;
            
            return {
                id: job.id,
                serviceCategory: job.serviceCategory,
                description: job.description,
                finalPrice: serviceCharge,
                commission: commission,
            };
        });
        
        return {
            walletBalance: technician.walletBalance,
            totalEarnings,
            totalCommission,
            netEarnings: totalEarnings - totalCommission,
            completedJobs: jobsWithEarnings,
        };
    }
```

---

### Step 3: Update Technician Home Screen Navigation

**File**: `technician_app/lib/screens/home_screen.dart`

**Add import at the top**:

```dart
import 'earnings/earnings_screen.dart';
```

**Replace lines 100-102** (the TODO section):

```dart
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EarningsScreen(),
                      ),
                    );
                  },
```

---

## Phase 4: Google Maps SDK Integration

### Step 1: Add Google Maps Flutter Package

**File**: `customer_app/pubspec.yaml`

Check if `google_maps_flutter` is already added. If not, add:

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
```

Then run:
```bash
cd customer_app
flutter pub get
```

### Step 2: Configure Android Manifest

**File**: `customer_app/android/app/src/main/AndroidManifest.xml`

Add inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyARqBIDPunOueW3nzOKCzfEP-mBRs0jwCw"/>
```

### Step 3: Create Location Picker Screen

**File**: `customer_app/lib/screens/location/location_picker_screen.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = 'Fetching address...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      _getAddressFromLatLng(_selectedLocation!);
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = location;
      });
      _getAddressFromLatLng(location);
      _mapController?.animateCamera(CameraUpdate.newLatLng(location));
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              '${place.street}, ${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() => _selectedAddress = 'Unknown location');
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromLatLng(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedLocation == null
                ? null
                : () {
                    Navigator.pop(context, {
                      'latitude': _selectedLocation!.latitude,
                      'longitude': _selectedLocation!.longitude,
                      'address': _selectedAddress,
                    });
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_selectedLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTapped,
              markers: {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
```

### Step 4: Update Customer Home Screen to Use Location Picker

**File**: `customer_app/lib/screens/home/home_screen.dart`

**Add import**:

```dart
import '../location/location_picker_screen.dart';
```

**Update the edit button onPressed** (around line 134):

```dart
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPickerScreen(
                          initialLat: locationProvider.latitude,
                          initialLng: locationProvider.longitude,
                        ),
                      ),
                    );
                    if (result != null) {
                      locationProvider.updateLocation(
                        result['latitude'],
                        result['longitude'],
                        result['address'],
                      );
                    }
                  },
                ),
```

### Step 5: Add updateLocation Method to LocationProvider

**File**: `customer_app/lib/providers/location_provider.dart`

**Add this method**:

```dart
  void updateLocation(double lat, double lng, String address) {
    _latitude = lat;
    _longitude = lng;
    _currentAddress = address;
    notifyListeners();
  }
```

---

## Testing Checklist

### Phase 3
- [ ] Navigation button appears in active jobs
- [ ] Clicking navigation opens Google Maps
- [ ] Earnings screen accessible from home
- [ ] Wallet balance displays
- [ ] Completed jobs list shows

### Phase 4
- [ ] Location picker screen opens
- [ ] Map displays current location
- [ ] Tap to select location works
- [ ] Address updates when location changes
- [ ] Selected location saved and used

---

## Estimated Time

- **Phase 3 Manual Steps**: 15 minutes
- **Phase 4 Maps Integration**: 30-45 minutes
- **Total**: ~1 hour

---

**Next**: After completing these steps, Phase 3 will be 100% and Phase 4 will be 80% complete!
