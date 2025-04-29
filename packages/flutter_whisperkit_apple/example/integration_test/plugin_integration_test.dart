// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin registration test', (WidgetTester tester) async {
    // Register the Apple implementation
    FlutterWhisperkitApple.registerWith();
    
    // Verify the platform instance is correctly set
    expect(FlutterWhisperkitPlatform.instance, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
    
    // Create plugin instance
    final FlutterWhisperkitApple plugin = FlutterWhisperkitApple();
    
    // Verify plugin instance can be created
    expect(plugin, isNotNull);
  });
}
