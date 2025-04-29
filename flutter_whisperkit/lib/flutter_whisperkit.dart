import 'src/api/model_support_api.dart';
import 'src/model/model_support_config.dart';
import 'src/service/model_support_service.dart';

export 'src/model/model_support_config.dart';
export 'src/service/model_support_service.dart';

/// Main class for the Flutter WhisperKit plugin.
class FlutterWhisperkit {
  /// The model support API.
  final ModelSupportApi modelSupport;
  
  /// Creates a new [FlutterWhisperkit] instance.
  FlutterWhisperkit({String? token}) 
      : modelSupport = ModelSupportApi(token: token);
}
