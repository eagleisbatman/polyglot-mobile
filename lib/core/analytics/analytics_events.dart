/// Comprehensive analytics events for usage tracking and A/B testing
class AnalyticsEvents {
  AnalyticsEvents._();

  // ==================== App Lifecycle Events ====================
  static const String appLaunched = 'app_launched';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';
  static const String appTerminated = 'app_terminated';

  // ==================== Screen View Events ====================
  static const String screenVoiceTranslation = 'screen_voice_translation';
  static const String screenVisionTranslation = 'screen_vision_translation';
  static const String screenDocumentTranslation = 'screen_document_translation';
  static const String screenVoiceHistory = 'screen_voice_history';
  static const String screenVisionHistory = 'screen_vision_history';
  static const String screenDocumentHistory = 'screen_document_history';
  static const String screenSettings = 'screen_settings';
  static const String screenLanguageSelector = 'screen_language_selector';

  // ==================== Voice Translation Events ====================
  static const String newSessionStarted = 'new_session_started';
  static const String voiceRecordingStarted = 'voice_recording_started';
  static const String voiceRecordingStopped = 'voice_recording_stopped';
  static const String voiceRecordingCancelled = 'voice_recording_cancelled';
  static const String voiceTranslationRequested = 'voice_translation_requested';
  static const String voiceTranslationCompleted = 'voice_translation_completed';
  static const String voiceTranslationFailed = 'voice_translation_failed';
  static const String voiceLanguageChanged = 'voice_language_changed';
  static const String voiceLanguageSwapped = 'voice_language_swapped';
  static const String voiceFollowUpQuestionSelected = 'voice_follow_up_question_selected';
  static const String voiceSessionSummaryViewed = 'voice_session_summary_viewed';
  static const String voiceHistoryItemViewed = 'voice_history_item_viewed';
  static const String voiceHistoryItemDeleted = 'voice_history_item_deleted';
  static const String voiceHistoryCleared = 'voice_history_cleared';
  static const String voiceLanguageMismatchDetected = 'voice_language_mismatch_detected';
  static const String voiceLanguageMismatchAdjusted = 'voice_language_mismatch_adjusted';
  static const String voiceAudioPlaybackStarted = 'voice_audio_playback_started';
  static const String voiceAudioPlaybackStopped = 'voice_audio_playback_stopped';

  // ==================== Vision Translation Events ====================
  static const String visionCameraOpened = 'vision_camera_opened';
  static const String visionImageCaptured = 'vision_image_captured';
  static const String visionImagePickedFromGallery = 'vision_image_picked_from_gallery';
  static const String visionImageDiscarded = 'vision_image_discarded';
  static const String visionTranslationRequested = 'vision_translation_requested';
  static const String visionTranslationCompleted = 'vision_translation_completed';
  static const String visionTranslationFailed = 'vision_translation_failed';
  static const String visionTargetLanguageChanged = 'vision_target_language_changed';
  static const String visionHistoryItemViewed = 'vision_history_item_viewed';
  static const String visionHistoryItemDeleted = 'vision_history_item_deleted';
  static const String visionHistoryCleared = 'vision_history_cleared';
  static const String visionImageShared = 'vision_image_shared';
  static const String visionTranslationCopied = 'vision_translation_copied';

  // ==================== Document Translation Events ====================
  static const String documentFilePickerOpened = 'document_file_picker_opened';
  static const String documentFileSelected = 'document_file_selected';
  static const String documentFileRemoved = 'document_file_removed';
  static const String documentModeChanged = 'document_mode_changed';
  static const String documentTranslationRequested = 'document_translation_requested';
  static const String documentSummarizationRequested = 'document_summarization_requested';
  static const String documentTranslationCompleted = 'document_translation_completed';
  static const String documentSummarizationCompleted = 'document_summarization_completed';
  static const String documentProcessingFailed = 'document_processing_failed';
  static const String documentTargetLanguageChanged = 'document_target_language_changed';
  static const String documentExported = 'document_exported';
  static const String documentHistoryItemViewed = 'document_history_item_viewed';
  static const String documentHistoryItemDeleted = 'document_history_item_deleted';
  static const String documentHistoryCleared = 'document_history_cleared';
  static const String documentPreviewViewed = 'document_preview_viewed';

  // ==================== Navigation Events ====================
  static const String navBottomBarVoiceTapped = 'nav_bottom_bar_voice_tapped';
  static const String navBottomBarVisionTapped = 'nav_bottom_bar_vision_tapped';
  static const String navBottomBarDocumentsTapped = 'nav_bottom_bar_documents_tapped';
  static const String navHistoryButtonTapped = 'nav_history_button_tapped';
  static const String navBackButtonTapped = 'nav_back_button_tapped';

  // ==================== Language Selection Events ====================
  static const String languageSelectorOpened = 'language_selector_opened';
  static const String languageSelected = 'language_selected';
  static const String languageSearchPerformed = 'language_search_performed';
  static const String languageAutoDetected = 'language_auto_detected';

  // ==================== Permission Events ====================
  static const String permissionMicrophoneRequested = 'permission_microphone_requested';
  static const String permissionMicrophoneGranted = 'permission_microphone_granted';
  static const String permissionMicrophoneDenied = 'permission_microphone_denied';
  static const String permissionCameraRequested = 'permission_camera_requested';
  static const String permissionCameraGranted = 'permission_camera_granted';
  static const String permissionCameraDenied = 'permission_camera_denied';
  static const String permissionLocationRequested = 'permission_location_requested';
  static const String permissionLocationGranted = 'permission_location_granted';
  static const String permissionLocationDenied = 'permission_location_denied';
  static const String permissionStorageRequested = 'permission_storage_requested';
  static const String permissionStorageGranted = 'permission_storage_granted';
  static const String permissionStorageDenied = 'permission_storage_denied';

  // ==================== Error Events ====================
  static const String errorNetworkTimeout = 'error_network_timeout';
  static const String errorNetworkUnavailable = 'error_network_unavailable';
  static const String errorServerError = 'error_server_error';
  static const String errorRateLimitExceeded = 'error_rate_limit_exceeded';
  static const String errorValidationFailed = 'error_validation_failed';
  static const String errorAudioRecordingFailed = 'error_audio_recording_failed';
  static const String errorImageProcessingFailed = 'error_image_processing_failed';
  static const String errorDocumentProcessingFailed = 'error_document_processing_failed';
  static const String errorRetryAttempted = 'error_retry_attempted';
  static const String errorDismissed = 'error_dismissed';

  // ==================== Connectivity Events ====================
  static const String connectivityOnline = 'connectivity_online';
  static const String connectivityOffline = 'connectivity_offline';
  static const String connectivityChanged = 'connectivity_changed';
  static const String offlineModeEntered = 'offline_mode_entered';
  static const String offlineModeExited = 'offline_mode_exited';

  // ==================== Performance Events ====================
  static const String performanceTranslationLatency = 'performance_translation_latency';
  static const String performanceImageProcessingTime = 'performance_image_processing_time';
  static const String performanceDocumentProcessingTime = 'performance_document_processing_time';
  static const String performanceAudioRecordingDuration = 'performance_audio_recording_duration';
  static const String performanceScreenLoadTime = 'performance_screen_load_time';
  static const String performanceApiResponseTime = 'performance_api_response_time';

  // ==================== User Engagement Events ====================
  static const String engagementSessionStarted = 'engagement_session_started';
  static const String engagementSessionEnded = 'engagement_session_ended';
  static const String engagementFeatureDiscovered = 'engagement_feature_discovered';
  static const String engagementTutorialStarted = 'engagement_tutorial_started';
  static const String engagementTutorialCompleted = 'engagement_tutorial_completed';
  static const String engagementTutorialSkipped = 'engagement_tutorial_skipped';
  static const String engagementOnboardingCompleted = 'engagement_onboarding_completed';
  static const String engagementOnboardingSkipped = 'engagement_onboarding_skipped';

  // ==================== Feature Usage Events ====================
  static const String featureVoiceFirstUse = 'feature_voice_first_use';
  static const String featureVisionFirstUse = 'feature_vision_first_use';
  static const String featureDocumentFirstUse = 'feature_document_first_use';
  static const String featureVoiceDailyActive = 'feature_voice_daily_active';
  static const String featureVisionDailyActive = 'feature_vision_daily_active';
  static const String featureDocumentDailyActive = 'feature_document_daily_active';
  static const String featureVoiceWeeklyActive = 'feature_voice_weekly_active';
  static const String featureVisionWeeklyActive = 'feature_vision_weekly_active';
  static const String featureDocumentWeeklyActive = 'feature_document_weekly_active';

  // ==================== A/B Testing Events ====================
  static const String abTestExposed = 'ab_test_exposed';
  static const String abTestConversion = 'ab_test_conversion';
  static const String abTestVariantAssigned = 'ab_test_variant_assigned';

  // ==================== User Behavior Events ====================
  static const String behaviorTranslationFlowStarted = 'behavior_translation_flow_started';
  static const String behaviorTranslationFlowCompleted = 'behavior_translation_flow_completed';
  static const String behaviorTranslationFlowAbandoned = 'behavior_translation_flow_abandoned';
  static const String behaviorMultipleLanguagesUsed = 'behavior_multiple_languages_used';
  static const String behaviorLanguagePairFrequency = 'behavior_language_pair_frequency';
  static const String behaviorFeatureSwitching = 'behavior_feature_switching';
  static const String behaviorHistoryUsage = 'behavior_history_usage';
  static const String behaviorSearchPerformed = 'behavior_search_performed';
  static const String behaviorShareAction = 'behavior_share_action';
  static const String behaviorCopyAction = 'behavior_copy_action';

  // ==================== Settings Events ====================
  static const String settingsOpened = 'settings_opened';
  static const String settingsThemeChanged = 'settings_theme_changed';
  static const String settingsLanguageChanged = 'settings_language_changed';
  static const String settingsNotificationsToggled = 'settings_notifications_toggled';
  static const String settingsAutoDetectLanguageToggled = 'settings_auto_detect_language_toggled';
  static const String settingsCacheCleared = 'settings_cache_cleared';
  static const String settingsDataDeleted = 'settings_data_deleted';
  static const String settingsAboutViewed = 'settings_about_viewed';
  static const String settingsPrivacyViewed = 'settings_privacy_viewed';
  static const String settingsTermsViewed = 'settings_terms_viewed';

  // ==================== Content Interaction Events ====================
  static const String contentTranscriptionViewed = 'content_transcription_viewed';
  static const String contentTranslationViewed = 'content_translation_viewed';
  static const String contentSummaryViewed = 'content_summary_viewed';
  static const String contentFollowUpQuestionViewed = 'content_follow_up_question_viewed';
  static const String contentImageViewed = 'content_image_viewed';
  static const String contentDocumentViewed = 'content_document_viewed';
  static const String contentLongPressed = 'content_long_pressed';
  static const String contentSelected = 'content_selected';

  // ==================== Search & Filter Events ====================
  static const String searchHistoryPerformed = 'search_history_performed';
  static const String searchLanguagePerformed = 'search_language_performed';
  static const String filterHistoryApplied = 'filter_history_applied';
  static const String filterHistoryCleared = 'filter_history_cleared';
  static const String sortHistoryChanged = 'sort_history_changed';

  // ==================== Export & Share Events ====================
  static const String exportTranslation = 'export_translation';
  static const String exportDocument = 'export_document';
  static const String shareTranslation = 'share_translation';
  static const String shareImage = 'share_image';
  static const String shareDocument = 'share_document';
  static const String copyTranslation = 'copy_translation';
  static const String copyTranscription = 'copy_transcription';

  // ==================== Onboarding & Tutorial Events ====================
  static const String onboardingStepViewed = 'onboarding_step_viewed';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingStepSkipped = 'onboarding_step_skipped';
  static const String tutorialStepViewed = 'tutorial_step_viewed';
  static const String tutorialStepCompleted = 'tutorial_step_completed';
  static const String tutorialHintViewed = 'tutorial_hint_viewed';
  static const String tutorialHintDismissed = 'tutorial_hint_dismissed';

  // ==================== Feedback Events ====================
  static const String feedbackSubmitted = 'feedback_submitted';
  static const String feedbackRatingGiven = 'feedback_rating_given';
  static const String feedbackCommentAdded = 'feedback_comment_added';
  static const String feedbackBugReported = 'feedback_bug_reported';
  static const String feedbackFeatureRequested = 'feedback_feature_requested';

  // ==================== Retention Events ====================
  static const String retentionDay1 = 'retention_day_1';
  static const String retentionDay7 = 'retention_day_7';
  static const String retentionDay30 = 'retention_day_30';
  static const String retentionWeeklyActive = 'retention_weekly_active';
  static const String retentionMonthlyActive = 'retention_monthly_active';

  // ==================== Conversion Events ====================
  static const String conversionFirstTranslation = 'conversion_first_translation';
  static const String conversionFirstVoiceTranslation = 'conversion_first_voice_translation';
  static const String conversionFirstVisionTranslation = 'conversion_first_vision_translation';
  static const String conversionFirstDocumentTranslation = 'conversion_first_document_translation';
  static const String conversionTranslationCompleted = 'conversion_translation_completed';
  static const String conversionFeatureAdopted = 'conversion_feature_adopted';

  // ==================== Quality Events ====================
  static const String qualityTranslationRated = 'quality_translation_rated';
  static const String qualityTranslationReported = 'quality_translation_reported';
  static const String qualityAccuracyFeedback = 'quality_accuracy_feedback';
  static const String qualitySpeedFeedback = 'quality_speed_feedback';

  // ==================== Session Events ====================
  static const String sessionStart = 'session_start';
  static const String sessionEnd = 'session_end';
  static const String sessionDuration = 'session_duration';
  static const String sessionTranslationCount = 'session_translation_count';
  static const String sessionFeatureUsage = 'session_feature_usage';
}

/// Event properties keys for consistent property naming
class AnalyticsProperties {
  AnalyticsProperties._();

  // Common properties
  static const String language = 'language';
  static const String sourceLanguage = 'source_language';
  static const String targetLanguage = 'target_language';
  static const String languagePair = 'language_pair';
  static const String feature = 'feature';
  static const String screen = 'screen';
  static const String errorMessage = 'error_message';
  static const String errorCode = 'error_code';
  static const String errorType = 'error_type';
  static const String duration = 'duration';
  static const String timestamp = 'timestamp';
  static const String userId = 'user_id';
  static const String sessionId = 'session_id';

  // Voice specific
  static const String audioDuration = 'audio_duration';
  static const String audioSize = 'audio_size';
  static const String transcriptionLength = 'transcription_length';
  static const String translationLength = 'translation_length';
  static const String interactionId = 'interaction_id';
  static const String followUpQuestionId = 'follow_up_question_id';
  static const String detectedLanguage = 'detected_language';
  static const String languageMismatch = 'language_mismatch';

  // Vision specific
  static const String imageSize = 'image_size';
  static const String imageFormat = 'image_format';
  static const String imageSource = 'image_source'; // camera, gallery
  static const String confidence = 'confidence';
  static const String ocrTextLength = 'ocr_text_length';

  // Document specific
  static const String documentType = 'document_type';
  static const String documentSize = 'document_size';
  static const String documentMode = 'document_mode'; // translate, summarize
  static const String wordCount = 'word_count';
  static const String pageCount = 'page_count';

  // Performance
  static const String latency = 'latency';
  static const String responseTime = 'response_time';
  static const String processingTime = 'processing_time';
  static const String loadTime = 'load_time';

  // A/B Testing
  static const String testName = 'test_name';
  static const String variant = 'variant';
  static const String variantGroup = 'variant_group';
  static const String conversionGoal = 'conversion_goal';

  // User properties
  static const String userType = 'user_type'; // new, returning
  static const String deviceType = 'device_type';
  static const String osVersion = 'os_version';
  static const String appVersion = 'app_version';
  static const String connectivityType = 'connectivity_type'; // wifi, cellular, offline

  // Engagement
  static const String sessionDuration = 'session_duration';
  static const String translationsCount = 'translations_count';
  static const String featuresUsed = 'features_used';
  static const String screensViewed = 'screens_viewed';

  // Quality
  static const String rating = 'rating';
  static const String accuracy = 'accuracy';
  static const String speed = 'speed';
  static const String feedbackType = 'feedback_type';
}

