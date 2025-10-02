part of 'mqtt_bloc.dart';

sealed class MQTTEvent extends Equatable {
  const MQTTEvent();

  @override
  List<Object> get props => [];
}

class ConnectToMQTTEvent extends MQTTEvent {
  final String topic;
  const ConnectToMQTTEvent(this.topic);

  @override
  List<Object> get props => [topic];
}

class NewMessageMQTTEvent extends MQTTEvent {
  final MqttResponseEntity message;
  const NewMessageMQTTEvent(this.message);

  @override
  List<Object> get props => [message];
}

class SendMessageMQTTEvent extends MQTTEvent {
  final String topic;
  final Map<String, dynamic> payload;
  const SendMessageMQTTEvent(this.topic, this.payload);

  @override
  List<Object> get props => [topic, payload];
}