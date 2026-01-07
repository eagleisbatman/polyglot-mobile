# Polyglot Mobile

A Flutter mobile application for real-time translation across Voice, Vision, and Documents using Google Gemini AI.

## Features

- **Voice Translation**: Real-time bidirectional voice translation
- **Vision Translation**: Camera capture and image translation
- **Document Translation**: Upload and translate/summarize documents

## Technology Stack

- **Framework**: Flutter 3.38+ (Dart 3.10+)
- **State Management**: Riverpod
- **Navigation**: go_router
- **Network**: dio (HTTP client)
- **Localization**: flutter_localizations + intl (14 languages)
- **Testing**: patrol (E2E), alchemist (golden), flutter_test
- **Design**: Material You (Material 3)

## Setup

### Prerequisites

- Flutter SDK 3.38 or higher
- Dart SDK 3.10 or higher
- iOS Simulator / Android Emulator or physical device

### Installation

1. Clone the repository
2. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env and add your API_BASE_URL
   ```

5. Generate localization files:
   ```bash
   flutter gen-l10n
   ```

## Running the App

### Development

```bash
flutter run
```

### Run Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/
```

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── network/
│   ├── services/
│   └── utils/
├── features/
│   ├── voice_translation/
│   ├── vision_translation/
│   └── document_translation/
├── shared/
│   ├── widgets/
│   └── models/
└── localization/
```

## Configuration

### Environment Variables

Create `.env` file in `mobile/` directory:
```
API_BASE_URL=https://your-backend.up.railway.app
CLERK_PUBLISHABLE_KEY=pk_test_...  # For Clerk auth (planned)
```

The app will use mock data if `API_BASE_URL` is empty or the backend is unavailable.

### Authentication

**Current**: Custom JWT authentication (fully functional)  
**Planned**: Migrating to Clerk managed authentication (see `docs/CLERK_AUTH_PLAN.md`)

## Supported Languages

English, Hindi, Spanish, French, German, Chinese, Japanese, Korean, Portuguese, Italian, Russian, Arabic, Vietnamese, Thai

## Permissions

The app requires the following permissions:

- **Microphone**: For voice translation
- **Camera**: For vision translation
- **Location**: For auto language detection
- **Storage**: For document uploads

## Testing

- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `integration_test/`

## Building

### iOS

```bash
flutter build ios
```

### Android

```bash
flutter build apk
# or
flutter build appbundle
```

## License

See LICENSE file for details.

