# WINCO Connect – Build & Release Instructions (Android & iOS)

This guide documents the procedures for compiling, testing, and packaging the **WINCO Connect** mobile application for Android and iOS.

---

## 1. Development Environment Prerequisites

- **Flutter SDK:** 3.24+ / 3.47+ (Stable Channel)
- **Dart SDK:** 3.5+ / 3.13+
- **Java Development Kit (JDK):** JDK 17 (Adoptium Temurin / OpenJDK)
- **Android Studio / Command Line Tools:** Android SDK API 34, Build-tools 34.0.0
- **Xcode (for iOS compilation):** Xcode 15+ on macOS with CocoaPods 1.14+

---

## 2. Project Setup & Dependency Installation

1. Navigate to the project root directory:
   ```bash
   cd "D:\HB\Winco Connect"
   ```
2. Retrieve Flutter packages:
   ```bash
   flutter pub get
   ```
3. Generate launcher icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```
4. Verify project diagnostics:
   ```bash
   flutter analyze
   flutter test
   ```

---

## 3. Environment Configuration

The application supports dual-mode architecture controlled via `lib/main.dart` or compile-time flags:

- **Mock / Offline Preview Mode (Default):**
  Uses realistic verified WINCO data matching `https://wincoconnect.com/` without network dependencies. Ideal for UI testing, local development, and App Store review inspection.
  ```dart
  // In lib/main.dart
  AppConfig.setConfig(AppConfig.mock);
  ```

- **Production Mode:**
  Connects directly to the live WINCO backend (`https://wincoconnect.com/api/v1`):
  ```dart
  // In lib/main.dart
  AppConfig.setConfig(AppConfig.production);
  ```

---

## 4. Android Build Instructions

### 4.1. Run on Connected Device or Emulator
```bash
flutter run -d android
```

### 4.2. Build Debug APK (For Internal Testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### 4.3. Build Production Signed Android App Bundle (.aab for Google Play Store)
1. Generate an upload keystore (if not already existing):
   ```bash
   keytool -genkey -v -keystore winco-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias winco_key
   ```
2. Configure `android/key.properties`:
   ```properties
   storePassword=<your_store_password>
   keyPassword=<your_key_password>
   keyAlias=winco_key
   storeFile=../winco-upload-keystore.jks
   ```
3. Compile the release bundle:
   ```bash
   flutter build appbundle --release
   ```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 5. iOS Build Instructions

### 5.1. Install CocoaPods Dependencies (on macOS)
```bash
cd ios
pod install
cd ..
```

### 5.2. Run on iOS Simulator or Connected iPhone
```bash
flutter run -d ios
```

### 5.3. Build Production iOS Archive / IPA (for Apple App Store)
```bash
flutter build ipa --release
```
Output: `build/ios/archive/Runner.xcarchive` and `build/ios/ipa/winco_connect.ipa`

Open `ios/Runner.xcworkspace` in Xcode to configure:
- **Team:** WINCO Developer Account Team ID
- **Bundle Identifier:** `com.wincoconnect.wincoConnect`
- **Signing Certificate:** Apple Distribution Certificate & App Store Provisioning Profile
- **Validate & Distribute App:** Upload directly to Apple TestFlight / App Store Connect.

---

## 6. Continuous Integration / Command Line Summary

| Task | Command |
|---|---|
| Analyze Codebase | `flutter analyze` |
| Execute Unit Tests | `flutter test` |
| Build Android APK | `flutter build apk --release` |
| Build Android AAB | `flutter build appbundle --release` |
| Build iOS IPA | `flutter build ipa --release` |
| Clean Build Cache | `flutter clean` |

