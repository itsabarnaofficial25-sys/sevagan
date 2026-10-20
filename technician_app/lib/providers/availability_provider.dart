import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class AvailabilityProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AvailabilityProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnline = prefs.getBool('isOnline') ?? false;
      debugPrint('📱 Loaded online status: $_isOnline');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading online status: $e');
    }
  }

  Future<void> toggleOnlineStatus(BuildContext context) async {
    final newStatus = !_isOnline;
    await setOnlineStatus(context, newStatus);
  }

  Future<void> setOnlineStatus(BuildContext context, bool isOnline) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Get token from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      debugPrint('📤 Toggle Online - Token: ${token?.substring(0, 20)}...');
      debugPrint('📤 URL: ${ApiConstants.baseUrl}/technicians/toggle-online');
      debugPrint('📤 Data: {"isOnline": $isOnline}');

      if (token == null) {
        _errorMessage = 'Please login again';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Token is null - User not authenticated');
        return;
      }

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/technicians/toggle-online',
        data: {'isOnline': isOnline},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isOnline = isOnline;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isOnline', isOnline);
        debugPrint('✅ Online status updated to: $isOnline');
      } else {
        _errorMessage = 'Failed to update status';
        debugPrint('❌ API returned error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error updating online status:');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Response: ${e.response?.data}');
      _errorMessage = 'Failed to update status. Please try again.';
    } catch (e) {
      debugPrint('❌ Error updating online status: $e');
      _errorMessage = 'Failed to update status. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}