import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../localization/l10n/app_localizations.dart';
import '../providers/voice_translation_provider.dart';
import '../widgets/mic_button.dart';
import '../widgets/language_selector.dart';
import '../widgets/transcription_bubble.dart';

class VoiceTranslatorScreen extends ConsumerStatefulWidget {
  const VoiceTranslatorScreen({super.key});

  @override
  ConsumerState<VoiceTranslatorScreen> createState() => _VoiceTranslatorScreenState();
}

class _VoiceTranslatorScreenState extends ConsumerState<VoiceTranslatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).trackScreenView('voice_translation');
      ref.read(analyticsServiceProvider).trackEvent(AnalyticsEvents.screenVoiceTranslation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceTranslationProvider);
    final notifier = ref.read(voiceTranslationProvider.notifier);

    return Scaffold(
      key: const Key(TestTags.voiceScreen),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.voiceTitle),
        actions: [
          IconButton(
            key: const Key(TestTags.voiceHistoryButton),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: LanguageSelector(
                    selectedLanguage: state.sourceLanguage,
                    onLanguageSelected: notifier.setSourceLanguage,
                    isSource: true,
                  ),
                ),
                IconButton(
                  key: const Key(TestTags.voiceLanguageSwapButton),
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: notifier.swapLanguages,
                ),
                Expanded(
                  child: LanguageSelector(
                    selectedLanguage: state.targetLanguage,
                    onLanguageSelected: notifier.setTargetLanguage,
                    isSource: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isProcessing
                ? LoadingIndicator(message: AppLocalizations.of(context)!.voiceProcessing)
                : state.error != null
                    ? ErrorBanner(
                        message: state.error!,
                        onRetry: () {},
                      )
                    : ListView.builder(
                        itemCount: state.interactions.length * 2,
                        itemBuilder: (context, index) {
                          if (index.isEven) {
                            final interactionIndex = index ~/ 2;
                            final interaction = state.interactions[interactionIndex];
                            return TranscriptionBubble(
                              text: interaction.transcription,
                              isUser: true,
                              index: interactionIndex,
                            );
                          } else {
                            final interactionIndex = (index - 1) ~/ 2;
                            final interaction = state.interactions[interactionIndex];
                            return TranscriptionBubble(
                              text: interaction.translation,
                              isUser: false,
                              index: interactionIndex,
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: MicButton(
        isRecording: state.isRecording,
        onPressed: state.isRecording
            ? notifier.stopRecording
            : notifier.startRecording,
      ),
    );
  }
}
