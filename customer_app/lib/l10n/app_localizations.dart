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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sevagan'**
  String get appTitle;

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

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to our Terms of Service and Privacy Policy'**
  String get termsText;

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
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get otpHint;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change Phone'**
  String get changePhone;

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

  /// No description provided for @validPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get validPhoneError;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(Object seconds);

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @continueAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Continue as Customer'**
  String get continueAsCustomer;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service Location'**
  String get serviceLocation;

  /// No description provided for @requestService.
  ///
  /// In en, this message translates to:
  /// **'Request Service'**
  String get requestService;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @rateService.
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rateService;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get cashPayment;

  /// No description provided for @upiPayment.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get upiPayment;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-demand local services at your doorstep'**
  String get welcomeSubtitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
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
  /// **'View all your bookings'**
  String get viewAllBookings;

  /// No description provided for @selectServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectServiceLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

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

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No Services Available'**
  String get noServices;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Please check back later for available services'**
  String get checkBackLater;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get describeIssue;

  /// No description provided for @issueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Tap is leaking in kitchen, fan not working...'**
  String get issueHint;

  /// No description provided for @scheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get scheduleForLater;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// No description provided for @preferredServiceTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred service time'**
  String get preferredServiceTime;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @estimatedBasePrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated Base Price'**
  String get estimatedBasePrice;

  /// No description provided for @finalPriceNote.
  ///
  /// In en, this message translates to:
  /// **'* Final price may vary based on work'**
  String get finalPriceNote;

  /// No description provided for @requestTechnician.
  ///
  /// In en, this message translates to:
  /// **'Request Technician'**
  String get requestTechnician;

  /// No description provided for @professionalService.
  ///
  /// In en, this message translates to:
  /// **'Professional service at your doorstep'**
  String get professionalService;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created successfully!'**
  String get requestCreated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @timeAtLeastOneHour.
  ///
  /// In en, this message translates to:
  /// **'Please select a time at least 1 hour from now'**
  String get timeAtLeastOneHour;

  /// No description provided for @jobStatus.
  ///
  /// In en, this message translates to:
  /// **'Job Status'**
  String get jobStatus;

  /// No description provided for @jobNotFound.
  ///
  /// In en, this message translates to:
  /// **'Job not found'**
  String get jobNotFound;

  /// No description provided for @findingTechnician.
  ///
  /// In en, this message translates to:
  /// **'Finding Technician'**
  String get findingTechnician;

  /// No description provided for @technicianAssigned.
  ///
  /// In en, this message translates to:
  /// **'Technician Assigned'**
  String get technicianAssigned;

  /// No description provided for @workInProgress.
  ///
  /// In en, this message translates to:
  /// **'Work in Progress'**
  String get workInProgress;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentPending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'PAY NOW'**
  String get payNow;

  /// No description provided for @shareOtpWithTechnician.
  ///
  /// In en, this message translates to:
  /// **'Share OTP with technician'**
  String get shareOtpWithTechnician;

  /// No description provided for @technician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technician;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @browseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse Services'**
  String get browseServices;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @paymentUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get paymentUnknownError;

  /// No description provided for @externalWalletSelected.
  ///
  /// In en, this message translates to:
  /// **'External wallet selected'**
  String get externalWalletSelected;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully.'**
  String get paymentSuccessMessage;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get backToHome;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @profileSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get started'**
  String get profileSetupMessage;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address'**
  String get addressRequired;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @profileCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create profile'**
  String get profileCreateFailed;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @workingAtLocation.
  ///
  /// In en, this message translates to:
  /// **'Working at your location'**
  String get workingAtLocation;

  /// No description provided for @waitingForLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to share location…'**
  String waitingForLocation(Object name);

  /// No description provided for @locationUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Location updates every 10 seconds'**
  String get locationUpdateMessage;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @metersAway.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away'**
  String metersAway(Object meters);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(Object km);

  /// No description provided for @profileCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile created successfully!'**
  String get profileCreatedSuccessfully;

  /// No description provided for @checkingProfile.
  ///
  /// In en, this message translates to:
  /// **'Checking profile...'**
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
