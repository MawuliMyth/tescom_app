import 'dart:async';

class AppRefreshBus {
  factory AppRefreshBus() => _instance;

  AppRefreshBus._();

  static final AppRefreshBus _instance = AppRefreshBus._();

  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void refresh() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
