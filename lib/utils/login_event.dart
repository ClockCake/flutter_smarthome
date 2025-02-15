// event_bus.dart
import 'dart:async';

class LoginEvent {
  final bool success;
  LoginEvent(this.success);
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  
  factory EventBus() => _instance;
  
  EventBus._internal();
  
  final _controller = StreamController<LoginEvent>.broadcast();
  
  Stream<LoginEvent> get stream => _controller.stream;
  
  void emit(LoginEvent event) {
    _controller.sink.add(event);
  }
  
  void dispose() {
    _controller.close();
  }
}

final eventBus = EventBus();