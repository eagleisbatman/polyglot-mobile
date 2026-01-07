import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Polyglot'**
  String get appName;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Translation'**
  String get voiceTitle;

  /// No description provided for @voiceSpeakIn.
  ///
  /// In en, this message translates to:
  /// **'Speak in {language}'**
  String voiceSpeakIn(String language);

  /// No description provided for @voiceTranslateTo.
  ///
  /// In en, this message translates to:
  /// **'Translate to {language}'**
  String voiceTranslateTo(String language);

  /// No description provided for @voiceTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceTapToSpeak;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get voiceRecording;

  /// No description provided for @voiceProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get voiceProcessing;

  /// No description provided for @voiceHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get voiceHistory;

  /// No description provided for @voiceSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'Session Summary'**
  String get voiceSessionSummary;

  /// No description provided for @voiceFollowUpQuestions.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Questions'**
  String get voiceFollowUpQuestions;

  /// No description provided for @voiceLanguageMismatch.
  ///
  /// In en, this message translates to:
  /// **'Language mismatch detected'**
  String get voiceLanguageMismatch;

  /// No description provided for @voiceAdjustLanguage.
  ///
  /// In en, this message translates to:
  /// **'Adjust Language'**
  String get voiceAdjustLanguage;

  /// No description provided for @visionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision Translation'**
  String get visionTitle;

  /// No description provided for @visionCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get visionCaptureImage;

  /// No description provided for @visionPickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get visionPickFromGallery;

  /// No description provided for @visionTranslateImage.
  ///
  /// In en, this message translates to:
  /// **'Translate Image'**
  String get visionTranslateImage;

  /// No description provided for @visionTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target Language'**
  String get visionTargetLanguage;

  /// No description provided for @visionProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get visionProcessing;

  /// No description provided for @visionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get visionHistory;

  /// No description provided for @docsTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Translation'**
  String get docsTitle;

  /// No description provided for @docsUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get docsUploadDocument;

  /// No description provided for @docsSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get docsSelectMode;

  /// No description provided for @docsTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get docsTranslate;

  /// No description provided for @docsSummarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get docsSummarize;

  /// No description provided for @docsProcess.
  ///
  /// In en, this message translates to:
  /// **'Process Document'**
  String get docsProcess;

  /// No description provided for @docsProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing document...'**
  String get docsProcessing;

  /// No description provided for @docsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Result'**
  String get docsExport;

  /// No description provided for @docsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get docsHistory;

  /// No description provided for @docsWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get docsWorkspace;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get commonOffline;

  /// No description provided for @commonNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get commonNoInternet;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get commonSelectLanguage;

  /// No description provided for @commonSearchLanguages.
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get commonSearchLanguages;

  /// No description provided for @navVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get navVoice;

  /// No description provided for @navVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get navVision;

  /// No description provided for @navDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// No description provided for @chatStartTranslating.
  ///
  /// In en, this message translates to:
  /// **'Start translating'**
  String get chatStartTranslating;

  /// No description provided for @chatEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic to speak, take a photo,\nor attach a document'**
  String get chatEmptyDescription;

  /// No description provided for @chatVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Speak and get instant translation'**
  String get chatVoiceHint;

  /// No description provided for @chatVisionHint.
  ///
  /// In en, this message translates to:
  /// **'Translate text in images'**
  String get chatVisionHint;

  /// No description provided for @chatDocumentsHint.
  ///
  /// In en, this message translates to:
  /// **'Translate PDFs and documents'**
  String get chatDocumentsHint;

  /// No description provided for @chatTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get chatTranslating;

  /// No description provided for @chatProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get chatProcessing;

  /// No description provided for @chatTranslationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get chatTranslationFailed;

  /// No description provided for @chatPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get chatPlayAudio;

  /// No description provided for @chatTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get chatTakePhoto;

  /// No description provided for @chatTakePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use camera to capture text'**
  String get chatTakePhotoSubtitle;

  /// No description provided for @chatChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chatChooseFromGallery;

  /// No description provided for @chatChooseFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an existing image'**
  String get chatChooseFromGallerySubtitle;

  /// No description provided for @chatLanguageFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get chatLanguageFrom;

  /// No description provided for @chatLanguageTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get chatLanguageTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
