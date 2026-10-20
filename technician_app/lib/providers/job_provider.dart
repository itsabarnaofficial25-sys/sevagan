import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/models/job_model.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  final Set<String> _rejectedJobIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Job> get jobs =>
      _jobs.where((job) => !_rejectedJobIds.contains(job.id)).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Job> get pendingJobs =>
      _jobs.where((job) => job.status == JobStatus.pending).toList();

  List<Job> get activeJobs => _jobs
      .where(
        (job) => [JobStatus.accepted, JobStatus.started].contains(job.status),
      )
      .toList();

  List<Job> get completedJobs =>
      _jobs.where((job) => job.status == JobStatus.completed).toList();

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAvailableJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _errorMessage = 'No authentication token found';
        debugPrint('No token found, user not authenticated');
        return;
      }

      debugPrint('Fetching available jobs...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/available');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/available',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Jobs API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('Received ${data.length} jobs from API');

        _jobs = data.map((json) => _mapJobFromJson(json, isPending: true)).toList();
        debugPrint('Successfully mapped ${_jobs.length} jobs');
      } else {
        _errorMessage = 'Failed to fetch jobs: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _errorMessage = 'No authentication token found';
        debugPrint('No token found, user not authenticated');
        return;
      }

      debugPrint('Fetching my jobs...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/my-jobs');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/my-jobs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('My jobs API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('Received ${data.length} assigned jobs from API');

        _jobs = data.map((json) => _mapJobFromJson(json)).toList();
        debugPrint('Successfully mapped ${_jobs.length} assigned jobs');
      } else {
        _errorMessage = 'Failed to fetch my jobs: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching my jobs: $e');
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Job _mapJobFromJson(Map<String, dynamic> json, {bool isPending = false}) {
    return Job(
      id: json['id'].toString(),
      customerName: json['customer']?['name'] ?? 
                     json['customerName'] ?? 
                     'Unknown Customer',
      serviceType: json['serviceCategory']?['nameEn'] ?? 
                   json['serviceType'] ?? 
                   'Service',
      serviceTypeTa: json['serviceCategory']?['nameTa'] ?? 
                     json['serviceTypeTa'] ?? 
                     '',
      description: json['description'] ?? '',
      descriptionTa: json['descriptionTa'] ?? '',
      address: json['locationAddress'] ?? 
               json['address'] ?? 
               'Unknown Location',
      latitude: (json['locationLat'] ?? json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['locationLng'] ?? json['longitude'] ?? 0.0).toDouble(),
      price: (json['estimatedPrice'] ?? json['price'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      status: isPending 
          ? JobStatus.pending 
          : _parseJobStatus(json['status']),
      preferredDateTime: json['preferredDateTime'] != null
          ? DateTime.parse(json['preferredDateTime'])
          : null,
      proposedDateTime: json['proposedDateTime'] != null
          ? DateTime.parse(json['proposedDateTime'])
          : null,
      schedulingStatus: json['schedulingStatus'],
      schedulingNote: json['schedulingNote'],
    );
  }

  JobStatus _parseJobStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'TECHNICIAN_ASSIGNED':
      case 'ACCEPTED':
        return JobStatus.accepted;
      case 'JOB_STARTED':
      case 'STARTED':
        return JobStatus.started;
      case 'JOB_COMPLETED':
      case 'COMPLETED':
        return JobStatus.completed;
      case 'CANCELLED':
        return JobStatus.cancelled;
      default:
        return JobStatus.pending;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please check your internet.';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'Server not responding. Please try again.';
      } else if (error.response?.statusCode == 401) {
        return 'Session expired. Please login again.';
      } else if (error.response?.statusCode == 403) {
        return 'Access denied. Please contact support.';
      } else if (error.response?.statusCode == 404) {
        return 'Service not found.';
      } else if (error.response?.statusCode == 500) {
        return 'Server error. Please try again later.';
      }
      return 'Network error: ${error.message}';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<bool> acceptJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot accept job');
        return false;
      }

      debugPrint('Accepting job $jobId...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/accept');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/accept',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Accept job response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAvailableJobs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting job: $e');
      return false;
    }
  }

  Future<bool> rejectJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot reject job');
        return false;
      }

      debugPrint('Rejecting job $jobId...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/reject');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/reject',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Reject job response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _rejectedJobIds.add(jobId);
        await fetchAvailableJobs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rejecting job: $e');
      return false;
    }
  }

  Future<bool> startJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot start job');
        return false;
      }

      debugPrint('Starting job $jobId...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/start');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/start',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Start job response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyJobs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error starting job: $e');
      return false;
    }
  }

  Future<bool> completeJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot complete job');
        return false;
      }

      debugPrint('Completing job $jobId...');
      debugPrint('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/complete');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/complete',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Complete job response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyJobs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error completing job: $e');
      return false;
    }
  }

  void clearRejectedJobs() {
    _rejectedJobIds.clear();
    notifyListeners();
  }
}