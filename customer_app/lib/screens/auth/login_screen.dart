// ignore_for_file: unused_import, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final logoSize = screenWidth * 0.28;
    final titleFontSize = screenWidth * 0.08;
    final subtitleFontSize = screenWidth * 0.035;
    final labelFontSize = screenWidth * 0.038;
    final inputFontSize = screenWidth * 0.04;
    final buttonFontSize = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(logoSize),
                SizedBox(height: screenHeight * 0.03),
                _buildTitle(l10n, titleFontSize, subtitleFontSize),
                SizedBox(height: screenHeight * 0.05),
                _buildMobileNumberField(l10n, labelFontSize, inputFontSize),
                if (_otpSent) ...[
                  SizedBox(height: screenHeight * 0.02),
                  _buildOtpField(l10n, labelFontSize, inputFontSize),
                ],
                SizedBox(height: screenHeight * 0.03),
                _buildActionButton(l10n, buttonFontSize),
                SizedBox(height: screenHeight * 0.02),
                _buildTermsText(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double logoSize) {
    return Container(
      height: logoSize,
      width: logoSize,
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(logoSize / 2),
        child: Image.asset(
          'assets/sevagan.jpg',
          height: logoSize,
          width: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.home_repair_service,
                size: logoSize * 0.5,
                color: primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(
      AppLocalizations l10n, double titleSize, double subtitleSize) {
    return Column(
      children: [
        Text(
          l10n.welcomeBack,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          l10n.signInContinue,
          style: TextStyle(
            fontSize: subtitleSize,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileNumberField(
      AppLocalizations l10n, double labelSize, double inputSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mobileNumber,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          enabled: !_otpSent,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(fontSize: inputSize, color: textPrimary),
          decoration: InputDecoration(
            prefixText: '+91 ',
            prefixStyle: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: inputSize,
            ),
            hintText: '9876543210',
            hintStyle: TextStyle(
                fontSize: inputSize, color: textSecondary.withOpacity(0.5)),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpField(
      AppLocalizations l10n, double labelSize, double inputSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.enterOtp,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(fontSize: inputSize, color: textPrimary),
          decoration: InputDecoration(
            hintText: l10n.otpHint,
            hintStyle: TextStyle(
                fontSize: inputSize, color: textSecondary.withOpacity(0.5)),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _otpSent && !_isLoading ? _resendOtp : null,
          child: Text(
            l10n.resendOtp,
            style: TextStyle(
              fontSize: labelSize * 0.9,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(AppLocalizations l10n, double buttonSize) {
    return ElevatedButton(
      onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryColor.withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              _otpSent ? l10n.verifyOtp : l10n.sendOtp,
              style: TextStyle(
                fontSize: buttonSize,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildTermsText(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.termsText,
        style: TextStyle(
          fontSize: 11,
          color: textSecondary.withOpacity(0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _sendOtp() async {
    String mobileNumber = _mobileController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (mobileNumber.isEmpty) {
      _showError(l10n.enterMobileNumber);
      return;
    }

    if (mobileNumber.length != 10) {
      _showError(l10n.validPhoneError);
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    final fullMobileNumber = '+91$mobileNumber';
    final authProvider = context.read<AuthProvider>();

    try {
      bool success = await authProvider.requestOtp(fullMobileNumber);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        setState(() => _otpSent = true);
        _showMessage('${l10n.otpSentSuccess} +91 $mobileNumber');
        _otpController.clear();
        FocusScope.of(context).nextFocus();
      } else {
        _showError(l10n.otpSendFailed);
      }
    } catch (e) {
      debugPrint('Send OTP Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(l10n.networkError);
    }
  }

  Future<void> _verifyOtp() async {
    String mobileNumber = _mobileController.text.trim();
    String otp = _otpController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (otp.isEmpty || otp.length != 6) {
      _showError(l10n.validOtpError);
      return;
    }

    final fullMobileNumber = '+91$mobileNumber';
    final authProvider = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    bool success =
        await authProvider.verifyOtp(fullMobileNumber, otp, 'CUSTOMER');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showMessage(l10n.loginSuccess);
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/profile-check');
    } else {
      _showError(authProvider.lastError ?? l10n.invalidOtpError);
      _otpController.clear();
    }
  }

  Future<void> _resendOtp() async {
    String mobileNumber = _mobileController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (mobileNumber.isEmpty) {
      _showError(l10n.enterMobileNumber);
      return;
    }

    if (mobileNumber.length != 10) {
      _showError(l10n.validPhoneError);
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    final fullMobileNumber = '+91$mobileNumber';
    final authProvider = context.read<AuthProvider>();

    try {
      bool success = await authProvider.requestOtp(fullMobileNumber);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showMessage('${l10n.otpSentSuccess} +91 $mobileNumber');
        _otpController.clear();
        FocusScope.of(context).nextFocus();
      } else {
        _showError(l10n.otpSendFailed);
      }
    } catch (e) {
      debugPrint('Resend OTP Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(l10n.networkError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}