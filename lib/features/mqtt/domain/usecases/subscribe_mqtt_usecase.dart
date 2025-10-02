import 'package:sockets_mqtt_app/features/mqtt/domain/entities/mqtt_response_entity.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/repositories/mqtt_repository.dart';

class SubscribeMqttUsecase {
  final MqttRepository _repository;
  SubscribeMqttUsecase(this._repository);

  Future<Stream<MqttResponseEntity>?> call(String topic) async {
    return _repository.suscribe(topic);
  }
}
