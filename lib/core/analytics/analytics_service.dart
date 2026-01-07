import 'package:flutter/foundation.dart';
import 'analytics_events.dart';

/// Analytics service for tracking user events and enabling A/B testing
/// 
/// This service provides a unified interface for analytics tracking.
/// It can be extended to integrate with analytics providers like:
/// - Firebase Analytics
/// - PostHog
/// - Mixpanel
/// - Amplitude
/// - Custom analytics backend
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final List<AnalyticsProvider> _providers = [];
  String? _userId;
  String? _sessionId;
  final Map<String, dynamic> _userProperties = {};
  final Map<String, dynamic> _sessionProperties = {};

  /// Initialize analytics service
  void initialize({
    List<AnalyticsProvider>? providers,
    String? userId,
  }) {
    _providers.addAll(providers ?? []);
    _userId = userId;
    _sessionId = _generateSessionId();
    _logEvent(AnalyticsEvents.appLaunched);
  }

  /// Set user ID for tracking
  void setUserId(String userId) {
    _userId = userId;
    for (final provider in _providers) {
      provider.setUserId(userId);
    }
  }

  /// Set user properties
  void setUserProperty(String key, dynamic value) {
    _userProperties[key] = value;
    for (final provider in _providers) {
      provider.setUserProperty(key, value);
    }
  }

  /// Set multiple user properties
  void setUserProperties(Map<String, dynamic> properties) {
    _userProperties.addAll(properties);
    for (final provider in _providers) {
      provider.setUserProperties(properties);
    }
  }

  /// Track an event
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) {
    final eventProperties = <String, dynamic>{
      ...?properties,
      AnalyticsProperties.sessionId: _sessionId,
      AnalyticsProperties.timestamp: DateTime.now().toIso8601String(),
      if (_userId != null) AnalyticsProperties.userId: _userId!,
    };

    _logEvent(eventName, properties: eventProperties);

    for (final provider in _providers) {
      provider.trackEvent(eventName, properties: eventProperties);
    }
  }

  /// Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    trackEvent(
      'screen_view',
      properties: {
        AnalyticsProperties.screen: screenName,
        ...?properties,
      },
    );
  }

  /// Track A/B test exposure
  void trackABTestExposure({
    required String testName,
    required String variant,
    String? variantGroup,
    Map<String, dynamic>? properties,
  }) {
    trackEvent(
      AnalyticsEvents.abTestExposed,
      properties: {
        AnalyticsProperties.testName: testName,
        AnalyticsProperties.variant: variant,
        if (variantGroup != null) AnalyticsProperties.variantGroup: variantGroup,
        ...?properties,
      },
    );
  }

  /// Track A/B test conversion
  void trackABTestConversion({
    required String testName,
    required String variant,
    required String conversionGoal,
    Map<String, dynamic>? properties,
  }) {
    trackEvent(
      AnalyticsEvents.abTestConversion,
      properties: {
        AnalyticsProperties.testName: testName,
        AnalyticsProperties.variant: variant,
        AnalyticsProperties.conversionGoal: conversionGoal,
        ...?properties,
      },
    );
  }

  /// Track performance metric
  void trackPerformance({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? properties,
  }) {
    trackEvent(
      'performance_$metricName',
      properties: {
        'value': value,
        if (unit != null) 'unit': unit,
        ...?properties,
      },
    );
  }

  /// Track error
  void trackError({
    required String errorType,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? properties,
  }) {
    trackEvent(
      'error_$errorType',
      properties: {
        AnalyticsProperties.errorMessage: errorMessage,
        AnalyticsProperties.errorType: errorType,
        if (errorCode != null) AnalyticsProperties.errorCode: errorCode,
        ...?properties,
      },
    );
  }

  /// Start a timed event
  void startTimedEvent(String eventName) {
    _timedEvents[eventName] = DateTime.now();
  }

  /// End a timed event and track duration
  void endTimedEvent(String eventName, {Map<String, dynamic>? properties}) {
    final startTime = _timedEvents.remove(eventName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      trackEvent(
        eventName,
        properties: {
          AnalyticsProperties.duration: duration,
          ...?properties,
        },
      );
    }
  }

  final Map<String, DateTime> _timedEvents = {};

  /// Set session property
  void setSessionProperty(String key, dynamic value) {
    _sessionProperties[key] = value;
  }

  /// Clear session
  void clearSession() {
    _sessionId = _generateSessionId();
    _sessionProperties.clear();
    trackEvent(AnalyticsEvents.sessionEnd);
  }

  /// Log event to console (for debugging)
  void _logEvent(String eventName, {Map<String, dynamic>? properties}) {
    if (kDebugMode) {
      debugPrint('Analytics Event: $eventName');
      if (properties != null && properties.isNotEmpty) {
        debugPrint('Properties: $properties');
      }
    }
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().hashCode}';
  }

  /// Get current session ID
  String? get sessionId => _sessionId;

  /// Get current user ID
  String? get userId => _userId;
}

/// Abstract base class for analytics providers
abstract class AnalyticsProvider {
  void trackEvent(String eventName, {Map<String, dynamic>? properties});
  void setUserId(String userId);
  void setUserProperty(String key, dynamic value);
  void setUserProperties(Map<String, dynamic> properties);
}

/// Console provider for debugging (logs to console)
class ConsoleAnalyticsProvider implements AnalyticsProvider {
  @override
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    if (kDebugMode) {
      debugPrint('[Analytics] Event: $eventName');
      if (properties != null) {
        debugPrint('[Analytics] Properties: $properties');
      }
    }
  }

  @override
  void setUserId(String userId) {
    if (kDebugMode) {
      debugPrint('[Analytics] User ID: $userId');
    }
  }

  @override
  void setUserProperty(String key, dynamic value) {
    if (kDebugMode) {
      debugPrint('[Analytics] User Property: $key = $value');
    }
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    if (kDebugMode) {
      debugPrint('[Analytics] User Properties: $properties');
    }
  }
}

