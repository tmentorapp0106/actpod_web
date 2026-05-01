@JS()
library demo_js_bridge;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('demoBridge')
external DemoBridgeJS get demoBridge;

extension type DemoBridgeJS(JSObject _) implements JSObject {
  external void initTapPay(JSNumber appId, JSString appKey, JSString env);
  external JSString getCardData();
  external JSBoolean setupCardData();
  external JSBoolean isTapPayLoaded();
  external JSBoolean areCardFieldsReady();
  external void getPrime(JSFunction callback);
}

class DemoJsBridge {
  void initTapPay({
    required int appId,
    required String appKey,
    required String env,
  }) {
    demoBridge.initTapPay(
      appId.toJS,
      appKey.toJS,
      env.toJS,
    );
  }

  Map<String, dynamic> getCardData() {
    final raw = demoBridge.getCardData().toDart;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  bool isTapPayLoaded() {
    return demoBridge.isTapPayLoaded().toDart;
  }

  bool areCardFieldsReady() {
    return demoBridge.areCardFieldsReady().toDart;
  }

  bool setupCardData() {
    return demoBridge.setupCardData().toDart;
  }

  Future<Map<String, dynamic>> getPrime() {
    final completer = Completer<Map<String, dynamic>>();

    demoBridge.getPrime(
      ((JSAny? value) {
        final result = value as JSObject;

        final status = (result.getProperty('status'.toJS) as JSNumber).toDartInt;
        final msg = (result.getProperty('msg'.toJS) as JSString?)?.toDart ?? '';

        final card = result.getProperty('card'.toJS) as JSObject?;
        final prime =
            (card?.getProperty('prime'.toJS) as JSString?)?.toDart;
        final bincode =
            (card?.getProperty('bincode'.toJS) as JSString?)?.toDart;
        final lastfour =
            (card?.getProperty('lastfour'.toJS) as JSString?)?.toDart;

        completer.complete({
          'status': status,
          'msg': msg,
          'prime': prime,
          'bincode': bincode,
          'lastfour': lastfour,
        });
      }).toJS,
    );

    return completer.future;
  }
}