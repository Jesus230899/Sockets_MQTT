import 'package:sockets_mqtt_app/features/mqtt/domain/repositories/mqtt_repository.dart';

class ConnectToMQTTUseCase {
  final MqttRepository repository;
  ConnectToMQTTUseCase(this.repository);

  void call() => repository.connect();
}
