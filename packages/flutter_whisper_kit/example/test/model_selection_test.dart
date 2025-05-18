import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit_example/main.dart';

// Import removed to fix unused import warning

void main() {
  group('ModelSelectionDropdown', () {
    testWidgets('displays correct initial model', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ModelSelectionDropdown(
              selectedModel: 'tiny-en',
              modelVariants: const ['tiny-en', 'base', 'small'],
              onModelChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the selected model is displayed
      expect(find.text('tiny-en'), findsOneWidget);
    });

    testWidgets('calls onModelChanged when selection changes', (
      WidgetTester tester,
    ) async {
      String selectedModel = 'tiny-en';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ModelSelectionDropdown(
              selectedModel: selectedModel,
              modelVariants: const ['tiny-en', 'base', 'small'],
              onModelChanged: (String newModel) {
                selectedModel = newModel;
              },
            ),
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select 'base' from the dropdown
      await tester.tap(find.text('base').last);
      await tester.pumpAndSettle();

      // Verify the selectedModel was updated
      expect(selectedModel, 'base');
    });
  });

  group('LanguageSelectionDropdown', () {
    testWidgets('displays correct initial language', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: LanguageSelectionDropdown(
              selectedLanguage: 'en',
              onLanguageChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the selected language is displayed (in dropdown format)
      expect(find.text('en (English)'), findsOneWidget);
    });

    testWidgets('calls onLanguageChanged when selection changes', (
      WidgetTester tester,
    ) async {
      String selectedLanguage = 'en';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: LanguageSelectionDropdown(
              selectedLanguage: selectedLanguage,
              onLanguageChanged: (String newLanguage) {
                selectedLanguage = newLanguage;
              },
            ),
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select 'ja (Japanese)' from the dropdown
      await tester.tap(find.text('ja (Japanese)').last);
      await tester.pumpAndSettle();

      // Verify the selectedLanguage was updated
      expect(selectedLanguage, 'ja');
    });
  });
}
