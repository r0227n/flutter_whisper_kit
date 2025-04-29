import 'package:flutter/material.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

void main() {
  // Register the Apple implementation
  FlutterWhisperkitApple.registerWith();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WhisperKit Example'),
        ),
        body: const Center(
          child: Text('Flutter WhisperKit Apple Plugin\n'),
        ),
      ),
    );
  }
}
