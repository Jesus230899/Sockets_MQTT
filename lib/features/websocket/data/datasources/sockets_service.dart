import 'dart:async';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketsService {
  final String url;

  WebSocketChannel? _channel; // Canal de comunicacion
  StreamSubscription? _channelSuscription; // Stream del canal

  final StreamController<String> _messageController =
      StreamController.broadcast(); // Mensajes entrantes
  final StreamController<bool> _connectionController =
      StreamController.broadcast(); // Estado de conexion (conectado es true)
  final StreamController<Exception> _errorController =
      StreamController.broadcast(); // Controla errores

  bool _manuallyDisconnected = false; // Para saber si la desconexion fue manual
  bool _connecting = false; // Para evitar conexiones multiples
  int _reconnectAttempts = 0; // Contador de reintentos
  final int maxReconnectAttempts; // Maximo de reintentos
  final Duration initialReconnectDelay; // Intervalo entre reintentos
  Timer? _reconnectTimer; // Timer para manejar reintentos

  WebSocketsService({
    required this.url,
    this.maxReconnectAttempts = 5,
    this.initialReconnectDelay = const Duration(seconds: 2),
  });

  // Stream de mensajes entrantes
  Stream<String> get messages => _messageController.stream;
  // Stream del estado de conexion
  Stream<bool> get connectionStatus => _connectionController.stream;
  // Stream de errores
  Stream<Exception> get errors => _errorController.stream;

  // Metodo para conectar al servidor WebSocket
  Future<void> connect() async {
    // Validar si se esta conectando, no hacer nada
    if (_connecting || _channel != null) return;
    _connecting = true;
    _manuallyDisconnected = false;
    // Intentar conexion
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      //Suscribirse para escuchar mensajes entrantes
      _channelSuscription = _channel!.stream.listen(
        (data) {
          // Si llega un mensaje, lo agregamos al stream de mensajes
          if (data is String) {
            _messageController.add(data);
          } else {
            // Si vienen otros tipos de datos (en este caso bytes) los convertimos a String
            _messageController.add(data.toString());
          }
        },
        onDone: () {
          // Con el onDone sabemos que la conexion se cerro
          _connectionController.add(false);
          _channel = null;
          _channelSuscription?.cancel();
          _channelSuscription = null;
          _connecting = false;

          // Si la desconexion no fue manual, intentamos reconectar
          if (!_manuallyDisconnected) {
            _scheduleReconnect();
          }
        },
        onError: (error) {
          _errorController.add(Exception(error.toString()));
          _connectionController.add(false);
          _channel = null;
          _channelSuscription?.cancel();
          _channelSuscription = null;
          _connecting = false;
          // Si la desconexion no fue manual, intentamos reconectar
          if (!_manuallyDisconnected) {
            _scheduleReconnect();
          }
        },
        //Cancelar la suscripcion en caso de error
        cancelOnError: true,
      );
      // Si todo sale bien, indicamos que estamos conectados
      _connectionController.add(true);
      _reconnectAttempts = 0;
      _connecting = false;
    } catch (e) {
      // Capturamos cualquier error y lo enviamos al stream de errores
      _errorController.add(Exception(e.toString()));
      _connectionController.add(false);
      _channel = null;
      _connecting = false;
      // Si la desconexion no fue manual, intentamos reconectar
      if (!_manuallyDisconnected) {
        _scheduleReconnect();
      }
    }
  }

  void send(String message) {
    // Validar si hay canal
    if (_channel == null) {
      _errorController.add(Exception('No hay conexion activa'));
      return;
    }
    try {
      // Enviamos mensaje al Socket
      _channel!.sink.add(message);
    } catch (e) {
      _errorController.add(
        Exception('Error al enviar mensaje: ${e.toString()}'),
      );
    }
  }

  Future<void> disconnect({
    int code = WebSocketStatus.normalClosure,
    String reason = 'Desconexion normal',
  }) async {
    _manuallyDisconnected = true; // Lo ponemos true para evitar reconexiones
    _reconnectTimer?.cancel(); // Cancelamos cualquier reintento pendiente
    _reconnectTimer = null;
    _reconnectAttempts = 0; // Reseteo de numero de intentos

    try {
      // Si hay canal, se cierra con codigo y razon
      await _channel?.sink.close(code, reason);
    } catch (e) {
      _errorController.add(Exception('Error al desconectar: ${e.toString()}'));
    } finally {
      _channel = null; // limpiar canal
      await _channelSuscription?.cancel(); // cancelar suscripcion
      _channelSuscription = null;
      _connectionController.add(false);
    }
  }

  void _scheduleReconnect() {
    if (_manuallyDisconnected) return;
    // Validar si ya se llegó al maximo de reintentos
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _errorController.add(Exception('Maximo de reintentos alcanzado'));
      return;
    }
    _reconnectAttempts++; // Se incrementa el contador de reintentos
    // calculamos delay exponencial (2^attempts * initial), limitado a 60s como ejemplo
    final int multiplier = 1 << (_reconnectAttempts - 1); // 2^(n-1)
    int delaySeconds = initialReconnectDelay.inSeconds * multiplier;

    if (delaySeconds > 60) delaySeconds = 60; // Se define el maximo como 60seg
    _reconnectTimer?.cancel(); // Cancelamos cualquier timer previo
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      connect(); // Intentamos reconectar
    });
  }

  // Forzar reconexion inmediata
  void forceReconnect() {
    if (_manuallyDisconnected) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    connect();
  }

  Future<void> dispose() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _channelSuscription?.cancel();
    _channelSuscription = null;
    try {
      await _channel?.sink.close(); // cerrar sink si existe
    } catch (e) {
      // ignorar errores al cerrar
    } finally {
      _channel = null;
      await _messageController.close();
      await _connectionController.close();
      await _errorController.close();
    }
  }
}
