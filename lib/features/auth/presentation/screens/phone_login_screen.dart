import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import '../widgets/auth_text_field.dart';

/// Phone/SMS OTP login screen
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _error;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    // Basic phone validation
    if (phone.length < 10) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ClerkAuth.of(context);
      
      // Format phone number with country code if not present
      final formattedPhone = phone.startsWith('+') ? phone : '+1$phone';
      _phoneNumber = formattedPhone;
      
      await auth.attemptSignIn(
        strategy: clerk.Strategy.phoneCode,
        identifier: formattedPhone,
      );
      
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $formattedPhone'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = _parseError(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Please enter the OTP');
      return;
    }

    if (otp.length != 6) {
      setState(() => _error = 'OTP must be 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ClerkAuth.of(context);
      
      await auth.attemptSignIn(
        strategy: clerk.Strategy.phoneCode,
        identifier: _phoneNumber!,
        code: otp,
      );
      
      // ClerkAuthBuilder will handle navigation on success
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = _parseError(e.toString());
        _isLoading = false;
      });
    }
  }

  String _parseError(String error) {
    if (error.contains('invalid_code') || error.contains('incorrect')) {
      return 'Invalid OTP. Please try again.';
    }
    if (error.contains('expired')) {
      return 'OTP expired. Please request a new one.';
    }
    if (error.contains('not_found')) {
      return 'Phone number not registered. Please sign up first.';
    }
    if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    if (error.contains('too_many')) {
      return 'Too many attempts. Please try again later.';
    }
    if (error.contains('phone') && error.contains('not enabled')) {
      return 'SMS login is not enabled. Please contact support.';
    }
    return 'Failed to send OTP. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.phone_android_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _otpSent ? 'Enter OTP' : 'Enter Phone Number',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _otpSent
                    ? 'We sent a 6-digit code to $_phoneNumber'
                    : 'We\'ll send you a one-time verification code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Phone or OTP input
              if (!_otpSent) ...[
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+1 234 567 8900',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Include country code (e.g., +1 for US)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                // OTP input
                AuthTextField(
                  controller: _otpController,
                  label: 'Verification Code',
                  hint: '000000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                              _error = null;
                            });
                          },
                    child: Text(
                      'Didn\'t receive code? Resend',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Action button
              FilledButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _verifyOtp : _sendOtp),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        _otpSent ? 'Verify OTP' : 'Send OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

