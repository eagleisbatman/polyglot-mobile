import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../localization/l10n/app_localizations.dart';
import '../providers/document_translation_provider.dart';

class DocumentTranslatorScreen extends ConsumerStatefulWidget {
  const DocumentTranslatorScreen({super.key});

  @override
  ConsumerState<DocumentTranslatorScreen> createState() => _DocumentTranslatorScreenState();
}

class _DocumentTranslatorScreenState extends ConsumerState<DocumentTranslatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).trackScreenView('document_translation');
      ref.read(analyticsServiceProvider).trackEvent(AnalyticsEvents.screenDocumentTranslation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentTranslationProvider);
    final notifier = ref.read(documentTranslationProvider.notifier);

    return Scaffold(
      key: const Key(TestTags.docsScreen),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.docsTitle),
        actions: [
          IconButton(
            key: const Key(TestTags.docsHistoryButton),
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/history');
            },
          ),
          IconButton(
            key: const Key(TestTags.appBarProfileButton),
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'translate', label: Text(AppLocalizations.of(context)!.docsTranslate)),
                      ButtonSegment(value: 'summarize', label: Text(AppLocalizations.of(context)!.docsSummarize)),
                    ],
                    selected: {state.mode},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref.read(analyticsServiceProvider).trackEvent(
                            AnalyticsEvents.documentModeChanged,
                            properties: {
                              AnalyticsProperties.documentMode: newSelection.first,
                            },
                          );
                      notifier.setMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (state.selectedFilePath != null)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('File: ${state.selectedFilePath!.split('/').last}'),
                  ),
                  if (state.isProcessing)
                    LoadingIndicator(message: AppLocalizations.of(context)!.docsProcessing)
                  else if (state.error != null)
                    ErrorBanner(
                      message: state.error!,
                      onRetry: () {},
                    )
                  else if (state.interactions.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            state.interactions.last.result,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: ElevatedButton.icon(
                  key: const Key(TestTags.docsFilePickerButton),
                  icon: const Icon(Icons.upload_file),
                  label: Text(AppLocalizations.of(context)!.docsUploadDocument),
                  onPressed: () async {
                    ref.read(analyticsServiceProvider).trackEvent(
                          AnalyticsEvents.documentFilePickerOpened,
                        );
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      ref.read(analyticsServiceProvider).trackEvent(
                            AnalyticsEvents.documentFileSelected,
                            properties: {
                              AnalyticsProperties.documentType: result.files.single.extension ?? 'unknown',
                              AnalyticsProperties.documentSize: result.files.single.size ?? 0,
                            },
                          );
                      notifier.processDocument(result.files.single.path!);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
