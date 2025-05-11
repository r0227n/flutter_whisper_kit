# Flutter WhisperKit Example App Testing Criteria

This document outlines the testing criteria for the Flutter WhisperKit example app, which provides a UI to manually test all public functions implemented in the FlutterWhisperKit class.

## Public Functions Testing Criteria

### 1. Device Information
- **Function**: `deviceName()`
- **UI Component**: DeviceInformationSection widget
- **Input**: "Get Device Name" button
- **Output**: Text display showing the device name
- **Success Criteria**:
  - Button is enabled and clickable
  - Loading state is displayed during API call
  - Device name is displayed after successful call
  - Error message is displayed if the call fails

### 2. Model Discovery
- **Functions**: 
  - `fetchAvailableModels()`
  - `recommendedModels()`
  - `recommendedRemoteModels()`
- **UI Component**: ModelDiscoverySection widget
- **Inputs**: 
  - "Fetch Available Models" button
  - "Get Recommended Models" button
  - "Get Recommended Remote Models" button
- **Outputs**: 
  - List of available models
  - ModelSupport object showing default, supported, and disabled models
  - ModelSupport object showing remote model recommendations
- **Success Criteria**:
  - All buttons are enabled and clickable
  - Loading states are displayed during API calls
  - Model lists are displayed after successful calls
  - Default models are clearly indicated
  - Supported and disabled models are properly categorized
  - Error messages are displayed if calls fail

### 3. Language Detection
- **Function**: `detectLanguage()`
- **UI Component**: LanguageDetectionSection widget
- **Input**: "Detect Language from File" button (opens file picker)
- **Output**: 
  - Detected language
  - Language probabilities (top 5, sorted by probability)
- **Success Criteria**:
  - Button is enabled only when a model is loaded
  - Loading state is displayed during API call
  - File picker opens when button is clicked
  - Detected language is displayed after successful call
  - Language probabilities are displayed and sorted correctly
  - Error message is displayed if the call fails

### 4. Model Configuration
- **Functions**: 
  - `formatModelFiles()`
  - `fetchModelSupportConfig()`
- **UI Component**: ModelConfigurationSection widget
- **Inputs**: 
  - Text field for model file names
  - "Format Model Files" button
  - "Fetch Model Support Config" button
- **Outputs**: 
  - List of formatted model files
  - ModelSupportConfig object with repository info, known models, and device supports
- **Success Criteria**:
  - Text field accepts comma-separated model file names
  - Buttons are enabled and clickable
  - Loading states are displayed during API calls
  - Formatted model files are displayed after successful call
  - Model support configuration details are displayed properly
  - Error messages are displayed if calls fail

### 5. File Transcription
- **Function**: `transcribeFromFile()`
- **UI Component**: FileTranscriptionSection widget
- **Input**: "Transcribe from File" button (opens file picker)
- **Output**: 
  - Transcription text
  - Detected language
  - Transcription segments with timestamps
  - Performance metrics (real-time factor, processing time)
- **Success Criteria**:
  - Button is enabled only when a model is loaded
  - Loading state is displayed during API call
  - File picker opens when button is clicked
  - Transcription text is displayed after successful call
  - Segments with timestamps are displayed correctly
  - Performance metrics are shown
  - Error message is displayed if the call fails

### 6. Real-time Transcription
- **Functions**: 
  - `startRecording()`
  - `stopRecording()`
  - `transcriptionStream`
- **UI Component**: RealTimeTranscriptionSection widget
- **Input**: "Start Recording"/"Stop Recording" toggle button
- **Output**: 
  - Real-time transcription text
  - Transcription segments with timestamps
- **Success Criteria**:
  - Button is enabled only when a model is loaded
  - Button text changes between "Start Recording" and "Stop Recording"
  - Transcription text updates in real-time during recording
  - Segments with timestamps are displayed correctly
  - Error message is displayed if recording fails

### 7. Model Loading
- **Functions**: 
  - `loadModel()`
  - `modelProgressStream`
- **UI Component**: ModelLoadingIndicator widget
- **Inputs**: 
  - Model selection dropdown
  - "Load Model" button
- **Output**: 
  - Loading progress indicator
  - Success/failure message
- **Success Criteria**:
  - Dropdown shows available model variants
  - Button is enabled and clickable
  - Progress indicator updates during model loading
  - Success message is displayed after successful loading
  - Error message is displayed if loading fails
  - Other UI components are enabled/disabled based on model loading state

## General UI Testing Criteria

1. **Layout and Design**:
   - UI follows Flutter material design guidelines
   - Widgets are properly aligned and spaced
   - Text is readable and appropriately sized
   - Containers have consistent styling (borders, padding, etc.)

2. **Error Handling**:
   - All API calls have proper error handling
   - Error messages are displayed to the user
   - UI remains responsive even when errors occur

3. **State Management**:
   - Loading states are properly managed and displayed
   - UI updates correctly when state changes
   - No unexpected UI behavior during state transitions

4. **Responsiveness**:
   - UI adapts to different screen sizes
   - Scrolling works properly for overflow content
   - No layout issues on small or large screens

5. **Code Structure**:
   - UI components are broken down into separate widget classes
   - Code follows Flutter best practices
   - Widget hierarchy is logical and maintainable
