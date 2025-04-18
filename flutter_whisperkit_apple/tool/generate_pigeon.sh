#!/bin/bash

# Create pigeons directory if it doesn't exist
mkdir -p pigeons

# Run pigeon code generation
dart run pigeon \
  --input pigeons/whisper_kit_api.dart \
  --dart_out lib/src/whisper_kit_api.dart \
  --objc_header_out ios/Classes/WhisperKitApi.h \
  --objc_source_out ios/Classes/WhisperKitApi.m \
  --objc_prefix FLT

# Copy the generated files to macOS
cp ios/Classes/WhisperKitApi.h macos/Classes/
cp ios/Classes/WhisperKitApi.m macos/Classes/