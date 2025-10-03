part of 'websocket_bloc.dart';

sealed class WebsocketState extends Equatable {
  const WebsocketState();

  @override
  List<Object?> get props => [];
}

final class WebsocketInitial extends WebsocketState {}

class WebSocketConnecting extends WebsocketState {}

class WebSocketConnected extends WebsocketState {
  final List<String> messages;
  const WebSocketConnected({this.messages = const []});
  @override
  List<Object> get props => [messages];
}

class WebSocketDisconnected extends WebsocketState {
  final String? error; // texto de error opcional
  const WebSocketDisconnected({this.error});
  @override
  List<Object?> get props => [error];
}

// Estado de error terminal (opcional)
class WebSocketFailure extends WebsocketState {
  final String message; // mensaje de falla
  const WebSocketFailure(this.message);
  @override
  List<Object> get props => [message];
}
