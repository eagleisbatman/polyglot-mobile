import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../localization/l10n/app_localizations.dart';
import '../providers/vision_translation_provider.dart';

class VisionTranslatorScreen extends ConsumerStatefulWidget {
  const VisionTranslatorScreen({super.key});

  @override
  ConsumerState<VisionTranslatorScreen> createState() => _VisionTranslatorScreenState();
}

class _VisionTranslatorScreenState extends ConsumerState<VisionTranslatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).trackScreenView('vision_translation');
      ref.read(analyticsServiceProvider).trackEvent(AnalyticsEvents.screenVisionTranslation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visionTranslationProvider);
    final notifier = ref.read(visionTranslationProvider.notifier);
    final imagePicker = ImagePicker();

    return Scaffold(
      key: const Key(TestTags.visionScreen),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.visionTitle),
        actions: [
          IconButton(
            key: const Key(TestTags.visionHistoryButton),
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
          if (state.selectedImagePath != null)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Image.file(
                      File(state.selectedImagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (state.isProcessing)
                    LoadingIndicator(message: AppLocalizations.of(context)!.visionProcessing)
                  else if (state.error != null)
                    ErrorBanner(
                      message: state.error!,
                      onRetry: () {},
                    )
                  else if (state.interactions.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.interactions.last.translatedText,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      key: const Key(TestTags.visionCaptureButton),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.visionCaptureImage),
                      onPressed: () async {
                        ref.read(analyticsServiceProvider).trackEvent(
                              AnalyticsEvents.visionCameraOpened,
                            );
                        final image = await imagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          ref.read(analyticsServiceProvider).trackEvent(
                                AnalyticsEvents.visionImageCaptured,
                                properties: {
                                  AnalyticsProperties.imageSource: 'camera',
                                },
                              );
                          notifier.translateImage(image.path);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      key: const Key(TestTags.visionImagePickerButton),
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)!.visionPickFromGallery),
                      onPressed: () async {
                        ref.read(analyticsServiceProvider).trackEvent(
                              AnalyticsEvents.visionImagePickedFromGallery,
                            );
                        final image = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          ref.read(analyticsServiceProvider).trackEvent(
                                AnalyticsEvents.visionImagePickedFromGallery,
                                properties: {
                                  AnalyticsProperties.imageSource: 'gallery',
                                },
                              );
                          notifier.translateImage(image.path);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
