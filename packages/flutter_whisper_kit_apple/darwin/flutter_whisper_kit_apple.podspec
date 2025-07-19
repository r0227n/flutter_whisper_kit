#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_whisper_kit_apple.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_whisper_kit_apple'
  s.version          = '0.2.0'
  s.summary          = 'iOS and macOS implementation of the flutter_whisper_kit plugin for on-device speech recognition.'
  s.description      = <<-DESC
iOS and macOS implementation of the flutter_whisper_kit plugin, providing on-device speech recognition and transcription capabilities using WhisperKit.
                       DESC
  s.homepage         = 'https://github.com/r0227n/flutter_whisper_kit/tree/main/flutter_whisper_kit_apple'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Ryo24'

  s.source           = { :path => '.' }
  s.source_files = 'flutter_whisper_kit_apple/Sources/flutter_whisper_kit_apple/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_whisperkit_apple_privacy' => ['flutter_whisper_kit_apple/Sources/flutter_whisper_kit_apple/PrivacyInfo.xcprivacy']}

  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  s.dependency 'FlutterMacOS'
  s.platform = :osx, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
