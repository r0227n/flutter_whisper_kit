import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin registration test', (WidgetTester tester) async {
    // Register the Apple implementation
    FlutterWhisperkitApple.registerWith();
    // Create plugin instance
    final FlutterWhisperkitApple plugin = FlutterWhisperkitApple();
    // Verify plugin instance can be created
    expect(plugin, isNotNull);
  });
}
