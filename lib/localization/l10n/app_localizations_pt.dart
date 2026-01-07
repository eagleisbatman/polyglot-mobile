// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Polyglot';

  @override
  String get voiceTitle => 'Voice Translation';

  @override
  String voiceSpeakIn(String language) {
    return 'Speak in $language';
  }

  @override
  String voiceTranslateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String get voiceTapToSpeak => 'Tap to speak';

  @override
  String get voiceRecording => 'Recording...';

  @override
  String get voiceProcessing => 'Processing...';

  @override
  String get voiceHistory => 'History';

  @override
  String get voiceSessionSummary => 'Session Summary';

  @override
  String get voiceFollowUpQuestions => 'Follow-up Questions';

  @override
  String get voiceLanguageMismatch => 'Language mismatch detected';

  @override
  String get voiceAdjustLanguage => 'Adjust Language';

  @override
  String get visionTitle => 'Vision Translation';

  @override
  String get visionCaptureImage => 'Capture Image';

  @override
  String get visionPickFromGallery => 'Pick from Gallery';

  @override
  String get visionTranslateImage => 'Translate Image';

  @override
  String get visionTargetLanguage => 'Target Language';

  @override
  String get visionProcessing => 'Processing image...';

  @override
  String get visionHistory => 'History';

  @override
  String get docsTitle => 'Document Translation';

  @override
  String get docsUploadDocument => 'Upload Document';

  @override
  String get docsSelectMode => 'Select Mode';

  @override
  String get docsTranslate => 'Translate';

  @override
  String get docsSummarize => 'Summarize';

  @override
  String get docsProcess => 'Process Document';

  @override
  String get docsProcessing => 'Processing document...';

  @override
  String get docsExport => 'Export Result';

  @override
  String get docsHistory => 'History';

  @override
  String get docsWorkspace => 'Workspace';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonOffline => 'You are offline';

  @override
  String get commonNoInternet => 'No internet connection';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonSelectLanguage => 'Select Language';

  @override
  String get commonSearchLanguages => 'Search languages...';

  @override
  String get navVoice => 'Voice';

  @override
  String get navVision => 'Vision';

  @override
  String get navDocuments => 'Documents';

  @override
  String get chatStartTranslating => 'Start translating';

  @override
  String get chatEmptyDescription =>
      'Tap the mic to speak, take a photo,\nor attach a document';

  @override
  String get chatVoiceHint => 'Speak and get instant translation';

  @override
  String get chatVisionHint => 'Translate text in images';

  @override
  String get chatDocumentsHint => 'Translate PDFs and documents';

  @override
  String get chatTranslating => 'Translating...';

  @override
  String get chatProcessing => 'Processing...';

  @override
  String get chatTranslationFailed => 'Translation failed';

  @override
  String get chatPlayAudio => 'Play audio';

  @override
  String get chatTakePhoto => 'Take Photo';

  @override
  String get chatTakePhotoSubtitle => 'Use camera to capture text';

  @override
  String get chatChooseFromGallery => 'Choose from Gallery';

  @override
  String get chatChooseFromGallerySubtitle => 'Select an existing image';

  @override
  String get chatLanguageFrom => 'From';

  @override
  String get chatLanguageTo => 'To';
}
