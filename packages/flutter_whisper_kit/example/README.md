# flutter_whisper_kit_example

Demonstrates how to use the flutter_whisper_kit plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android Configuration

### Minimum Requirements

The Flutter Whisper Kit plugin requires the following minimum Android configurations:

1. **Minimum SDK Version**: API 26 (Android 8.0)
   - Update `android/app/build.gradle.kts`:
   ```kotlin
   defaultConfig {
       minSdk = 26
       // ... other configurations
   }
   ```

2. **OnBackInvokedCallback Support** (for Android 13+)
   - Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application
       android:enableOnBackInvokedCallback="true"
       ... >
   ```

### Build Configuration

The following changes are automatically handled by the plugin but are documented here for reference:

1. **Dependencies**:
   - WhisperKit Android: `com.argmaxinc:whisperkit:0.3.2`
   - QNN Runtime: `com.qualcomm.qti:qnn-runtime:2.34.0`

2. **JNI Library Packaging**:
   ```gradle
   android {
       packaging {
           jniLibs {
               useLegacyPackaging = true
           }
       }
   }
   ```

### Troubleshooting

If you encounter build errors:

1. **Dependency Resolution**: Ensure your project uses Maven Central repository
2. **Clean Build**: Run `flutter clean && flutter pub get`
3. **Gradle Sync**: Sync your project with Gradle files in Android Studio
