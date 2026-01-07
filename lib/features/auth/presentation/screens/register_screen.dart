import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import '../../../../core/constants/test_tags.dart';
import '../widgets/social_login_button.dart';
import '../widgets/auth_text_field.dart';

/// Beautiful native Flutter registration screen using Clerk auth
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  String? _error;
  
  // Track current verification step
  bool _needsPhoneVerification = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Attempting sign up with email: ${_emailController.text.trim()}');
      final phoneNumber = _phoneController.text.trim();
      debugPrint('Phone number: ${phoneNumber.isEmpty ? "(not provided)" : phoneNumber}');
      final auth = ClerkAuth.of(context);
      
      // Create sign-up with email (and optionally phone) and password
      await auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode, // Email verification first
        emailAddress: _emailController.text.trim(),
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      
      debugPrint('Sign up response - status: ${auth.signUp?.status}');
      debugPrint('Sign up response - verification status: ${auth.signUp?.verifications}');
      
      // Show email verification dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to ${_emailController.text.trim()}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        _showVerificationDialog();
      }
    } catch (e) {
      debugPrint('Sign-up error: $e');
      final errorMessage = _parseError(e.toString());
      setState(() {
        _error = errorMessage;
      });
      // Also show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ClerkAuth.of(context);
      await auth.attemptSignUp(strategy: clerk.Strategy.oauthGoogle);
    } catch (e) {
      setState(() {
        _error = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ClerkAuth.of(context);
      await auth.attemptSignUp(strategy: clerk.Strategy.oauthApple);
    } catch (e) {
      setState(() {
        _error = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error) {
    debugPrint('Parsing error: $error');
    if (error.contains('email_address_taken')) {
      return 'This email is already registered. Try signing in instead.';
    }
    if (error.contains('phone_number_taken')) {
      return 'This phone number is already registered.';
    }
    if (error.contains('password_too_short') || error.contains('password_too_weak')) {
      return 'Password must be at least 8 characters with mix of letters and numbers';
    }
    if (error.contains('form_identifier_exists')) {
      return 'This email or phone is already registered';
    }
    if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    if (error.contains('verification')) {
      return 'Verification required. Check your email/SMS.';
    }
    if (error.contains('phone_number') && error.contains('invalid')) {
      return 'Please enter a valid phone number with country code (e.g., +1...)';
    }
    if (error.contains('captcha')) {
      return 'Security check failed. Please try again.';
    }
    return 'Sign up failed. Please try again.';
  }

  final _verificationCodeController = TextEditingController();

  void _showVerificationDialog({bool isPhone = false}) {
    bool isVerifying = false;
    bool isResending = false;
    
    final verificationTarget = isPhone ? _phoneController.text : _emailController.text;
    final strategy = isPhone ? clerk.Strategy.phoneCode : clerk.Strategy.emailCode;
    final icon = isPhone ? Icons.sms_outlined : Icons.mark_email_unread_outlined;
    final title = isPhone ? 'Verify Your Phone' : 'Verify Your Email';
    final messagePrefix = isPhone ? 'We sent an SMS code to:' : 'We sent a verification code to:';
    final spamHint = isPhone ? '' : '(Check your spam folder if you don\'t see it)';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                messagePrefix,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                verificationTarget,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (spamHint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  spamHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '000000',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isResending
                    ? null
                    : () async {
                        setDialogState(() => isResending = true);
                        try {
                          final auth = ClerkAuth.of(context);
                          // Resend the verification code
                          await auth.attemptSignUp(
                            strategy: strategy,
                            emailAddress: _emailController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            password: _passwordController.text,
                            passwordConfirmation: _confirmPasswordController.text,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification code resent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Resend error: $e');
                        }
                        setDialogState(() => isResending = false);
                      },
                child: isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isVerifying
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      _verificationCodeController.clear();
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isVerifying
                  ? null
                  : () async {
                      final code = _verificationCodeController.text.trim();
                      if (code.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the 6-digit code'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isVerifying = true);
                      
                      try {
                        debugPrint('Verifying ${isPhone ? "phone" : "email"} code: $code');
                        final auth = ClerkAuth.of(context);
                        await auth.attemptSignUp(
                          strategy: strategy,
                          code: code,
                        );
                        
                        debugPrint('Verification status: ${auth.signUp?.status}');
                        
                        // Check if we need phone verification after email
                        if (!isPhone && auth.signUp?.status == clerk.Status.missingRequirements) {
                          // Email verified, now need phone
                          if (mounted) {
                            Navigator.of(dialogContext).pop();
                            _verificationCodeController.clear();
                            
                            // Request phone verification
                            try {
                              await auth.attemptSignUp(
                                strategy: clerk.Strategy.phoneCode,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('SMS code sent to ${_phoneController.text}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _showVerificationDialog(isPhone: true);
                            } catch (e) {
                              debugPrint('Phone verification request error: $e');
                              setState(() => _error = 'Phone verification failed: ${e.toString()}');
                            }
                          }
                          return;
                        }
                        
                        debugPrint('Verification successful!');
                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          _verificationCodeController.clear();
                          // Success - ClerkAuthBuilder will handle navigation
                        }
                      } catch (e) {
                        debugPrint('Verification error: $e');
                        setDialogState(() => isVerifying = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invalid or expired code. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key(TestTags.authRegisterScreen),
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // Header
              Text(
                'Create Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your translation journey',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Social login buttons
              _buildSocialButtons(theme),
              const SizedBox(height: 24),
              
              // Divider
              _buildDivider(theme),
              const SizedBox(height: 24),
              
              // Email form
              _buildEmailForm(theme),
              const SizedBox(height: 24),
              
              // Sign in link
              _buildSignInLink(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons(ThemeData theme) {
    return Column(
      children: [
        SocialLoginButton(
          icon: Icons.apple,
          label: 'Continue with Apple',
          onPressed: _isLoading ? null : _handleAppleSignUp,
          backgroundColor: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          foregroundColor: theme.brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        const SizedBox(height: 12),
        SocialLoginButton.google(
          onPressed: _isLoading ? null : _handleGoogleSignUp,
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or sign up with email',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.colorScheme.outlineVariant),
        ),
      ],
    );
  }

  Widget _buildEmailForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          // Email field
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone field (optional - for SMS login/2FA)
          AuthTextField(
            controller: _phoneController,
            label: 'Phone Number (Optional)',
            hint: '+1 (555) 123-4567',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              // Phone is optional, but if provided, validate it
              if (value != null && value.isNotEmpty) {
                final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length < 10) {
                  return 'Please enter a valid phone number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            obscureText: !_showPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm password field
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            obscureText: !_showPassword,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Sign up button
          FilledButton(
            onPressed: _isLoading ? null : _handleEmailSignUp,
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
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
