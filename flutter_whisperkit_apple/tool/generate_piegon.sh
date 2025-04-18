#!/bin/bash

# スクリプトが実行されるディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR"

# 実行前に必要なディレクトリを作成
mkdir -p $ROOT_DIR/lib/src
mkdir -p $ROOT_DIR/ios/Classes
mkdir -p $ROOT_DIR/macos/Classes

# Dart出力の生成（共通）
flutter pub run pigeon \
  --input $ROOT_DIR/pigeons/whisperkit_messages.dart \
  --dart_out $ROOT_DIR/lib/src/whisperkit_messages.dart

# iOS用の出力を生成
flutter pub run pigeon \
  --input $ROOT_DIR/pigeons/whisperkit_messages.dart \
  --objc_header_out $ROOT_DIR/ios/Classes/whisperkit_messages.h \
  --objc_source_out $ROOT_DIR/ios/Classes/whisperkit_messages.m \
  --swift_out $ROOT_DIR/ios/Classes/WhisperKitMessages.swift \
  --objc_prefix FWA

# macOS用の出力を生成
flutter pub run pigeon \
  --input $ROOT_DIR/pigeons/whisperkit_messages.dart \
  --objc_header_out $ROOT_DIR/macos/Classes/whisperkit_messages.h \
  --objc_source_out $ROOT_DIR/macos/Classes/whisperkit_messages.m \
  --swift_out $ROOT_DIR/macos/Classes/WhisperKitMessages.swift \
  --objc_prefix FWA

echo "Pigeon code generation completed."