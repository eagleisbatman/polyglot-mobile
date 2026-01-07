import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/constants/supported_languages.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;
  final bool isSource;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    this.isSource = true,
  });

  @override
  Widget build(BuildContext context) {
    final language = SupportedLanguages.findByCode(selectedLanguage);
    
    return InkWell(
      key: Key(isSource
          ? TestTags.voiceLanguageSelectorSource
          : TestTags.voiceLanguageSelectorTarget),
      onTap: () => _showLanguageModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language?.nativeName ?? selectedLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
        // key: const Key(TestTags.voiceLanguageModal), // TODO: Fix key parameter
      builder: (context) => _LanguageModal(
        selectedLanguage: selectedLanguage,
        onLanguageSelected: (lang) {
          onLanguageSelected(lang);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _LanguageModal extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const _LanguageModal({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<_LanguageModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = SupportedLanguages.all.where((lang) {
      return lang.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lang.nativeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key(TestTags.voiceLanguageSearchInput),
            decoration: const InputDecoration(
              hintText: 'Search languages...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                final lang = filteredLanguages[index];
                return ListTile(
                  key: Key(TestTags.voiceLanguageItem(lang.code)),
                  title: Text(lang.nativeName),
                  subtitle: Text(lang.name),
                  selected: lang.code == widget.selectedLanguage,
                  onTap: () => widget.onLanguageSelected(lang.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

