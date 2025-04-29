import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The platform interface for the flutter_whisperkit plugin.
///
/// This interface is the contract that all implementations must adhere to.
abstract class FlutterWhisperkitPlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperkitPlatform.
  FlutterWhisperkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWhisperkitPlatform? _instance;

  /// The default instance of [FlutterWhisperkitPlatform] to use.
  static FlutterWhisperkitPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError(
          'No implementation of FlutterWhisperkitPlatform has been registered.');
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperkitPlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
