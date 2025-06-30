# Integration Tests

This directory contains integration tests that verify the interaction between multiple components and services.

## Test Files

### error_codes_integration_test.dart

Tests error handling across the entire system, ensuring consistent error codes and proper error propagation between services.

### error_recovery_integration_test.dart

Tests error recovery mechanisms and retry logic across different service boundaries.

### result_api_integration_test.dart

Tests the Result-based API functionality across all services, ensuring consistent error handling patterns.

### stream_management_integration_test.dart

Tests stream management and data flow between services, particularly for real-time transcription scenarios.

## Purpose

Integration tests verify that:

1. **Service Interaction**: Services work correctly together
2. **Data Flow**: Information flows properly between components
3. **Error Propagation**: Errors are handled consistently across service boundaries
4. **End-to-End Scenarios**: Complete user workflows function as expected

## Running Integration Tests

Run all integration tests:

```bash
flutter test test/integration/
```

Run specific integration test:

```bash
flutter test test/integration/result_api_integration_test.dart
```
