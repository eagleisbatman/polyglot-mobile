// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Polyglot';

  @override
  String get voiceTitle => 'आवाज अनुवाद';

  @override
  String voiceSpeakIn(String language) {
    return '$language में बोलें';
  }

  @override
  String voiceTranslateTo(String language) {
    return '$language में अनुवाद करें';
  }

  @override
  String get voiceTapToSpeak => 'बोलने के लिए टैप करें';

  @override
  String get voiceRecording => 'रिकॉर्डिंग...';

  @override
  String get voiceProcessing => 'प्रसंस्करण...';

  @override
  String get voiceHistory => 'इतिहास';

  @override
  String get voiceSessionSummary => 'सत्र सारांश';

  @override
  String get voiceFollowUpQuestions => 'अनुवर्ती प्रश्न';

  @override
  String get voiceLanguageMismatch => 'भाषा असंगति का पता चला';

  @override
  String get voiceAdjustLanguage => 'भाषा समायोजित करें';

  @override
  String get visionTitle => 'दृष्टि अनुवाद';

  @override
  String get visionCaptureImage => 'छवि कैप्चर करें';

  @override
  String get visionPickFromGallery => 'गैलरी से चुनें';

  @override
  String get visionTranslateImage => 'छवि का अनुवाद करें';

  @override
  String get visionTargetLanguage => 'लक्ष्य भाषा';

  @override
  String get visionProcessing => 'छवि प्रसंस्करण...';

  @override
  String get visionHistory => 'इतिहास';

  @override
  String get docsTitle => 'दस्तावेज़ अनुवाद';

  @override
  String get docsUploadDocument => 'दस्तावेज़ अपलोड करें';

  @override
  String get docsSelectMode => 'मोड चुनें';

  @override
  String get docsTranslate => 'अनुवाद करें';

  @override
  String get docsSummarize => 'सारांश';

  @override
  String get docsProcess => 'दस्तावेज़ प्रसंस्करण';

  @override
  String get docsProcessing => 'दस्तावेज़ प्रसंस्करण...';

  @override
  String get docsExport => 'परिणाम निर्यात करें';

  @override
  String get docsHistory => 'इतिहास';

  @override
  String get docsWorkspace => 'कार्यक्षेत्र';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get commonError => 'त्रुटि';

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonDelete => 'हटाएं';

  @override
  String get commonOffline => 'आप ऑफलाइन हैं';

  @override
  String get commonNoInternet => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String get commonTryAgain => 'पुनः प्रयास करें';

  @override
  String get commonSelectLanguage => 'भाषा चुनें';

  @override
  String get commonSearchLanguages => 'भाषाएं खोजें...';

  @override
  String get navVoice => 'आवाज';

  @override
  String get navVision => 'दृष्टि';

  @override
  String get navDocuments => 'दस्तावेज़';

  @override
  String get chatStartTranslating => 'अनुवाद शुरू करें';

  @override
  String get chatEmptyDescription =>
      'बोलने के लिए माइक टैप करें, फोटो लें,\nया दस्तावेज़ संलग्न करें';

  @override
  String get chatVoiceHint => 'बोलें और तुरंत अनुवाद प्राप्त करें';

  @override
  String get chatVisionHint => 'छवियों में टेक्स्ट का अनुवाद करें';

  @override
  String get chatDocumentsHint => 'PDF और दस्तावेज़ों का अनुवाद करें';

  @override
  String get chatTranslating => 'अनुवाद हो रहा है...';

  @override
  String get chatProcessing => 'प्रसंस्करण...';

  @override
  String get chatTranslationFailed => 'अनुवाद विफल';

  @override
  String get chatPlayAudio => 'ऑडियो चलाएं';

  @override
  String get chatTakePhoto => 'फोटो लें';

  @override
  String get chatTakePhotoSubtitle =>
      'टेक्स्ट कैप्चर करने के लिए कैमरा का उपयोग करें';

  @override
  String get chatChooseFromGallery => 'गैलरी से चुनें';

  @override
  String get chatChooseFromGallerySubtitle => 'मौजूदा छवि चुनें';

  @override
  String get chatLanguageFrom => 'से';

  @override
  String get chatLanguageTo => 'में';
}
