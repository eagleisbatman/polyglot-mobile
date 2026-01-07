import 'package:flutter/material.dart';

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    data.icon,
                    size: 64,
                    color: data.color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

