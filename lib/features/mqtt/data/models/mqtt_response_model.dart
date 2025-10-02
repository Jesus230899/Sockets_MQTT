import 'package:sockets_mqtt_app/features/mqtt/domain/entities/mqtt_response_entity.dart';

class MqttResponseModel extends MqttResponseEntity {
  const MqttResponseModel({required super.topic, required super.payload});

  factory MqttResponseModel.fromJson(Map<String, dynamic> json) {
    return MqttResponseModel(
      topic: json['topic'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {'topic': topic, 'payload': payload};
  }
}
