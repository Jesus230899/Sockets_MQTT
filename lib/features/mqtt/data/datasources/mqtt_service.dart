import 'dart:convert';
import 'dart:developer';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sockets_mqtt_app/core/env/env.dart';

class MQTTService {
  final MqttServerClient _client;
  MQTTService(String broker, String clientID)
    : _client = MqttServerClient(Env.mqttBroker, Env.clientID);

  Stream<Map<String, dynamic>>? _messageStream;

  Future<bool> connect() async {
    // imprime los logs en la consola
    _client.port = 1883;
    // intervalo en segundos para mantener la conexion activa
    _client.keepAlivePeriod = 20;
    // Este es el callback para cuando se pierde la conexion, aqui es recomendable reintentar la conexion
    _client.logging(on: false);
    _client.onDisconnected = () =>
        log('MQTT Desconectado - Estado final: ${_client.connectionStatus}');
    _client.onFailedConnectionAttempt = (val) =>
        log('ERROR EN onFailedConnectionAttempt: $val');
    _client.onSubscribeFail = (str) => log('Fallo la suscripcion $str');
    _client.onConnected = () => log('Se pudo conectar al broker');
    _client.onSubscribed = (str) => log('Se suscribio al topico: $str');
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;

    final MqttConnectMessage connMess = MqttConnectMessage()
        // .authenticateAs(Env.username, Env.password)
        .withClientIdentifier(Env.clientID)
        .startClean() // Non persistent session
        // .keepAliveFor(60) // Keep alive interval in seconds
        // .withWillTopic('willtopic') // Will topic
        //.withWillMessage('Cliente desconectado') // Will message
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    // _client.secure = true;

    // intentar conexion con el Broker, en caso de que no suceda nos desconectamos e imprimimos el error
    try {
      await _client.connect();
    } catch (e) {
      log('Error conexion MQTT: $e');
      _client.disconnect();
      return false;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      log('Se pudo conectar al broker MQTT');
      // _messageStream = _client.updates?.map((messages) {
      //   final msg = messages[0].payload as MqttPublishMessage;
      //   final payload = MqttPublishPayload.bytesToStringAsString(
      //     msg.payload.message,
      //   );
      //   log(
      //     'Nuevo mensaje tras reconectar: topic: ${messages[0].topic}, payload: $payload',
      //   );
      //   return {'topic': messages[0].topic, 'payload': jsonDecode(payload)};
      // });
      return true;
    } else {
      log('No se pudo conectar al broker MQTT: ${_client.connectionStatus}');
      _client.disconnect();
      return false;
    }
  }

  Future<void> suscribe(String topic) async {
    try {
      log('Entra a suscribe de MQTTService con el topico: ${Env.topic}');
      // Nos suscribimos a un topico con QoS (at most once)
      _client.subscribe(Env.topic, MqttQos.atLeastOnce);
      // Obtenemos los mensajes entrantes y los transformamos a un Stream de Map<String, dynamic>
      _messageStream = _client.updates?.map((messages) {
        final msg = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          msg.payload.message,
        );
        log('Nuevo mensaje: topic: ${messages[0].topic}, payload: $payload');
        return {'topic': messages[0].topic, 'payload': jsonDecode(payload)};
      });
    } catch (e) {
      log(' Error en suscribe: $e');
    }
  }

  // obtenemos el stream que contiene los mensajes entrantes
  Stream<Map<String, dynamic>>? get messages => _messageStream;

  // Publicamos un mensaje en un topic
  Future<void> publish({
    required String topic,
    required Map<String, dynamic> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      log(
        '_client.connectionStatus!.state: ${_client.connectionStatus!.state}',
      );
      if (_client.connectionStatus?.state != MqttConnectionState.connected) {
        log('Cliente desconectado, intentando reconectar...');
        final connected = await connect();
        if (!connected) {
          log('No se pudo publicar, sigue desconectado');
          return;
        }

        // await suscribe(Env.topic);
      }
      log('Entra en publish de MQTTService');
      // Declaramos nuestro PayloadBuilder
      final builder = MqttClientPayloadBuilder();
      // Convertimos el Map a String y lo agregamos al builder
      builder.addString('Mensaje desde flutter');
      // Publicamos el mensaje
      _client.publishMessage(Env.topic, MqttQos.atLeastOnce, builder.payload!);
    } catch (e) {
      log('Error al publicar: $e');
    }
  }
}
