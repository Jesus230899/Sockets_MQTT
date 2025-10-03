part of 'websocket_bloc.dart';

sealed class WebsocketEvent extends Equatable {
  const WebsocketEvent();

  @override
  List<Object> get props => [];
}

// Evento para iniciar la conexión
class WebSocketConnectRequestedEvent extends WebsocketEvent {}

// Evento para desconectar manualmente
class WebSocketDisconnectRequestedEvent extends WebsocketEvent {}

// Evento para enviar un mensaje
class WebSocketSendMessageEvent extends WebsocketEvent {
  final String message;
  const WebSocketSendMessageEvent(this.message);
  @override
  List<Object> get props => [message];
}

// Evento interno: cuando recibimos mensaje del servicio
class WebSocketMessageReceivedEvent extends WebsocketEvent {
  final String message;
  const WebSocketMessageReceivedEvent(this.message);
  @override
  List<Object> get props => [message];
}

// Evento interno: cambio de estado de conexión
class WebSocketConnectionChangedEvent extends WebsocketEvent {
  final bool connected;
  const WebSocketConnectionChangedEvent(this.connected);
  @override
  List<Object> get props => [connected];
}

// Evento interno: errores
class WebSocketErrorOccurredEvent extends WebsocketEvent {
  final Exception exception; // excepción recibida
  const WebSocketErrorOccurredEvent(this.exception);
  @override
  List<Object> get props => [exception];
}
