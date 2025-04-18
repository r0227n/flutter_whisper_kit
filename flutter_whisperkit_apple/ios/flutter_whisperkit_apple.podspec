#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_whisperkit_apple'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for WhisperKit on iOS'
  s.description      = <<-DESC
A Flutter plugin that wraps WhisperKit for iOS/macOS for audio transcription.
                       DESC
  s.homepage         = 'https://github.com/yourusername/flutter_whisperkit_apple'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'your-email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  
  # WhisperKit依存関係（実際のバージョンとリポジトリを指定）
  # s.dependency 'WhisperKit', '~> 1.0'
  
  # プラットフォームの最小バージョン
  s.platform = :ios, '16.0'
  
  # Swift版のみ使用する場合
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end