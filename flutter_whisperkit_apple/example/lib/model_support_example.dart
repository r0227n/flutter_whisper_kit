import 'package:flutter/material.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

/// Example widget demonstrating the use of WhisperKit model support.
class ModelSupportExample extends StatefulWidget {
  const ModelSupportExample({super.key});

  @override
  State<ModelSupportExample> createState() => _ModelSupportExampleState();
}

class _ModelSupportExampleState extends State<ModelSupportExample> {
  final _flutterWhisperkitApple = FlutterWhisperkitApple();
  ModelSupportConfig? _config;
  String _status = 'Loading...';
  List<String> _supportedModels = [];
  String _defaultModel = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModelSupportConfig();
  }

  // Load model support configuration
  Future<void> _loadModelSupportConfig() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading model support configuration...';
    });

    try {
      final result = await _flutterWhisperkitApple.modelSupport.fetchModelSupportConfig();
      
      if (result.isSuccess && result.data != null) {
        final config = result.data!;
        final supportedModels = await _flutterWhisperkitApple.modelSupport.getSupportedModels(config);
        final defaultModel = await _flutterWhisperkitApple.modelSupport.getDefaultModel(config);
        
        setState(() {
          _config = config;
          _supportedModels = supportedModels;
          _defaultModel = defaultModel;
          _status = 'Configuration loaded successfully';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = 'Error: ${result.error} - ${result.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Refresh configuration
  Future<void> _refreshConfiguration() async {
    await _flutterWhisperkitApple.modelSupport.clearCache();
    await _loadModelSupportConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhisperKit Model Support'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  if (_config != null) ...[
                    Text('Repository: ${_config!.repoName}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text('Version: ${_config!.repoVersion}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('Default Model: $_defaultModel',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Supported Models:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _supportedModels.length,
                        itemBuilder: (context, index) {
                          final model = _supportedModels[index];
                          return ListTile(
                            title: Text(model),
                            leading: model == _defaultModel
                                ? const Icon(Icons.star, color: Colors.amber)
                                : const Icon(Icons.check),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshConfiguration,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
