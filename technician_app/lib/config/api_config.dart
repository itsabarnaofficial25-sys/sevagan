class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://159.65.144.107:3000/api',
  );

  // Auth endpoints
  static const String otpRequest = '/auth/otp';
  static const String otpVerify = '/auth/verify';
  static const String updateFcmToken = '/auth/fcm-token';

  // Technician endpoints
  static const String technicianProfile = '/technicians/profile';
  static const String updateProfile = '/technicians/profile';
  static const String uploadDocument = '/technicians/upload-document';
  static const String toggleOnline = '/technicians/toggle-online';
  static const String updateLocation = '/technicians/update-location';
  static const String earnings = '/technicians/earnings';

  // Job endpoints
  static const String nearbyJobs = '/jobs/nearby';
  static const String acceptJob = '/jobs';
  static const String startJob = '/jobs';
  static const String completeJob = '/jobs';
  static const String activeJobs = '/jobs/active';
}
