import 'package:sockets_mqtt_app/features/mqtt/domain/repositories/mqtt_repository.dart';

class MqttPublishUsecase {
  final MqttRepository _repository;
  MqttPublishUsecase(this._repository);

  Future<void> call({
    required String topic,
    required Map<String, dynamic> data,
  }) {
    return _repository.publish(topic: topic, data: data);
  }
}
