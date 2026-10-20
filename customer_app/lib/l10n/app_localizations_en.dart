// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sevagan';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInContinue => 'Sign in to continue';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get termsText => 'By signing in, you agree to our Terms of Service and Privacy Policy';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get otpHint => 'Enter 6-digit OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get changePhone => 'Change Phone';

  @override
  String get otpSentSuccess => 'OTP sent successfully to';

  @override
  String get otpSendFailed => 'Failed to send OTP. Please try again.';

  @override
  String get otpEmptyError => 'Please enter OTP';

  @override
  String get validOtpError => 'Please enter a valid 6-digit OTP';

  @override
  String get invalidOtpError => 'Invalid OTP. Please try again.';

  @override
  String get validPhoneError => 'Please enter a valid 10-digit mobile number';

  @override
  String resendOtpIn(Object seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get continueAsCustomer => 'Continue as Customer';

  @override
  String get selectService => 'Select Service';

  @override
  String get serviceLocation => 'Service Location';

  @override
  String get requestService => 'Request Service';

  @override
  String get myRequests => 'My Requests';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get rateService => 'Rate Service';

  @override
  String get payment => 'Payment';

  @override
  String get cashPayment => 'Cash Payment';

  @override
  String get upiPayment => 'UPI Payment';

  @override
  String get welcome => 'Welcome!';

  @override
  String get welcomeSubtitle => 'On-demand local services at your doorstep';

  @override
  String get hello => 'Hello,';

  @override
  String get whereNeedService => 'Where do you need service?';

  @override
  String get serviceLocationLabel => 'Service Location';

  @override
  String get selectYourLocation => 'Select your location';

  @override
  String get myServiceRequests => 'My Service Requests';

  @override
  String get viewAllBookings => 'View all your bookings';

  @override
  String get selectServiceLabel => 'Select Service';

  @override
  String get viewAll => 'View All';

  @override
  String get loadingServices => 'Loading services...';

  @override
  String get oopsError => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noServices => 'No Services Available';

  @override
  String get checkBackLater => 'Please check back later for available services';

  @override
  String get refresh => 'Refresh';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get exitApp => 'Exit App';

  @override
  String get doYouWantToExit => 'Do you want to exit the application?';

  @override
  String get exit => 'Exit';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get enterMobileNumber => 'Please enter mobile number';

  @override
  String get describeIssue => 'Describe your issue';

  @override
  String get issueHint => 'e.g., Tap is leaking in kitchen, fan not working...';

  @override
  String get scheduleForLater => 'Schedule for later';

  @override
  String get selectDateTime => 'Select Date & Time';

  @override
  String get preferredServiceTime => 'Preferred service time';

  @override
  String get change => 'Change';

  @override
  String get estimatedBasePrice => 'Estimated Base Price';

  @override
  String get finalPriceNote => '* Final price may vary based on work';

  @override
  String get requestTechnician => 'Request Technician';

  @override
  String get professionalService => 'Professional service at your doorstep';

  @override
  String get requestCreated => 'Request created successfully!';

  @override
  String get error => 'Error';

  @override
  String get timeAtLeastOneHour => 'Please select a time at least 1 hour from now';

  @override
  String get jobStatus => 'Job Status';

  @override
  String get jobNotFound => 'Job not found';

  @override
  String get findingTechnician => 'Finding Technician';

  @override
  String get technicianAssigned => 'Technician Assigned';

  @override
  String get workInProgress => 'Work in Progress';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get completed => 'Completed';

  @override
  String get payNow => 'PAY NOW';

  @override
  String get shareOtpWithTechnician => 'Share OTP with technician';

  @override
  String get technician => 'Technician';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get unknown => 'Unknown';

  @override
  String get browseServices => 'Browse Services';

  @override
  String get viewDetails => 'View Details';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get daysAgo => 'days ago';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get paymentUnknownError => 'Unknown error';

  @override
  String get externalWalletSelected => 'External wallet selected';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get paymentSuccessMessage => 'Your payment has been processed successfully.';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get service => 'Service';

  @override
  String get backToHome => 'BACK TO HOME';

  @override
  String get completeYourProfile => 'Complete Your Profile';

  @override
  String get profileSetupMessage => 'Complete your profile to get started';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressRequired => 'Please enter your address';

  @override
  String get continueText => 'Continue';

  @override
  String get profileCreateFailed => 'Failed to create profile';

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String get onTheWay => 'On the way';

  @override
  String get workingAtLocation => 'Working at your location';

  @override
  String waitingForLocation(Object name) {
    return 'Waiting for $name to share location…';
  }

  @override
  String get locationUpdateMessage => 'Location updates every 10 seconds';

  @override
  String get live => 'Live';

  @override
  String get waiting => 'Waiting';

  @override
  String metersAway(Object meters) {
    return '$meters m away';
  }

  @override
  String kmAway(Object km) {
    return '$km km away';
  }

  @override
  String get profileCreatedSuccessfully => 'Profile created successfully!';

  @override
  String get checkingProfile => 'Checking profile...';

  @override
  String get profileCheckError => 'Failed to check profile';

  @override
  String get retry => 'Retry';
}
