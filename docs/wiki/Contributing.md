# Contributing

Thank you for your interest in contributing to the Flutter WhisperKit Apple plugin! This guide will help you get started with contributing to the project.

## Development Environment Setup

1. **Flutter Setup**
   - Install Flutter by following the [official installation guide](https://docs.flutter.dev/get-started/install)
   - Ensure you have Flutter 3.3.0 or higher and Dart 3.7.2 or higher

2. **Clone the Repository**
   ```bash
   git clone https://github.com/r0227n/flutter_whisperkit.git
   cd flutter_whisperkit/flutter_whisperkit_apple
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **iOS/macOS Development Setup**
   - Xcode 14.0 or higher is required
   - For iOS development, ensure you have a valid iOS development certificate
   - For macOS development, ensure you have the necessary entitlements

## Project Structure

Familiarize yourself with the [Project Organization](Project-Organization) to understand the codebase structure.

## Development Workflow

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Implement your feature or fix
   - Follow the existing code style and patterns
   - Add tests for your changes when applicable

3. **Test Your Changes**
   - Run the example app to verify your changes
   ```bash
   cd example
   flutter run
   ```
   - Run tests
   ```bash
   flutter test
   ```

4. **Commit Your Changes**
   ```bash
   git commit -m "Description of your changes"
   ```

5. **Submit a Pull Request**
   - Push your branch to GitHub
   ```bash
   git push origin feature/your-feature-name
   ```
   - Create a pull request on GitHub
   - Provide a clear description of your changes
   - Reference any related issues

## Code Style Guidelines

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write clear comments for complex logic
- Keep functions small and focused on a single responsibility
- Use proper indentation (2 spaces)

## Testing Guidelines

- Write unit tests for new functionality
- Update existing tests when modifying functionality
- Ensure all tests pass before submitting a pull request
- Add integration tests for significant features

## Documentation Guidelines

- Update documentation for any changes to the public API
- Document complex algorithms or non-obvious behavior
- Keep the README and wiki up to date
- Use dartdoc comments for public APIs

## Reporting Issues

If you find a bug or have a feature request, please create an issue on GitHub:

1. Check if the issue already exists
2. Use a clear and descriptive title
3. Provide detailed steps to reproduce the issue
4. Include relevant information about your environment (Flutter version, iOS/macOS version, etc.)
5. If possible, provide a minimal code example that demonstrates the issue

## Community Guidelines

- Be respectful and considerate of others
- Help others when you can
- Provide constructive feedback
- Follow the [Flutter code of conduct](https://github.com/flutter/flutter/blob/master/CODE_OF_CONDUCT.md)

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license.

Thank you for contributing to the Flutter WhisperKit Apple plugin!
