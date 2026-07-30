# Almared Mobile App

Open-source ecommerce mobile app for the Almared storefront, built with Flutter.

## Features

- Product browsing and search
- Cart and checkout
- Customer account and orders
- Push notifications (Firebase)
- Multi-language and multi-currency support

## Requirements

- Flutter SDK (see `pubspec.yaml` for Dart SDK constraints)
- Android Studio / Xcode for platform builds
- A configured GraphQL storefront endpoint

## Configuration

1. Clone the repository and install dependencies:

```bash
flutter pub get
```

2. Set your API endpoint and storefront key in [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart):

```dart
/// Almared API endpoint
const String almaredEndpoint = 'https://your-domain.com/graphql';

/// Storefront key for Almared API
const String storefrontKey = 'your_storefront_key_here';

/// Company name
const String companyName = 'Almared';
```

3. Confirm Firebase configs match package/bundle id `com.almared.app`:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/core/notifications/firebase_options.dart`

4. Run the app:

```bash
flutter run
```

## Branding

- Application name: **Almared**
- Android applicationId / iOS bundle id: `com.almared.app`
- In-app logo: `assets/images/almared_logo.svg`
- Android notification icon: `@drawable/ic_stat_almared`
- Notification channel: `almared_notifications`

## Documentation

Additional setup notes are available under the `Docs/` folder and `Configuration_guide.md`.

## License

MIT
