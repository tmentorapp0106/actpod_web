import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// 實戰：
/// - WebSocket 連線（帶 token）
/// - 收送 JSON
/// - 心跳
/// - 自動重連（指數退避）
///
/// 可以把這個當成 singleton 或放在 Provider/Riverpod 裡管理。
class WsService {
  WsService({
    required this.wsBaseUrl,
  });


  /// e.g. wss://api.actpodapp.com/ws
  final String wsBaseUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  StreamController<Map<String, dynamic>>? _incomingController;
  Stream<Map<String, dynamic>>? get messages => _incomingController?.stream;

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _manualClosed = false;
  int _retry = 0;

  /// 你可以在外部看連線狀態（很簡化）
  StreamController<bool>? _connectedController;
  Stream<bool>? get connected => _connectedController?.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect({required String path}) async {
    _manualClosed = false;

    // 2) 建立 WS url（示意：token 放 query；若你後端想放 header，見下方註解）
    final uri = Uri.parse(wsBaseUrl + path);

    await _open(uri);
  }

  Future<void> _open(Uri uri) async {
    _cleanupSocketOnly();

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _setConnected(true);

      // 3) 監聽訊息
      _sub = _channel!.stream.listen(
          (event) {
          // event 可能是 String 或 bytes；這裡先當 String
          final text = event is String ? event : utf8.decode(event as List<int>);
          _handleIncoming(text);
        },
        onError: (e, st) {
          _setConnected(false);
          _scheduleReconnect(uri, reason: 'onError: $e');
        },
        onDone: () {
          _setConnected(false);
          if (!_manualClosed) {
            _scheduleReconnect(uri, reason: 'onDone');
          }
        },
        cancelOnError: true,
      );

      // 4) 心跳（很多後端需要）
      _startHeartbeat();
    } catch (e) {
      _setConnected(false);
      _scheduleReconnect(uri, reason: 'connect throw: $e');
    }
  }

  void sendJson(Map<String, dynamic> data) {
    final ch = _channel;
    if (ch == null) return;
    ch.sink.add(jsonEncode(data));
  }

  /// 若你的後端要求 ping/pong 格式不同，改這裡
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      // 常見做法：送一個 type=ping
      sendJson({
        'cmd': 'ping',
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  void _handleIncoming(String text) {
    try {
      final obj = jsonDecode(text);
      if (obj is Map<String, dynamic>) {
        // 例：收到 pong 就不往上丟也行
        if (obj['cmd'] == 'pong') return;

        _incomingController?.add(obj);
      } else {
        // 你也可以把非 Map 的丟出去，這裡先忽略
      }
    } catch (_) {
      // 非 JSON 的訊息（例如後端只送字串）
      _incomingController?.add({'cmd': 'text', 'content': text});
    }
  }

  void _scheduleReconnect(Uri uri, {required String reason}) {
    if (_manualClosed) return;

    _reconnectTimer?.cancel();

    // 指數退避：1s,2s,4s,8s... max 30s
    final delaySec = (1 << _retry).clamp(1, 30);
    _retry = (_retry + 1).clamp(0, 10);

    _reconnectTimer = Timer(Duration(seconds: delaySec), () {
      if (_manualClosed) return;
      _open(uri);
    });
  }

  Future<void> close() async {
    _manualClosed = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    await _sub?.cancel();
    _sub = null;

    _channel?.sink.close(1000);
    _channel = null;

    _setConnected(false);
  }

  void _cleanupSocketOnly() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _sub?.cancel();
    _sub = null;

    // 關閉舊連線（不是手動 close 的情境）
    _channel?.sink.close(status.normalClosure);
    _channel = null;
  }

  void _setConnected(bool value) {
    if (_isConnected == value) return;

    _isConnected = value;

    if(_incomingController == null) {
      _incomingController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if(_connectedController == null) {
      _connectedController = StreamController<bool>.broadcast();
    }
    _connectedController?.add(value);
  }

  Future<void> dispose() async {
    await close();
    await _incomingController?.close();
    _incomingController = null;
    await _connectedController?.close();
    _connectedController = null;
  }
}
