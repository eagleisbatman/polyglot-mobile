import 'package:flutter/material.dart';

/// Full screen language selector bottom sheet
class LanguageSelectorSheet extends StatefulWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;

  const LanguageSelectorSheet({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  @override
  State<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<LanguageSelectorSheet> {
  late String _source;
  late String _target;
  String? _selectingFor;

  static const _languages = [
    ('en', 'English', '🇺🇸'),
    ('hi', 'हिंदी', '🇮🇳'),
    ('es', 'Español', '🇪🇸'),
    ('fr', 'Français', '🇫🇷'),
    ('de', 'Deutsch', '🇩🇪'),
    ('zh', '中文', '🇨🇳'),
    ('ja', '日本語', '🇯🇵'),
    ('ko', '한국어', '🇰🇷'),
    ('pt', 'Português', '🇧🇷'),
    ('it', 'Italiano', '🇮🇹'),
    ('ru', 'Русский', '🇷🇺'),
    ('ar', 'العربية', '🇸🇦'),
    ('vi', 'Tiếng Việt', '🇻🇳'),
    ('th', 'ไทย', '🇹🇭'),
  ];

  @override
  void initState() {
    super.initState();
    _source = widget.sourceLanguage;
    _target = widget.targetLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _LanguageChip(
                    code: _source,
                    languages: _languages,
                    label: 'From',
                    isSelected: _selectingFor == 'source',
                    onTap: () => setState(() => _selectingFor = 'source'),
                    theme: theme,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = _source;
                      _source = _target;
                      _target = temp;
                    });
                    widget.onSourceChanged(_source);
                    widget.onTargetChanged(_target);
                  },
                  icon: const Icon(Icons.swap_horiz),
                ),
                Expanded(
                  child: _LanguageChip(
                    code: _target,
                    languages: _languages,
                    label: 'To',
                    isSelected: _selectingFor == 'target',
                    onTap: () => setState(() => _selectingFor = 'target'),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectingFor == 'source'
                    ? _source == lang.$1
                    : _target == lang.$1;
                
                return ListTile(
                  leading: Text(lang.$3, style: const TextStyle(fontSize: 24)),
                  title: Text(lang.$2),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      if (_selectingFor == 'source') {
                        _source = lang.$1;
                        widget.onSourceChanged(lang.$1);
                      } else if (_selectingFor == 'target') {
                        _target = lang.$1;
                        widget.onTargetChanged(lang.$1);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String code;
  final List<(String, String, String)> languages;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LanguageChip({
    required this.code,
    required this.languages,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final lang = languages.firstWhere(
      (l) => l.$1 == code,
      orElse: () => (code, code, '🌐'),
    );
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lang.$3, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  lang.$2,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

