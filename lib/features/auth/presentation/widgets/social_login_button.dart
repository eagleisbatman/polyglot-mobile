import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A styled button for social login providers
class SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? customIcon;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.customIcon,
    this.isLoading = false,
  });

  /// Creates a Google sign-in button with proper branding
  factory SocialLoginButton.google({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      label: 'Continue with Google',
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      isLoading: isLoading,
      customIcon: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _GoogleLogoPainter(),
        ),
      ),
    );
  }

  /// Creates an Apple sign-in button
  factory SocialLoginButton.apple({
    required BuildContext context,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SocialLoginButton(
      icon: Icons.apple,
      label: 'Continue with Apple',
      onPressed: onPressed,
      backgroundColor: isDark ? Colors.white : Colors.black,
      foregroundColor: isDark ? Colors.black : Colors.white,
      isLoading: isLoading,
    );
  }

  /// Creates a Phone/SMS sign-in button
  factory SocialLoginButton.phone({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      icon: Icons.phone_outlined,
      label: 'Continue with Phone',
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fgColor = foregroundColor ?? theme.colorScheme.onSurface;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (customIcon != null)
                    customIcon!
                  else if (icon != null)
                    Icon(icon, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Google "G" logo painter with proper colors
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Google brand colors
    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4);
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335);
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853);

    final path = Path();
    
    // Draw the G shape
    // Blue part (right side and bar)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -0.4,
      1.8,
      true,
      bluePaint,
    );
    
    // Red part (top right)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -1.57,
      1.17,
      true,
      redPaint,
    );
    
    // Yellow part (bottom left)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      1.4,
      1.17,
      true,
      yellowPaint,
    );
    
    // Green part (bottom)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      0.4,
      1.0,
      true,
      greenPaint,
    );
    
    // White center circle
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.35,
      Paint()..color = Colors.white,
    );
    
    // Blue horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.52, h * 0.24),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
