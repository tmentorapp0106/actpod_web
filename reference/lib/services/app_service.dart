import 'dart:async';

class AppReady {
  AppReady._();
  static final instance = AppReady._();

  bool _ready = false;
  final Completer<void> _c = Completer<void>();

  bool get isReady => _ready;

  void markReady() {
    if (_ready) return;
    _ready = true;
    if (!_c.isCompleted) _c.complete();
  }

  Future<void> waitUntilReady() => _c.future;
}