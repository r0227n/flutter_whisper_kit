import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _whisperKitStatus = 'Not initialized';
  String _availableModels = 'Unknown';
  bool _isInitializing = false;
  final _flutterWhisperkitApplePlugin = FlutterWhisperkitApple();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterWhisperkitApplePlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _initializeWhisperKit() async {
    setState(() {
      _isInitializing = true;
      _whisperKitStatus = 'Initializing...';
    });

    try {
      // Create a configuration for WhisperKit
      final config = WhisperKitConfig(
        enableVAD: true,
        vadFallbackSilenceThreshold: 600,
        vadTemperature: 0.15,
        enableLanguageIdentification: true,
      );

      // Initialize WhisperKit with the configuration
      final result = await _flutterWhisperkitApplePlugin.initializeWhisperKit(config: config);
      
      setState(() {
        _whisperKitStatus = result ? 'Initialized successfully' : 'Initialization failed';
      });

      // Get available models
      if (result) {
        final models = await _flutterWhisperkitApplePlugin.getAvailableModels();
        setState(() {
          _availableModels = models.join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _whisperKitStatus = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhisperKit Example'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('WhisperKit Integration Demo', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Status: $_whisperKitStatus',
                style: TextStyle(
                  fontSize: 16,
                  color: _whisperKitStatus.contains('success') ? Colors.green : 
                         _whisperKitStatus.contains('Error') ? Colors.red : Colors.black,
                )),
              const SizedBox(height: 10),
              Text('Available Models: $_availableModels', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isInitializing ? null : _initializeWhisperKit,
                child: _isInitializing 
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Initializing...'),
                      ],
                    )
                  : const Text('Initialize WhisperKit'),
              ),
              const SizedBox(height: 20),
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WhisperKit Configuration', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('• Voice Activity Detection (VAD): Enabled'),
                      Text('• VAD Fallback Silence Threshold: 600ms'),
                      Text('• VAD Temperature: 0.15'),
                      Text('• Language Identification: Enabled'),
                      SizedBox(height: 10),
                      Text('This example demonstrates the initialization of WhisperKit v0.12.0 '
                           'using Swift Package Manager for iOS and macOS platforms.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
