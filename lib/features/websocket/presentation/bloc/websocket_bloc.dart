import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sockets_mqtt_app/features/websocket/data/datasources/sockets_service.dart';

part 'websocket_event.dart';
part 'websocket_state.dart';

class WebsocketBloc extends Bloc<WebsocketEvent, WebsocketState> {
  final WebSocketsService service;
  StreamSubscription<String>? _msgSub; // suscripción a mensajes
  StreamSubscription<bool>? _connSub; // suscripción a conexión
  StreamSubscription<Exception>? _errSub; // suscripción a errores

  final List<String> _messages = [];

  WebsocketBloc({required this.service}) : super(WebsocketInitial()) {
    on<WebSocketConnectRequestedEvent>(
      _onConnectRequested,
    ); // al pedir conectar
    on<WebSocketDisconnectRequestedEvent>(
      _onDisconnectRequested,
    ); // al pedir desconectar
    on<WebSocketSendMessageEvent>(_onSendMessage); // al pedir enviar mensaje
    on<WebSocketMessageReceivedEvent>(_onMessageReceived); // al recibir mensaje
    on<WebSocketConnectionChangedEvent>(
      _onConnectionChanged,
    ); // cambios de conexión
    on<WebSocketErrorOccurredEvent>(_onErrorOccurred); // errores del servicio
  }

  /// Manejador para conectar.
  Future<void> _onConnectRequested(
    WebSocketConnectRequestedEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    // Emitimos estado de connecting
    emit(WebSocketConnecting()); // informamos UI que estamos conectando
    // Suscribimos streams del servicio para propagar eventos al BLoC
    _msgSub?.cancel(); // cancelamos suscripción previa si existía
    _connSub?.cancel(); // cancelamos suscripción previa si existía
    _errSub?.cancel(); // cancelamos suscripción previa si existía

    // Suscribimos mensajes entrantes
    _msgSub = service.messages.listen((msg) {
      add(WebSocketMessageReceivedEvent(msg));
    });

    // Suscribimos cambios de conexión
    _connSub = service.connectionStatus.listen((connected) {
      add(
        WebSocketConnectionChangedEvent(connected),
      ); // añadimos evento de cambio de conexión
    });

    // Suscribimos errores
    _errSub = service.errors.listen((err) {
      add(WebSocketErrorOccurredEvent(err)); // añadimos evento de error
    });

    // Intentamos conectar mediante el servicio
    await service.connect(); // delegamos la lógica de conexión al servicio
  }

  /// Manejador para desconectar manualmente.
  Future<void> _onDisconnectRequested(
    WebSocketDisconnectRequestedEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    // Llamamos al servicio para desconectar y cancelar reconexiones
    await service.disconnect(); // desconexión ordenada
    // limpiamos suscripciones
    await _msgSub?.cancel(); // cancelamos subscripciones de mensajes
    _msgSub = null; // limpiamos referencia
    await _connSub?.cancel(); // cancelamos subscripcion de conexión
    _connSub = null; // limpiamos referencia
    await _errSub?.cancel(); // cancelamos subscripcion de errores
    _errSub = null; // limpiamos referencia
    _messages.clear(); // limpiamos buffer local de mensajes
    // Emitimos estado desconectado
    emit(WebSocketDisconnected()); // informamos UI de desconexión
  }

  /// Manejador para enviar mensajes.
  void _onSendMessage(
    WebSocketSendMessageEvent event,
    Emitter<WebsocketState> emit,
  ) {
    service.send(event.message); // delegamos envío al servicio
    // añadimos al buffer local para mostrar en UI (opcionalmente)
    _messages.insert(0, 'You: ${event.message}'); // insertamos al inicio
    emit(
      WebSocketConnected(messages: List.from(_messages)),
    ); // emitimos estado conectado con mensajes
  }

  /// Manejador cuando recibimos un nuevo mensaje desde el servicio.
  void _onMessageReceived(
    WebSocketMessageReceivedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    _messages.insert(
      0,
      'Server: ${event.message}',
    ); // guardamos mensaje recibido al inicio
    emit(
      WebSocketConnected(messages: List.from(_messages)),
    ); // emitimos estado conectado con la lista actualizada
  }

  /// Manejador del cambio de estado de conexión.
  void _onConnectionChanged(
    WebSocketConnectionChangedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    if (event.connected) {
      // Si estamos conectados, emitimos estado conectado con mensajes actuales
      emit(WebSocketConnected(messages: List.from(_messages))); // conectado
    } else {
      // Si estamos desconectados, emitimos estado desconectado (sin error)
      emit(WebSocketDisconnected()); // desconectado
    }
  }

  /// Manejador de errores reportados por el servicio.
  void _onErrorOccurred(
    WebSocketErrorOccurredEvent event,
    Emitter<WebsocketState> emit,
  ) {
    // Emitimos estado de failure o desconectado con mensaje de error
    emit(
      WebSocketDisconnected(error: event.exception.toString()),
    ); // emitimos desconexión con error
  }

  /// Limpia suscripciones y recursos del BLoC.
  @override
  Future<void> close() {
    _msgSub?.cancel(); // cancelamos subscripción a mensajes
    _connSub?.cancel(); // cancelamos subscripción a conexión
    _errSub?.cancel(); // cancelamos subscripción a errores
    service.dispose(); // limpiamos servicio (cierra controllers)
    return super.close(); // llamamos al close del padre
  }
}
