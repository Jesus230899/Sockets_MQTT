import 'package:equatable/equatable.dart';

class MqttResponseEntity extends Equatable {
  final String topic;
  final Map<String, dynamic> payload;

  const MqttResponseEntity({required this.topic, required this.payload});

  @override
  List<Object> get props => [topic, payload];
}
