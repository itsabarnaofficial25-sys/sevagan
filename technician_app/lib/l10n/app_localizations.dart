import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Professional technician services at your doorstep'**
  String get splashTagline;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sevagan Technician'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join as a service partner'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password (min 6 characters)'**
  String get createPassword;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInContinue;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneLabel;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get enterOtp;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get otpHint;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhone;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service\nand Privacy Policy'**
  String get termsText;

  /// No description provided for @technicianPartner.
  ///
  /// In en, this message translates to:
  /// **'Technician Partner App'**
  String get technicianPartner;

  /// No description provided for @phoneEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get phoneEmptyError;

  /// No description provided for @validPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get validPhoneError;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully to'**
  String get otpSentSuccess;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get otpSendFailed;

  /// No description provided for @otpEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get otpEmptyError;

  /// No description provided for @validOtpError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get validOtpError;

  /// No description provided for @invalidOtpError.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtpError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sevagan Technician'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Service at your doorstep'**
  String get welcomeSubtitle;

  /// No description provided for @technician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technician;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @doYouWantToExit.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the application?'**
  String get doYouWantToExit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeTitle;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @newJobRequests.
  ///
  /// In en, this message translates to:
  /// **'New Job Requests'**
  String get newJobRequests;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @checkingProfile.
  ///
  /// In en, this message translates to:
  /// **'Checking your profile...'**
  String get checkingProfile;

  /// No description provided for @profileCheckError.
  ///
  /// In en, this message translates to:
  /// **'Failed to check profile'**
  String get profileCheckError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @activeJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobsTitle;

  /// No description provided for @noActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'No Active Jobs'**
  String get noActiveJobs;

  /// No description provided for @noActiveJobsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active jobs at the moment'**
  String get noActiveJobsSubtitle;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @serviceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceTypeLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @navigateButton.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Customer'**
  String get navigateButton;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @mapsLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch maps'**
  String get mapsLaunchError;

  /// No description provided for @otpSentToMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP sent to +91 {phoneNumber}'**
  String otpSentToMessage(Object phoneNumber);

  /// No description provided for @otpInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit verification code'**
  String get otpInstruction;

  /// No description provided for @myEarnings.
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get myEarnings;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @earningsSummary.
  ///
  /// In en, this message translates to:
  /// **'Earnings Summary'**
  String get earningsSummary;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @platformCommission.
  ///
  /// In en, this message translates to:
  /// **'Platform Commission'**
  String get platformCommission;

  /// No description provided for @netEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get netEarnings;

  /// No description provided for @viewAllReviews.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL REVIEWS'**
  String get viewAllReviews;

  /// No description provided for @completedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get completedJobs;

  /// No description provided for @noCompletedJobs.
  ///
  /// In en, this message translates to:
  /// **'No completed jobs yet'**
  String get noCompletedJobs;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @serviceCharge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get serviceCharge;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @navigateToLocation.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Location'**
  String get navigateToLocation;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJob;

  /// No description provided for @completeJob.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get completeJob;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @noNewJobRequests.
  ///
  /// In en, this message translates to:
  /// **'No New Job Requests'**
  String get noNewJobRequests;

  /// No description provided for @noPendingJobRequests.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any pending job requests'**
  String get noPendingJobRequests;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @jobTracking.
  ///
  /// In en, this message translates to:
  /// **'Job Tracking'**
  String get jobTracking;

  /// No description provided for @jobError.
  ///
  /// In en, this message translates to:
  /// **'Job Error'**
  String get jobError;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call Customer'**
  String get callCustomer;

  /// No description provided for @issueLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issueLabel;

  /// No description provided for @navigateToCustomerLocation.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Customer Location'**
  String get navigateToCustomerLocation;

  /// No description provided for @enterOtpFromCustomer.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP from Customer to Start Job'**
  String get enterOtpFromCustomer;

  /// No description provided for @otpHintShort.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit OTP'**
  String get otpHintShort;

  /// No description provided for @jobStarted.
  ///
  /// In en, this message translates to:
  /// **'Job Started!'**
  String get jobStarted;

  /// No description provided for @enterFinalPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter final price'**
  String get enterFinalPrice;

  /// No description provided for @jobCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job Completed!'**
  String get jobCompleted;

  /// No description provided for @jobCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Job Completed Successfully'**
  String get jobCompletedSuccessfully;

  /// No description provided for @jobInProgress.
  ///
  /// In en, this message translates to:
  /// **'Job in Progress'**
  String get jobInProgress;

  /// No description provided for @enterFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Final Amount'**
  String get enterFinalAmount;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @profileWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Please complete your profile to start receiving job requests.'**
  String get profileWelcomeMessage;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience *'**
  String get yearsOfExperience;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid number'**
  String get enterValidNumber;

  /// No description provided for @serviceRadius.
  ///
  /// In en, this message translates to:
  /// **'Service Radius (km) *'**
  String get serviceRadius;

  /// No description provided for @selectYourSkills.
  ///
  /// In en, this message translates to:
  /// **'Select Your Skills *'**
  String get selectYourSkills;

  /// No description provided for @selectAtLeastOneSkill.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one skill'**
  String get selectAtLeastOneSkill;

  /// No description provided for @submitProfile.
  ///
  /// In en, this message translates to:
  /// **'Submit Profile'**
  String get submitProfile;

  /// No description provided for @profileNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Your profile will be reviewed by admin before you can start receiving jobs.'**
  String get profileNote;

  /// No description provided for @profileCreatedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Profile created! Waiting for admin approval.'**
  String get profileCreatedWaiting;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get noReviewsYet;

  /// No description provided for @noReviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When customers review your service, it will appear here'**
  String get noReviewsSubtitle;

  /// No description provided for @anonymousCustomer.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Customer'**
  String get anonymousCustomer;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get monthsAgo;

  /// No description provided for @rejectJob.
  ///
  /// In en, this message translates to:
  /// **'Reject Job'**
  String get rejectJob;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @rejectJobConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this job?'**
  String get rejectJobConfirm;

  /// No description provided for @jobRejected.
  ///
  /// In en, this message translates to:
  /// **'Job rejected successfully'**
  String get jobRejected;

  /// No description provided for @rejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject job'**
  String get rejectFailed;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @jobNotFound.
  ///
  /// In en, this message translates to:
  /// **'Job not found'**
  String get jobNotFound;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccess;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @loadingServices.
  ///
  /// In en, this message translates to:
  /// **'Loading services...'**
  String get loadingServices;

  /// No description provided for @oopsError.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsError;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServices;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Please check back later'**
  String get checkBackLater;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @whereNeedService.
  ///
  /// In en, this message translates to:
  /// **'Where do you need service?'**
  String get whereNeedService;

  /// No description provided for @serviceLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Location'**
  String get serviceLocationLabel;

  /// No description provided for @selectYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Select your location'**
  String get selectYourLocation;

  /// No description provided for @myServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'My Service Requests'**
  String get myServiceRequests;

  /// No description provided for @viewAllBookings.
  ///
  /// In en, this message translates to:
  /// **'View all bookings'**
  String get viewAllBookings;

  /// No description provided for @selectServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectServiceLabel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @fullNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get fullNameMissing;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordEmpty;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @acceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service'**
  String get acceptTermsError;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Mobile number may already exist.'**
  String get registrationFailed;

  /// No description provided for @technicianHome.
  ///
  /// In en, this message translates to:
  /// **'Technician Home'**
  String get technicianHome;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ta': return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
