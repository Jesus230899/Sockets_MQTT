import 'package:sockets_mqtt_app/features/mqtt/data/datasources/mqtt_service.dart';
import 'package:sockets_mqtt_app/features/mqtt/data/models/mqtt_response_model.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/entities/mqtt_response_entity.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/repositories/mqtt_repository.dart';

class MqttRepositoryImpl extends MqttRepository {
  final MQTTService _service;
  MqttRepositoryImpl(this._service);

  @override
  Future<void> connect() async => await _service.connect();

  @override
  Future<Stream<MqttResponseEntity>?> suscribe(String topic) async {
    final connected = await _service.connect();
    if (!connected) return null;
    _service.suscribe(topic);
    return _service.messages!.map((event) => MqttResponseModel.fromJson(event));
  }

  @override
  Future<void> publish({
    required String topic,
    required Map<String, dynamic> data,
  }) async {
    _service.publish(topic: topic, data: data);
  }
}
