import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/voice_api_service.dart';
import '../../lib/core/services/vision_api_service.dart';
import '../../lib/core/services/document_api_service.dart';
import '../../lib/core/services/audio_service.dart';

class MockVoiceApiService extends Mock implements VoiceApiService {}

class MockVisionApiService extends Mock implements VisionApiService {}

class MockDocumentApiService extends Mock implements DocumentApiService {}

class MockAudioService extends Mock implements AudioService {}

