class TestTags {
  TestTags._();

  // Authentication
  static const String authLoginScreen = 'auth_login_screen';
  static const String authRegisterScreen = 'auth_register_screen';
  static const String authEmailField = 'auth_email_field';
  static const String authPasswordField = 'auth_password_field';
  static const String authLoginButton = 'auth_login_button';
  static const String authRegisterButton = 'auth_register_button';
  static const String authRegisterEmailField = 'auth_register_email_field';
  static const String authRegisterPasswordField = 'auth_register_password_field';
  static const String authRegisterConfirmPasswordField = 'auth_register_confirm_password_field';
  static const String authRegisterLink = 'auth_register_link';
  static const String authLoginLink = 'auth_login_link';

  // User Profile
  static const String userProfileScreen = 'user_profile_screen';
  static const String userProfileEditButton = 'user_profile_edit_button';
  static const String userProfileEmailField = 'user_profile_email_field';
  static const String userProfileSaveButton = 'user_profile_save_button';
  static const String userProfileCancelButton = 'user_profile_cancel_button';
  static const String userProfileLogoutButton = 'user_profile_logout_button';

  // Preferences
  static const String preferencesScreen = 'preferences_screen';
  static const String preferencesSaveButton = 'preferences_save_button';
  static const String preferencesNotificationsSwitch = 'preferences_notifications_switch';
  static const String preferencesLocationSwitch = 'preferences_location_switch';

  // App Bar
  static const String appBarProfileButton = 'app_bar_profile_button';

  // History Screen
  static const String historyScreen = 'history_screen';
  static const String historyFilterButton = 'history_filter_button';
  static String historyItem(String id) => 'history_item_$id';

  // Voice Translation Tags
  static const String voiceScreen = 'voice_screen';
  static const String voiceHistoryButton = 'voice_history_button';
  static const String voiceLiveAudioBadge = 'voice_live_audio_badge';

  // Voice Language Selection
  static const String voiceLanguageSelectorSource = 'voice_language_selector_source';
  static const String voiceLanguageSelectorTarget = 'voice_language_selector_target';
  static const String voiceLanguageSwapButton = 'voice_language_swap_button';
  static const String voiceLanguageModal = 'voice_language_modal';
  static const String voiceLanguageSearchInput = 'voice_language_search_input';
  static String voiceLanguageItem(String code) => 'voice_language_item_$code';

  // Voice Microphone Controls
  static const String voiceMicButton = 'voice_mic_button';
  static const String voiceMicButtonStart = 'voice_mic_button_start';
  static const String voiceMicButtonStop = 'voice_mic_button_stop';
  static const String voiceMicStatusIndicator = 'voice_mic_status_indicator';

  // Voice Transcription Display
  static const String voiceTranscriptionContainer = 'voice_transcription_container';
  static String voiceTranscriptionUser(int index) => 'voice_transcription_user_$index';
  static String voiceTranscriptionModel(int index) => 'voice_transcription_model_$index';
  static const String voiceLiveUserText = 'voice_live_user_text';
  static const String voiceLiveModelText = 'voice_live_model_text';

  // Voice Session Summary
  static const String voiceSessionSummary = 'voice_session_summary';
  static const String voiceSessionSummaryToggle = 'voice_session_summary_toggle';
  static const String voiceSessionSummaryText = 'voice_session_summary_text';

  // Voice Language Mismatch
  static const String voiceLangMismatchAlert = 'voice_lang_mismatch_alert';
  static const String voiceLangMismatchAdjustButton = 'voice_lang_mismatch_adjust_button';

  // Voice History
  static const String voiceHistoryScreen = 'voice_history_screen';
  static const String voiceHistoryBackButton = 'voice_history_back_button';
  static String voiceHistoryItem(String id) => 'voice_history_item_$id';
  static const String voiceHistoryItemTimestamp = 'voice_history_item_timestamp';
  static const String voiceHistoryItemLanguages = 'voice_history_item_languages';
  static const String voiceHistoryItemPreview = 'voice_history_item_preview';
  static const String voiceHistoryThreadView = 'voice_history_thread_view';
  static const String voiceHistoryThreadBack = 'voice_history_thread_back';

  // Vision Translation Tags
  static const String visionScreen = 'vision_screen';
  static const String visionHistoryButton = 'vision_history_button';
  static const String visionTargetLanguageSelector = 'vision_target_language_selector';

  // Vision Camera & Image
  static const String visionCameraPreview = 'vision_camera_preview';
  static const String visionCaptureButton = 'vision_capture_button';
  static const String visionImagePreview = 'vision_image_preview';
  static const String visionImageCloseButton = 'vision_image_close_button';
  static const String visionImagePickerButton = 'vision_image_picker_button';

  // Vision Translation
  static const String visionTranslateButton = 'vision_translate_button';
  static const String visionTranslationResult = 'vision_translation_result';
  static const String visionTranslationResultText = 'vision_translation_result_text';
  static const String visionTranslationResultClose = 'vision_translation_result_close';
  static const String visionProcessingIndicator = 'vision_processing_indicator';

  // Vision History
  static const String visionHistoryScreen = 'vision_history_screen';
  static const String visionHistoryBackButton = 'vision_history_back_button';
  static String visionHistoryItem(String id) => 'vision_history_item_$id';
  static const String visionHistoryItemImage = 'vision_history_item_image';
  static const String visionHistoryItemPreview = 'vision_history_item_preview';
  static const String visionHistoryThreadView = 'vision_history_thread_view';
  static const String visionHistoryThreadImage = 'vision_history_thread_image';
  static const String visionHistoryThreadTranslation = 'vision_history_thread_translation';

  // Document Translation Tags
  static const String docsScreen = 'docs_screen';
  static const String docsHistoryButton = 'docs_history_button';
  static const String docsWorkspaceLabel = 'docs_workspace_label';

  // Document Mode Selection
  static const String docsModeSelector = 'docs_mode_selector';
  static const String docsModeTranslate = 'docs_mode_translate';
  static const String docsModeSummarize = 'docs_mode_summarize';
  static const String docsTargetLanguageSelector = 'docs_target_language_selector';

  // Document File Handling
  static const String docsFilePickerButton = 'docs_file_picker_button';
  static const String docsFilePickerInput = 'docs_file_picker_input';
  static const String docsDocumentPreview = 'docs_document_preview';
  static const String docsDocumentName = 'docs_document_name';
  static const String docsDocumentRemoveButton = 'docs_document_remove_button';

  // Document Processing
  static const String docsProcessButton = 'docs_process_button';
  static const String docsProcessButtonTranslate = 'docs_process_button_translate';
  static const String docsProcessButtonSummarize = 'docs_process_button_summarize';
  static const String docsProcessingIndicator = 'docs_processing_indicator';

  // Document Results
  static const String docsResultContainer = 'docs_result_container';
  static const String docsResultModeLabel = 'docs_result_mode_label';
  static const String docsResultText = 'docs_result_text';
  static const String docsExportButton = 'docs_export_button';

  // Document History
  static const String docsHistoryScreen = 'docs_history_screen';
  static const String docsHistoryBackButton = 'docs_history_back_button';
  static String docsHistoryItem(String id) => 'docs_history_item_$id';
  static const String docsHistoryItemMode = 'docs_history_item_mode';
  static const String docsHistoryItemFilename = 'docs_history_item_filename';
  static const String docsHistoryItemPreview = 'docs_history_item_preview';
  static const String docsHistoryThreadView = 'docs_history_thread_view';
  static const String docsHistoryThreadResult = 'docs_history_thread_result';

  // Navigation Tags
  static const String navBottomBar = 'nav_bottom_bar';
  static const String navBottomBarVoice = 'nav_bottom_bar_voice';
  static const String navBottomBarVision = 'nav_bottom_bar_vision';
  static const String navBottomBarDocs = 'nav_bottom_bar_docs';

  // Common Widget Tags
  static const String commonConnectivityBanner = 'common_connectivity_banner';
  static const String commonOfflineIndicator = 'common_offline_indicator';
  static const String commonLoadingIndicator = 'common_loading_indicator';
  static const String commonErrorBanner = 'common_error_banner';
  static const String commonErrorRetryButton = 'common_error_retry_button';
  static String commonLanguageFlag(String code) => 'common_language_flag_$code';
  static const String commonHeader = 'common_header';
  static const String commonHeaderTitle = 'common_header_title';
  static const String commonHeaderLocation = 'common_header_location';
  static const String commonHeaderAiProBadge = 'common_header_ai_pro_badge';
}

