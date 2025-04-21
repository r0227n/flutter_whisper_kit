# Flutter WhisperKit Apple Example

This example demonstrates how to use the Flutter WhisperKit Apple plugin to load WhisperKit models and perform speech recognition.

## Required Settings

To run this example app, you need to configure the following settings:

### iOS Configuration

1. **Info.plist Settings**:
   - Add network permissions by adding `NSAppTransportSecurity` with `NSAllowsArbitraryLoads` set to `true`
   - Add the following usage descriptions:
     ```xml
     <key>NSLocalNetworkUsageDescription</key>
     <string>This app needs to access your local network to download WhisperKit models</string>
     <key>NSDownloadsFolderUsageDescription</key>
     <string>This app needs to access your Downloads folder to store WhisperKit models</string>
     <key>NSDocumentsFolderUsageDescription</key>
     <string>This app needs to access your Documents folder to store WhisperKit models</string>
     ```

2. **Entitlements**:
   - Create a `Runner.entitlements` file in the `ios/Runner` directory with the following content:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
         <key>com.apple.security.app-sandbox</key>
         <true/>
         <key>com.apple.security.network.client</key>
         <true/>
         <key>com.apple.security.files.downloads.read-write</key>
         <true/>
         <key>com.apple.security.files.user-selected.read-write</key>
         <true/>
     </dict>
     </plist>
     ```

### macOS Configuration

1. **Info.plist Settings**:
   - Add network permissions by adding `NSAppTransportSecurity` with `NSAllowsArbitraryLoads` set to `true`
   - Add the following usage descriptions:
     ```xml
     <key>NSDownloadsFolderUsageDescription</key>
     <string>This app needs to access your Downloads folder to store WhisperKit models</string>
     <key>NSDocumentsFolderUsageDescription</key>
     <string>This app needs to access your Documents folder to store WhisperKit models</string>
     <key>NSNetworkVolumesUsageDescription</key>
     <string>This app needs to access network volumes to store WhisperKit models</string>
     <key>NSDesktopFolderUsageDescription</key>
     <string>This app needs to access your Desktop folder to store WhisperKit models</string>
     ```

2. **Entitlements**:
   - Update both `DebugProfile.entitlements` and `Release.entitlements` in the `macos/Runner` directory to include:
     ```xml
     <key>com.apple.security.network.client</key>
     <true/>
     <key>com.apple.security.files.downloads.read-write</key>
     <true/>
     <key>com.apple.security.files.user-selected.read-write</key>
     <true/>
     ```

## Running the Example

1. Clone the repository
2. Navigate to the example directory: `cd packages/flutter_whisperkit_apple/example`
3. Run the app on iOS or macOS: `flutter run -d ios` or `flutter run -d macos`

## Features

The example app demonstrates:

- Loading WhisperKit models with progress tracking
- Selecting different model variants (tiny-en, base, small, etc.)
- Choosing between package directory and user folder storage
- Handling permission and download errors

## Troubleshooting

If you encounter the "Operation not permitted" error:
1. Check that all entitlements are properly configured
2. Verify that Info.plist contains all required usage descriptions
3. For macOS, ensure the app has permission to access the file system in System Preferences > Security & Privacy > Privacy
