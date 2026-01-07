import 'package:flutter/material.dart';

/// Compact language pair selector for the app bar
class CompactLanguageSelector extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback onTap;
  final VoidCallback onSwap;

  const CompactLanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onTap,
    required this.onSwap,
  });

  String _getLanguageName(String code) {
    const languages = {
      'en': 'English',
      'hi': 'हिंदी',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'pt': 'Português',
      'it': 'Italiano',
      'ru': 'Русский',
      'ar': 'العربية',
      'vi': 'Tiếng Việt',
      'th': 'ไทย',
    };
    return languages[code] ?? code.toUpperCase();
  }

  String _getFlag(String code) {
    const flags = {
      'en': '🇺🇸',
      'hi': '🇮🇳',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'zh': '🇨🇳',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'pt': '🇧🇷',
      'it': '🇮🇹',
      'ru': '🇷🇺',
      'ar': '🇸🇦',
      'vi': '🇻🇳',
      'th': '🇹🇭',
    };
    return flags[code] ?? '🌐';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlag(sourceLanguage),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              sourceLanguage.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSwap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              targetLanguage.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getFlag(targetLanguage),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

