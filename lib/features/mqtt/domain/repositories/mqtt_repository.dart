import 'package:sockets_mqtt_app/features/mqtt/domain/entities/mqtt_response_entity.dart';

abstract class MqttRepository {
  // Para conectarse al Broker
  Future<void> connect();
  // Para suscribirse a un topico y obtener los mensajes entrantes
  Future<Stream<MqttResponseEntity>?> suscribe(String topic);
  // Para publicar un mensaje en un topico
  Future<void> publish({required String topic, required Map<String, dynamic> data});
}
