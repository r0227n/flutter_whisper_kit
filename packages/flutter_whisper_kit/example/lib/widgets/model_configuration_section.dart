import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for model configuration section
class ModelConfigurationSection extends StatelessWidget {
  const ModelConfigurationSection({
    super.key,
    required this.modelFilesToFormat,
    required this.formattedModelFiles,
    required this.isFormattingModelFiles,
    required this.modelSupportConfig,
    required this.isLoadingModelSupportConfig,
    required this.onFormatModelFilesPressed,
    required this.onFetchModelSupportConfigPressed,
    required this.onModelFilesChanged,
  });

  final List<String> modelFilesToFormat;
  final List<String> formattedModelFiles;
  final bool isFormattingModelFiles;
  final ModelSupportConfig? modelSupportConfig;
  final bool isLoadingModelSupportConfig;
  final VoidCallback onFormatModelFilesPressed;
  final VoidCallback onFetchModelSupportConfigPressed;
  final Function(String) onModelFilesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Model Configuration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Format Model Files
        const Text(
          'Format Model Files:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter model file names separated by commas',
            helperText: 'Example: tiny.mlmodelc, base.mlmodelc',
          ),
          initialValue: modelFilesToFormat.join(', '),
          onChanged: onModelFilesChanged,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isFormattingModelFiles ? null : onFormatModelFilesPressed,
          child: Text(
            isFormattingModelFiles ? 'Formatting...' : 'Format Model Files',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formatted Model Files:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              formattedModelFiles.isEmpty
                  ? const Text('Press the button to format model files')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: formattedModelFiles
                          .map((file) => Text('- $file'))
                          .toList(),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fetch Model Support Config
        ElevatedButton(
          onPressed: isLoadingModelSupportConfig
              ? null
              : onFetchModelSupportConfigPressed,
          child: Text(
            isLoadingModelSupportConfig
                ? 'Loading...'
                : 'Fetch Model Support Config',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Model Support Config:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              modelSupportConfig == null
                  ? const Text('Press the button to fetch model support config')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repository: ${modelSupportConfig?.repoName ?? "Unknown"}',
                        ),
                        Text(
                          'Version: ${modelSupportConfig?.repoVersion ?? "Unknown"}',
                        ),
                        const SizedBox(height: 4),
                        const Text('Known Models:'),
                        if (modelSupportConfig?.knownModels != null) ...[
                          ...modelSupportConfig!.knownModels.map(
                            (model) => Text('- $model'),
                          ),
                        ],
                        const SizedBox(height: 4),
                        const Text('Device Supports:'),
                        if (modelSupportConfig?.deviceSupports != null) ...[
                          ...modelSupportConfig!.deviceSupports.map(
                            (deviceSupport) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Chip: ${deviceSupport.chips ?? "Unknown"}'),
                                Text(
                                  'Identifiers: ${deviceSupport.identifiers.join(", ")}',
                                ),
                                Text(
                                  'Default Model: ${deviceSupport.models.defaultModel}',
                                ),
                                Text(
                                  'Supported Models: ${deviceSupport.models.supported.join(", ")}',
                                ),
                                Text(
                                  'Disabled Models: ${deviceSupport.models.disabled.isEmpty ? "None" : deviceSupport.models.disabled.join(", ")}',
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
