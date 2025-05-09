import 'dart:io';

void main() async {
  // Run ffigen to generate bindings
  final result = await Process.run(
    'dart',
    [
      'run',
      'ffigen',
      '--config',
      'pubspec.yaml',
    ],
  );

  if (result.exitCode != 0) {
    print('Error generating bindings:');
    print(result.stderr);
    exit(1);
  }

  print('Bindings generated successfully:');
  print(result.stdout);
}
