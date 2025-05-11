import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for model discovery section
class ModelDiscoverySection extends StatelessWidget {
  const ModelDiscoverySection({
    super.key,
    required this.availableModels,
    required this.isLoadingAvailableModels,
    required this.recommendedModels,
    required this.isLoadingRecommendedModels,
    required this.recommendedRemoteModels,
    required this.isLoadingRecommendedRemoteModels,
    required this.onFetchAvailableModelsPressed,
    required this.onGetRecommendedModelsPressed,
    required this.onGetRecommendedRemoteModelsPressed,
  });

  final List<String> availableModels;
  final bool isLoadingAvailableModels;
  final ModelSupport? recommendedModels;
  final bool isLoadingRecommendedModels;
  final ModelSupport? recommendedRemoteModels;
  final bool isLoadingRecommendedRemoteModels;
  final VoidCallback onFetchAvailableModelsPressed;
  final VoidCallback onGetRecommendedModelsPressed;
  final VoidCallback onGetRecommendedRemoteModelsPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Model Discovery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Fetch Available Models
        ElevatedButton(
          onPressed: isLoadingAvailableModels ? null : onFetchAvailableModelsPressed,
          child: Text(
            isLoadingAvailableModels ? 'Loading...' : 'Fetch Available Models',
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
                'Available Models:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              availableModels.isEmpty
                  ? const Text('Press the button to fetch available models')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: availableModels
                          .map((model) => Text(model))
                          .toList(),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Get Recommended Models
        ElevatedButton(
          onPressed: isLoadingRecommendedModels ? null : onGetRecommendedModelsPressed,
          child: Text(
            isLoadingRecommendedModels ? 'Loading...' : 'Get Recommended Models',
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
                'Recommended Models:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              recommendedModels == null
                  ? const Text('Press the button to get recommended models')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Default Model: ${recommendedModels.defaultModel}'),
                        const SizedBox(height: 4),
                        const Text('Supported Models:'),
                        ...recommendedModels.supported
                            .map((model) => Text('- $model'))
                            .toList(),
                        const SizedBox(height: 4),
                        const Text('Disabled Models:'),
                        recommendedModels.disabled.isEmpty
                            ? const Text('- None')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: recommendedModels.disabled
                                    .map((model) => Text('- $model'))
                                    .toList(),
                              ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Get Recommended Remote Models
        ElevatedButton(
          onPressed: isLoadingRecommendedRemoteModels ? null : onGetRecommendedRemoteModelsPressed,
          child: Text(
            isLoadingRecommendedRemoteModels ? 'Loading...' : 'Get Recommended Remote Models',
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
                'Recommended Remote Models:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              recommendedRemoteModels == null
                  ? const Text('Press the button to get recommended remote models')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Default Model: ${recommendedRemoteModels.defaultModel}'),
                        const SizedBox(height: 4),
                        const Text('Supported Models:'),
                        ...recommendedRemoteModels.supported
                            .map((model) => Text('- $model'))
                            .toList(),
                        const SizedBox(height: 4),
                        const Text('Disabled Models:'),
                        recommendedRemoteModels.disabled.isEmpty
                            ? const Text('- None')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: recommendedRemoteModels.disabled
                                    .map((model) => Text('- $model'))
                                    .toList(),
                              ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
