import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/test_tags.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../localization/l10n/app_localizations.dart';

class BottomNavBar extends ConsumerWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      key: const Key(TestTags.navBottomBar),
      currentIndex: _getCurrentIndex(),
      onTap: (index) => _onTap(context, index, ref),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.mic),
          label: AppLocalizations.of(context)!.navVoice,
          tooltip: AppLocalizations.of(context)!.voiceTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt),
          label: AppLocalizations.of(context)!.navVision,
          tooltip: AppLocalizations.of(context)!.visionTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.description),
          label: AppLocalizations.of(context)!.navDocuments,
          tooltip: AppLocalizations.of(context)!.docsTitle,
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    switch (currentRoute) {
      case '/voice':
        return 0;
      case '/vision':
        return 1;
      case '/documents':
        return 2;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index, WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    switch (index) {
      case 0:
        analytics.trackEvent(AnalyticsEvents.navBottomBarVoiceTapped);
        context.go('/voice');
        break;
      case 1:
        analytics.trackEvent(AnalyticsEvents.navBottomBarVisionTapped);
        context.go('/vision');
        break;
      case 2:
        analytics.trackEvent(AnalyticsEvents.navBottomBarDocumentsTapped);
        context.go('/documents');
        break;
    }
  }
}

