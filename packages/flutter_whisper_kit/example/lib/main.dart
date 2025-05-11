import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:file_picker/file_picker.dart';

// Import widget files
import 'widgets/device_information_section.dart';
import 'widgets/model_discovery_section.dart';
import 'widgets/language_detection_section.dart';
import 'widgets/model_configuration_section.dart';

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

  final _flutterWhisperkitPlugin = FlutterWhisperKit();
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;

  @override
  void initState() {
    super.initState();
    _asyncLoadModel = _loadModel();
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    super.dispose();
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
        language:
            _selectedLanguage == 'auto'
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
          language:
              _selectedLanguage == 'auto'
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WhisperKit Example'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _transcriptionResult = [];
                  _transcriptionText = '';
                  _fileTranscriptionResult = null;
                  _fileTranscriptionText = '';
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
                  _modelFilesToFormat =
                      value
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
            items:
                modelVariants.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
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
            items:
                _languages.map<DropdownMenuItem<String>>((String value) {
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

/// Widget for file transcription section
class FileTranscriptionSection extends StatelessWidget {
  const FileTranscriptionSection({
    super.key,
    required this.isModelLoaded,
    required this.isTranscribingFile,
    required this.fileTranscriptionText,
    required this.fileTranscriptionResult,
    required this.onTranscribePressed,
  });

  final bool isModelLoaded;
  final bool isTranscribingFile;
  final String fileTranscriptionText;
  final TranscriptionResult? fileTranscriptionResult;
  final VoidCallback onTranscribePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'File Transcription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        ElevatedButton(
          onPressed: isModelLoaded ? onTranscribePressed : null,
          child: Text(
            isTranscribingFile ? 'Transcribing...' : 'Transcribe from File',
          ),
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
              Text(
                fileTranscriptionText.isEmpty
                    ? 'Press the button to transcribe a file'
                    : fileTranscriptionText,
                style: const TextStyle(fontSize: 16),
              ),
              if (fileTranscriptionResult != null) ...[
                const Text(
                  'Detected Language:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(fileTranscriptionResult?.language ?? 'Unknown'),

                const Text(
                  'Segments:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(fileTranscriptionResult?.segments ?? []).map(
                  (segment) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '[${segment.start.toStringAsFixed(2)}s - ${segment.end.toStringAsFixed(2)}s]: ${segment.text}',
                    ),
                  ),
                ),

                const Text(
                  'Performance:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Real-time factor: ${fileTranscriptionResult?.timings.realTimeFactor.toStringAsFixed(2)}x',
                ),
                Text(
                  'Processing time: ${fileTranscriptionResult?.timings.fullPipeline.toStringAsFixed(2)}s',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for real-time transcription section
class RealTimeTranscriptionSection extends StatelessWidget {
  const RealTimeTranscriptionSection({
    super.key,
    required this.isModelLoaded,
    required this.isRecording,
    required this.transcriptionText,
    required this.segments,
    required this.onRecordPressed,
  });

  final bool isModelLoaded;
  final bool isRecording;
  final List<TranscriptionSegment> segments;
  final String transcriptionText;
  final VoidCallback onRecordPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16.0,
      children: [
        const Text(
          'Real-time Transcription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
              segments.isNotEmpty
                  ? ListView.builder(
                    itemCount: segments.length,
                    itemBuilder: (context, index) {
                      return Text(
                        '[${segments[index].start.toStringAsFixed(2)}s - ${segments[index].end.toStringAsFixed(2)}s]: ${segments[index].text}',
                      );
                    },
                  )
                  : const Text('No segments'),
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
              transcriptionText.isEmpty
                  ? 'Press the button to start recording'
                  : transcriptionText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        ElevatedButton(
          onPressed: isModelLoaded ? onRecordPressed : null,
          child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ],
    );
  }
}
