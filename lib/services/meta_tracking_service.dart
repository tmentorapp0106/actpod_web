import 'package:flutter/foundation.dart';
import 'package:flutter_meta_appads_sdk/flutter_meta_appads_sdk.dart';

class MetaTrackingService {
  MetaTrackingService._();

  static final MetaTrackingService instance = MetaTrackingService._();

  final FlutterMetaAppAdsSdk _metaSdk = FlutterMetaAppAdsSdk();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      await _metaSdk.initWebPixel(
        pixelId: '1165023005790351',
      );
    } else {
      await _metaSdk.initSdk(
        enableLogging: kDebugMode,
      );
    }

    _initialized = true;
  }

  Future<void> trackViewContent({
    required String pageName,
    String? contentId,
    String? contentType,
  }) async {
    if (!_initialized) return;

    await _metaSdk.logStandardEvent(
      FBLogStandardEventCommand(
        event: FBStandardEvent.viewedContent,
        parameters: {
          FBStandardParameter.parameterNameContent: pageName,
          if (contentId != null)
            FBStandardParameter.parameterNameContentID: contentId,
          if (contentType != null)
            FBStandardParameter.parameterNameContentType: contentType,
        },
      ),
    );
  }
}