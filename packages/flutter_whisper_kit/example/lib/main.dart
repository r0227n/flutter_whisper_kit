import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
// Import widget files
import 'package:flutter_whisper_kit_example/widgets/device_information_section.dart';
import 'package:flutter_whisper_kit_example/widgets/file_transcription_section.dart';
import 'package:flutter_whisper_kit_example/widgets/language_detection_section.dart';
import 'package:flutter_whisper_kit_example/widgets/model_configuration_section.dart';
import 'package:flutter_whisper_kit_example/widgets/model_discovery_section.dart';
import 'package:flutter_whisper_kit_example/widgets/real_time_transcription_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _asyncLoadModel;
  List<TranscriptionSegment> _transcriptionResult = [];
  String _transcriptionText = '';
  bool _isRecording = false;
  bool _isModelLoaded = false;

  // Added state variables for file transcription
  String _fileTranscriptionText = '';
  bool _isTranscribingFile = false;
  TranscriptionResult? _fileTranscriptionResult;

  // Added state variables for model and language selection
  String _selectedModel = 'tiny';
  String _selectedLanguage = 'en';

  // Model variants available for selection
  final List<String> _modelVariants = [
    'tiny',
    'tiny-en',
    'base',
    'small',
    'medium',
    'large-v2',
    'large-v3',
  ];

  // State variables for device information
  String _deviceNameResult = '';
  bool _isLoadingDeviceName = false;

  // State variables for model discovery
  List<String> _availableModels = [];
  bool _isLoadingAvailableModels = false;
  ModelSupport? _recommendedModels;
  bool _isLoadingRecommendedModels = false;
  ModelSupport? _recommendedRemoteModels;
  bool _isLoadingRecommendedRemoteModels = false;

  // State variables for language detection
  LanguageDetectionResult? _languageDetectionResult;
  bool _isDetectingLanguage = false;

  // State variables for model configuration
  List<String> _modelFilesToFormat = ['tiny.mlmodelc', 'base.mlmodelc'];
  List<String> _formattedModelFiles = [];
  bool _isFormattingModelFiles = false;
  ModelSupportConfig? _modelSupportConfig;
  bool _isLoadingModelSupportConfig = false;

  // NEW: State variables for additional model management functions
  bool _isSettingUpModels = false;
  String _setupModelsResult = '';
  bool _isDownloadingModel = false;
  String _downloadResult = '';
  bool _isPrewarmingModels = false;
  String _prewarmResult = '';
  bool _isUnloadingModels = false;
  String _unloadResult = '';
  bool _isClearingState = false;
  String _clearStateResult = '';
  bool _isSettingLogging = false;
  String _loggingResult = '';

  // NEW: State variables for Result-based API testing
  String _resultApiTest = '';
  bool _isTestingResultApi = false;

  // NEW: State variables for streams monitoring
  List<String> _streamEvents = [];
  int _progressEventCount = 0;
  int _transcriptionEventCount = 0;

  final _flutterWhisperkitPlugin = FlutterWhisperKit();
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;
  StreamSubscription<Progress>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _asyncLoadModel = _loadModel();
    _setupStreamMonitoring();
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }

  // NEW: Setup stream monitoring for detailed testing
  void _setupStreamMonitoring() {
    _progressSubscription = _flutterWhisperkitPlugin.modelProgressStream.listen(
      (progress) {
        setState(() {
          _progressEventCount++;
          _streamEvents.insert(
            0,
            'Progress: ${(progress.fractionCompleted * 100).toStringAsFixed(1)}% (Event #$_progressEventCount)',
          );
          if (_streamEvents.length > 10) {
            _streamEvents = _streamEvents.take(10).toList();
          }
        });
      },
      onError: (error) {
        setState(() {
          _streamEvents.insert(0, 'Progress Error: $error');
        });
      },
    );

    _transcriptionSubscription = _flutterWhisperkitPlugin.transcriptionStream
        .listen(
          (result) {
            setState(() {
              _transcriptionEventCount++;
              final truncatedText = result.text.length > 30
                  ? '${result.text.substring(0, 30)}...'
                  : result.text;
              _streamEvents.insert(
                0,
                'Transcription: "$truncatedText" (Event #$_transcriptionEventCount)',
              );
              if (_streamEvents.length > 10) {
                _streamEvents = _streamEvents.take(10).toList();
              }
            });
          },
          onError: (error) {
            setState(() {
              _streamEvents.insert(0, 'Transcription Error: $error');
            });
          },
        );
  }

  Future<String> _loadModel() async {
    try {
      final result = await _flutterWhisperkitPlugin.loadModel(
        _selectedModel,
        redownload: true,
        modelRepo: 'argmaxinc/whisperkit-coreml',
      );

      setState(() {
        _isModelLoaded = true;
      });

      return 'Model loaded: $result';
    } catch (e) {
      return 'Error loading model: $e';
    }
  }

  Future<void> _transcribeFromFile() async {
    if (!_isModelLoaded) {
      setState(() {
        _fileTranscriptionText = 'Please wait for the model to load first.';
      });
      return;
    }

    setState(() {
      _isTranscribingFile = true;
      _fileTranscriptionText = 'Transcribing file...';
    });

    try {
      final filePath = await FilePicker.platform.pickFiles().then(
        (file) => file?.files.firstOrNull?.path,
      );

      if (filePath == null) {
        setState(() {
          _fileTranscriptionText = 'No file picked';
        });
        return;
      }

      // Create custom decoding options
      final options = DecodingOptions(
        verbose: true,
        task: DecodingTask.transcribe,
        language: _selectedLanguage == 'auto'
            ? null
            : _selectedLanguage, // Use selected language or null for auto-detection
        temperature: 0.0,
        temperatureFallbackCount: 5,
        wordTimestamps: true,
        chunkingStrategy: ChunkingStrategy.vad,
      );

      final result = await _flutterWhisperkitPlugin.transcribeFromFile(
        filePath,
        options: options,
      );

      setState(() {
        _isTranscribingFile = false;
        _fileTranscriptionResult = result;
        _fileTranscriptionText = result?.text ?? 'No transcription result';
      });
    } catch (e) {
      setState(() {
        _isTranscribingFile = false;
        _fileTranscriptionText = 'Error transcribing file: $e';
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isModelLoaded) {
      setState(() {
        _transcriptionText = 'Please wait for the model to load first.';
        _transcriptionResult = [];
      });
      return;
    }

    try {
      if (_isRecording) {
        await _flutterWhisperkitPlugin.stopRecording();
        _transcriptionSubscription?.cancel();
      } else {
        // Create custom decoding options for real-time transcription
        final options = DecodingOptions(
          verbose: true,
          task: DecodingTask.transcribe,
          language: _selectedLanguage == 'auto'
              ? null
              : _selectedLanguage, // Use selected language or null for auto-detection
          temperature: 0.0,
          temperatureFallbackCount: 5,
          wordTimestamps: true,
          chunkingStrategy: ChunkingStrategy.vad,
        );

        await _flutterWhisperkitPlugin.startRecording(options: options);
        _transcriptionSubscription = _flutterWhisperkitPlugin
            .transcriptionStream
            .listen((result) {
              setState(() {
                _transcriptionText = result.text;
                // Only add segments that don't already exist in the result
                for (final segment in result.segments) {
                  if (!_transcriptionResult.any(
                    (existing) =>
                        existing.id == segment.id &&
                        existing.text == segment.text,
                  )) {
                    _transcriptionResult.add(segment);
                  }
                }
              });
            });
      }

      setState(() {
        _isRecording = !_isRecording;
      });
    } catch (e) {
      setState(() {
        _transcriptionText = 'Error: $e';
        _transcriptionResult = [];
      });
    }
  }

  // Device Information Methods
  Future<void> _getDeviceName() async {
    setState(() {
      _isLoadingDeviceName = true;
      _deviceNameResult = 'Loading device name...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.deviceName();
      setState(() {
        _deviceNameResult = result;
      });
    } catch (e) {
      setState(() {
        _deviceNameResult = 'Error getting device name: $e';
      });
    } finally {
      setState(() {
        _isLoadingDeviceName = false;
      });
    }
  }

  // Model Discovery Methods
  Future<void> _fetchAvailableModels() async {
    setState(() {
      _isLoadingAvailableModels = true;
      _availableModels = [];
    });

    try {
      final models = await _flutterWhisperkitPlugin.fetchAvailableModels(
        modelRepo: 'argmaxinc/whisperkit-coreml',
        matching: ['*'],
      );
      setState(() {
        _availableModels = models;
      });
    } catch (e) {
      setState(() {
        _availableModels = ['Error fetching models: $e'];
      });
    } finally {
      setState(() {
        _isLoadingAvailableModels = false;
      });
    }
  }

  Future<void> _getRecommendedModels() async {
    setState(() {
      _isLoadingRecommendedModels = true;
      _recommendedModels = null;
    });

    try {
      final result = await _flutterWhisperkitPlugin.recommendedModels();
      setState(() {
        _recommendedModels = result;
      });
    } catch (e) {
      setState(() {
        // Create an error model support
        _recommendedModels = ModelSupport(
          defaultModel: 'Error',
          supported: ['Error getting recommended models: $e'],
          disabled: [],
        );
      });
    } finally {
      setState(() {
        _isLoadingRecommendedModels = false;
      });
    }
  }

  Future<void> _getRecommendedRemoteModels() async {
    setState(() {
      _isLoadingRecommendedRemoteModels = true;
      _recommendedRemoteModels = null;
    });

    try {
      final result = await _flutterWhisperkitPlugin.recommendedRemoteModels();
      setState(() {
        _recommendedRemoteModels = result;
      });
    } catch (e) {
      setState(() {
        // Create an error model support
        _recommendedRemoteModels = ModelSupport(
          defaultModel: 'Error',
          supported: ['Error getting recommended remote models: $e'],
          disabled: [],
        );
      });
    } finally {
      setState(() {
        _isLoadingRecommendedRemoteModels = false;
      });
    }
  }

  // Language Detection Methods
  Future<void> _detectLanguage() async {
    if (!_isModelLoaded) {
      setState(() {
        _languageDetectionResult = null;
      });
      return;
    }

    setState(() {
      _isDetectingLanguage = true;
    });

    try {
      final filePath = await FilePicker.platform.pickFiles().then(
        (file) => file?.files.firstOrNull?.path,
      );

      if (filePath == null) {
        setState(() {
          _isDetectingLanguage = false;
        });
        return;
      }

      final result = await _flutterWhisperkitPlugin.detectLanguage(filePath);
      setState(() {
        _languageDetectionResult = result;
      });
    } catch (e) {
      setState(() {
        // Create an error language detection result
        _languageDetectionResult = LanguageDetectionResult(
          language: 'Error',
          probabilities: {'error': 1.0},
        );
      });
    } finally {
      setState(() {
        _isDetectingLanguage = false;
      });
    }
  }

  // Model Configuration Methods
  Future<void> _formatModelFiles() async {
    setState(() {
      _isFormattingModelFiles = true;
      _formattedModelFiles = [];
    });

    try {
      final result = await _flutterWhisperkitPlugin.formatModelFiles(
        _modelFilesToFormat,
      );
      setState(() {
        _formattedModelFiles = result;
      });
    } catch (e) {
      setState(() {
        _formattedModelFiles = ['Error formatting model files: $e'];
      });
    } finally {
      setState(() {
        _isFormattingModelFiles = false;
      });
    }
  }

  Future<void> _fetchModelSupportConfig() async {
    setState(() {
      _isLoadingModelSupportConfig = true;
      _modelSupportConfig = null;
    });

    try {
      final result = await _flutterWhisperkitPlugin.fetchModelSupportConfig();
      setState(() {
        _modelSupportConfig = result;
      });
    } catch (e) {
      setState(() {
        // We can't create a proper error ModelSupportConfig, so we'll just set it to null
        _modelSupportConfig = null;
      });
    } finally {
      setState(() {
        _isLoadingModelSupportConfig = false;
      });
    }
  }

  // NEW: Additional Model Management Functions
  Future<void> _setupModels() async {
    setState(() {
      _isSettingUpModels = true;
      _setupModelsResult = 'Setting up models...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.setupModels(
        model: _selectedModel,
        download: true,
        modelRepo: 'argmaxinc/whisperkit-coreml',
      );
      setState(() {
        _setupModelsResult = 'Setup successful: $result';
      });
    } catch (e) {
      setState(() {
        _setupModelsResult = 'Setup failed: $e';
      });
    } finally {
      setState(() {
        _isSettingUpModels = false;
      });
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloadingModel = true;
      _downloadResult = 'Downloading model...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.download(
        variant: _selectedModel,
        repo: 'argmaxinc/whisperkit-coreml',
        onProgress: (progress) {
          setState(() {
            _downloadResult =
                'Downloading: ${(progress.fractionCompleted * 100).toStringAsFixed(1)}%';
          });
        },
      );
      setState(() {
        _downloadResult = 'Download successful: $result';
      });
    } catch (e) {
      setState(() {
        _downloadResult = 'Download failed: $e';
      });
    } finally {
      setState(() {
        _isDownloadingModel = false;
      });
    }
  }

  Future<void> _prewarmModels() async {
    setState(() {
      _isPrewarmingModels = true;
      _prewarmResult = 'Prewarming models...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.prewarmModels();
      setState(() {
        _prewarmResult = 'Prewarm successful: $result';
      });
    } catch (e) {
      setState(() {
        _prewarmResult = 'Prewarm failed: $e';
      });
    } finally {
      setState(() {
        _isPrewarmingModels = false;
      });
    }
  }

  Future<void> _unloadModels() async {
    setState(() {
      _isUnloadingModels = true;
      _unloadResult = 'Unloading models...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.unloadModels();
      setState(() {
        _unloadResult = 'Unload successful: $result';
        _isModelLoaded = false; // Update model loaded state
      });
    } catch (e) {
      setState(() {
        _unloadResult = 'Unload failed: $e';
      });
    } finally {
      setState(() {
        _isUnloadingModels = false;
      });
    }
  }

  Future<void> _clearState() async {
    setState(() {
      _isClearingState = true;
      _clearStateResult = 'Clearing state...';
    });

    try {
      final result = await _flutterWhisperkitPlugin.clearState();
      setState(() {
        _clearStateResult = 'Clear state successful: $result';
        // Reset transcription state
        _transcriptionResult = [];
        _transcriptionText = '';
      });
    } catch (e) {
      setState(() {
        _clearStateResult = 'Clear state failed: $e';
      });
    } finally {
      setState(() {
        _isClearingState = false;
      });
    }
  }

  Future<void> _setLoggingCallback() async {
    setState(() {
      _isSettingLogging = true;
      _loggingResult = 'Setting logging callback...';
    });

    try {
      await _flutterWhisperkitPlugin.loggingCallback(level: 'debug');
      setState(() {
        _loggingResult = 'Logging callback set successfully';
      });
    } catch (e) {
      setState(() {
        _loggingResult = 'Set logging failed: $e';
      });
    } finally {
      setState(() {
        _isSettingLogging = false;
      });
    }
  }

  // NEW: Result-based API Testing
  Future<void> _testResultApi() async {
    setState(() {
      _isTestingResultApi = true;
      _resultApiTest = 'Testing Result-based APIs...\n\n';
    });

    // Test loadModelWithResult
    setState(() {
      _resultApiTest += '1. Testing loadModelWithResult...\n';
    });

    final loadResult = await _flutterWhisperkitPlugin.loadModelWithResult(
      _selectedModel,
      modelRepo: 'argmaxinc/whisperkit-coreml',
    );

    loadResult.when(
      success: (modelPath) {
        setState(() {
          _resultApiTest += '✅ loadModelWithResult SUCCESS: $modelPath\n\n';
        });
      },
      failure: (error) {
        setState(() {
          _resultApiTest +=
              '❌ loadModelWithResult FAILED: ${error.message}\n\n';
        });
      },
    );

    // Test detectLanguageWithResult
    setState(() {
      _resultApiTest += '2. Testing detectLanguageWithResult...\n';
    });

    try {
      final filePath = await FilePicker.platform.pickFiles().then(
        (file) => file?.files.firstOrNull?.path,
      );

      if (filePath != null) {
        final detectResult = await _flutterWhisperkitPlugin
            .detectLanguageWithResult(filePath);
        detectResult.when(
          success: (result) {
            setState(() {
              _resultApiTest +=
                  '✅ detectLanguageWithResult SUCCESS: ${result?.language}\n\n';
            });
          },
          failure: (error) {
            setState(() {
              _resultApiTest +=
                  '❌ detectLanguageWithResult FAILED: ${error.message}\n\n';
            });
          },
        );
      } else {
        setState(() {
          _resultApiTest +=
              '⚠️ detectLanguageWithResult SKIPPED: No file selected\n\n';
        });
      }

      // Test transcribeFileWithResult
      setState(() {
        _resultApiTest += '3. Testing transcribeFileWithResult...\n';
      });

      if (filePath != null) {
        final transcribeResult = await _flutterWhisperkitPlugin
            .transcribeFileWithResult(filePath);
        transcribeResult.when(
          success: (result) {
            setState(() {
              _resultApiTest +=
                  '✅ transcribeFileWithResult SUCCESS: "${result?.text.substring(0, 50)}..."\n\n';
            });
          },
          failure: (error) {
            setState(() {
              _resultApiTest +=
                  '❌ transcribeFileWithResult FAILED: ${error.message}\n\n';
            });
          },
        );
      } else {
        setState(() {
          _resultApiTest +=
              '⚠️ transcribeFileWithResult SKIPPED: No file selected\n\n';
        });
      }
    } catch (e) {
      setState(() {
        _resultApiTest += '❌ Result API test error: $e\n\n';
      });
    }

    setState(() {
      _resultApiTest += 'Result-based API testing completed!';
      _isTestingResultApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WhisperKit API Test'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _transcriptionResult = [];
                  _transcriptionText = '';
                  _fileTranscriptionResult = null;
                  _fileTranscriptionText = '';
                  _streamEvents = [];
                  _progressEventCount = 0;
                  _transcriptionEventCount = 0;
                });
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Model and language selection
            ModelSelectionDropdown(
              selectedModel: _selectedModel,
              modelVariants: _modelVariants,
              onModelChanged: (newModel) {
                setState(() {
                  _selectedModel = newModel;
                  _isModelLoaded = false;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _asyncLoadModel = _loadModel();
                });
              },
              child: const Text('Load Model'),
            ),

            LanguageSelectionDropdown(
              selectedLanguage: _selectedLanguage,
              onLanguageChanged: (newLanguage) {
                setState(() {
                  _selectedLanguage = newLanguage;
                });
              },
            ),

            // Model loading indicator
            ModelLoadingIndicator(
              asyncLoadModel: _asyncLoadModel,
              modelProgressStream: _flutterWhisperkitPlugin.modelProgressStream,
            ),

            const SizedBox(height: 16),

            // NEW: Additional Model Management Section
            AdditionalModelManagementSection(
              isSettingUpModels: _isSettingUpModels,
              setupModelsResult: _setupModelsResult,
              isDownloadingModel: _isDownloadingModel,
              downloadResult: _downloadResult,
              isPrewarmingModels: _isPrewarmingModels,
              prewarmResult: _prewarmResult,
              isUnloadingModels: _isUnloadingModels,
              unloadResult: _unloadResult,
              isClearingState: _isClearingState,
              clearStateResult: _clearStateResult,
              isSettingLogging: _isSettingLogging,
              loggingResult: _loggingResult,
              onSetupModelsPressed: _setupModels,
              onDownloadModelPressed: _downloadModel,
              onPrewarmModelsPressed: _prewarmModels,
              onUnloadModelsPressed: _unloadModels,
              onClearStatePressed: _clearState,
              onSetLoggingPressed: _setLoggingCallback,
            ),

            const SizedBox(height: 16),

            // NEW: Result-based API Testing Section
            ResultApiTestingSection(
              isTestingResultApi: _isTestingResultApi,
              resultApiTest: _resultApiTest,
              onTestResultApiPressed: _testResultApi,
            ),

            const SizedBox(height: 16),

            // NEW: Stream Monitoring Section
            StreamMonitoringSection(
              streamEvents: _streamEvents,
              progressEventCount: _progressEventCount,
              transcriptionEventCount: _transcriptionEventCount,
            ),

            const SizedBox(height: 16),

            // Device Information Section
            DeviceInformationSection(
              deviceNameResult: _deviceNameResult,
              isLoadingDeviceName: _isLoadingDeviceName,
              onGetDeviceNamePressed: _getDeviceName,
            ),

            const SizedBox(height: 16),

            // Model Discovery Section
            ModelDiscoverySection(
              availableModels: _availableModels,
              isLoadingAvailableModels: _isLoadingAvailableModels,
              recommendedModels: _recommendedModels,
              isLoadingRecommendedModels: _isLoadingRecommendedModels,
              recommendedRemoteModels: _recommendedRemoteModels,
              isLoadingRecommendedRemoteModels:
                  _isLoadingRecommendedRemoteModels,
              onFetchAvailableModelsPressed: _fetchAvailableModels,
              onGetRecommendedModelsPressed: _getRecommendedModels,
              onGetRecommendedRemoteModelsPressed: _getRecommendedRemoteModels,
            ),

            const SizedBox(height: 16),

            // Language Detection Section
            LanguageDetectionSection(
              isModelLoaded: _isModelLoaded,
              isDetectingLanguage: _isDetectingLanguage,
              languageDetectionResult: _languageDetectionResult,
              onDetectLanguagePressed: _detectLanguage,
            ),

            const SizedBox(height: 16),

            // Model Configuration Section
            ModelConfigurationSection(
              modelFilesToFormat: _modelFilesToFormat,
              formattedModelFiles: _formattedModelFiles,
              isFormattingModelFiles: _isFormattingModelFiles,
              modelSupportConfig: _modelSupportConfig,
              isLoadingModelSupportConfig: _isLoadingModelSupportConfig,
              onFormatModelFilesPressed: _formatModelFiles,
              onFetchModelSupportConfigPressed: _fetchModelSupportConfig,
              onModelFilesChanged: (value) {
                setState(() {
                  _modelFilesToFormat = value
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                });
              },
            ),

            const SizedBox(height: 16),

            // File transcription section
            FileTranscriptionSection(
              isModelLoaded: _isModelLoaded,
              isTranscribingFile: _isTranscribingFile,
              fileTranscriptionText: _fileTranscriptionText,
              fileTranscriptionResult: _fileTranscriptionResult,
              onTranscribePressed: _transcribeFromFile,
            ),

            const SizedBox(height: 16),

            // Real-time transcription section
            RealTimeTranscriptionSection(
              isModelLoaded: _isModelLoaded,
              isRecording: _isRecording,
              transcriptionText: _transcriptionText,
              segments: _transcriptionResult,
              onRecordPressed: _toggleRecording,
            ),
          ],
        ),
      ),
    );
  }
}

/// NEW: Widget for additional model management functions
class AdditionalModelManagementSection extends StatelessWidget {
  const AdditionalModelManagementSection({
    super.key,
    required this.isSettingUpModels,
    required this.setupModelsResult,
    required this.isDownloadingModel,
    required this.downloadResult,
    required this.isPrewarmingModels,
    required this.prewarmResult,
    required this.isUnloadingModels,
    required this.unloadResult,
    required this.isClearingState,
    required this.clearStateResult,
    required this.isSettingLogging,
    required this.loggingResult,
    required this.onSetupModelsPressed,
    required this.onDownloadModelPressed,
    required this.onPrewarmModelsPressed,
    required this.onUnloadModelsPressed,
    required this.onClearStatePressed,
    required this.onSetLoggingPressed,
  });

  final bool isSettingUpModels;
  final String setupModelsResult;
  final bool isDownloadingModel;
  final String downloadResult;
  final bool isPrewarmingModels;
  final String prewarmResult;
  final bool isUnloadingModels;
  final String unloadResult;
  final bool isClearingState;
  final String clearStateResult;
  final bool isSettingLogging;
  final String loggingResult;
  final VoidCallback onSetupModelsPressed;
  final VoidCallback onDownloadModelPressed;
  final VoidCallback onPrewarmModelsPressed;
  final VoidCallback onUnloadModelsPressed;
  final VoidCallback onClearStatePressed;
  final VoidCallback onSetLoggingPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Additional Model Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8.0,
          children: [
            ElevatedButton(
              onPressed: isSettingUpModels ? null : onSetupModelsPressed,
              child: Text(isSettingUpModels ? 'Setting Up...' : 'Setup Models'),
            ),
            ElevatedButton(
              onPressed: isDownloadingModel ? null : onDownloadModelPressed,
              child: Text(
                isDownloadingModel ? 'Downloading...' : 'Download Model',
              ),
            ),
            ElevatedButton(
              onPressed: isPrewarmingModels ? null : onPrewarmModelsPressed,
              child: Text(
                isPrewarmingModels ? 'Prewarming...' : 'Prewarm Models',
              ),
            ),
            ElevatedButton(
              onPressed: isUnloadingModels ? null : onUnloadModelsPressed,
              child: Text(isUnloadingModels ? 'Unloading...' : 'Unload Models'),
            ),
            ElevatedButton(
              onPressed: isClearingState ? null : onClearStatePressed,
              child: Text(isClearingState ? 'Clearing...' : 'Clear State'),
            ),
            ElevatedButton(
              onPressed: isSettingLogging ? null : onSetLoggingPressed,
              child: Text(isSettingLogging ? 'Setting...' : 'Set Logging'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (setupModelsResult.isNotEmpty)
                Text('Setup: $setupModelsResult'),
              if (downloadResult.isNotEmpty) Text('Download: $downloadResult'),
              if (prewarmResult.isNotEmpty) Text('Prewarm: $prewarmResult'),
              if (unloadResult.isNotEmpty) Text('Unload: $unloadResult'),
              if (clearStateResult.isNotEmpty) Text('Clear: $clearStateResult'),
              if (loggingResult.isNotEmpty) Text('Logging: $loggingResult'),
              if (setupModelsResult.isEmpty &&
                  downloadResult.isEmpty &&
                  prewarmResult.isEmpty &&
                  unloadResult.isEmpty &&
                  clearStateResult.isEmpty &&
                  loggingResult.isEmpty)
                const Text(
                  'Press buttons above to test additional model management functions',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// NEW: Widget for Result-based API testing
class ResultApiTestingSection extends StatelessWidget {
  const ResultApiTestingSection({
    super.key,
    required this.isTestingResultApi,
    required this.resultApiTest,
    required this.onTestResultApiPressed,
  });

  final bool isTestingResultApi;
  final String resultApiTest;
  final VoidCallback onTestResultApiPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Result-based API Testing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: isTestingResultApi ? null : onTestResultApiPressed,
          child: Text(isTestingResultApi ? 'Testing...' : 'Test Result APIs'),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Text(
              resultApiTest.isEmpty
                  ? 'Press the button to test Result-based APIs (loadModelWithResult, transcribeFileWithResult, detectLanguageWithResult)'
                  : resultApiTest,
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }
}

/// NEW: Widget for stream monitoring
class StreamMonitoringSection extends StatelessWidget {
  const StreamMonitoringSection({
    super.key,
    required this.streamEvents,
    required this.progressEventCount,
    required this.transcriptionEventCount,
  });

  final List<String> streamEvents;
  final int progressEventCount;
  final int transcriptionEventCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Stream Monitoring',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Progress Events: $progressEventCount | Transcription Events: $transcriptionEventCount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          height: 150,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: streamEvents.isEmpty
              ? const Text('Stream events will appear here...')
              : ListView.builder(
                  itemCount: streamEvents.length,
                  itemBuilder: (context, index) {
                    return Text(
                      streamEvents[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Widget for model selection dropdown
class ModelSelectionDropdown extends StatelessWidget {
  const ModelSelectionDropdown({
    super.key,
    required this.selectedModel,
    required this.modelVariants,
    required this.onModelChanged,
  });

  final String selectedModel;
  final List<String> modelVariants;
  final Function(String) onModelChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Select Model: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: selectedModel,
            isExpanded: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onModelChanged(newValue);
              }
            },
            items: modelVariants.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Widget for language selection dropdown
class LanguageSelectionDropdown extends StatelessWidget {
  const LanguageSelectionDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : _languages = const [
         'auto', // Auto-detect
         'en', // English
         'ja', // Japanese
         'zh', // Chinese
         'de', // German
         'es', // Spanish
         'ru', // Russian
         'ko', // Korean
         'fr', // French
         'it', // Italian
         'pt', // Portuguese
         'tr', // Turkish
         'pl', // Polish
         'nl', // Dutch
         'ar', // Arabic
         'hi', // Hindi
       ];

  final String selectedLanguage;
  final List<String> _languages;
  final Function(String) onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Select Language: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: selectedLanguage,
            isExpanded: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onLanguageChanged(newValue);
              }
            },
            items: _languages.map<DropdownMenuItem<String>>((String value) {
              // Show language code and name for better readability
              String displayText = switch (value) {
                'auto' => 'auto (Auto-detect)',
                'en' => 'en (English)',
                'ja' => 'ja (Japanese)',
                'zh' => 'zh (Chinese)',
                'de' => 'de (German)',
                'es' => 'es (Spanish)',
                'ru' => 'ru (Russian)',
                'ko' => 'ko (Korean)',
                'fr' => 'fr (French)',
                'it' => 'it (Italian)',
                'pt' => 'pt (Portuguese)',
                'tr' => 'tr (Turkish)',
                'pl' => 'pl (Polish)',
                'nl' => 'nl (Dutch)',
                'ar' => 'ar (Arabic)',
                'hi' => 'hi (Hindi)',
                _ => throw UnimplementedError(),
              };

              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Widget for model loading indicator
class ModelLoadingIndicator extends StatelessWidget {
  const ModelLoadingIndicator({
    super.key,
    required this.asyncLoadModel,
    required this.modelProgressStream,
  });

  final Future<String> asyncLoadModel;
  final Stream<Progress> modelProgressStream;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asyncLoadModel,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading model: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text('Model loaded successfully');
        }

        return StreamBuilder(
          stream: modelProgressStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading model: ${snapshot.error}');
            }

            if (snapshot.data?.fractionCompleted == 1.0) {
              return const Center(
                child: Column(
                  spacing: 16.0,
                  children: [CircularProgressIndicator(), Text('Model loaded')],
                ),
              );
            }

            return Column(
              spacing: 16.0,
              children: [
                LinearProgressIndicator(
                  value: snapshot.data?.fractionCompleted,
                ),
                Text('${(snapshot.data?.fractionCompleted ?? 0) * 100}%'),
              ],
            );
          },
        );
      },
    );
  }
}
