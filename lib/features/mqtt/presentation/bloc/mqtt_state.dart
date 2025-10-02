part of 'mqtt_bloc.dart';

sealed class MQTTState extends Equatable {
  const MQTTState();

  @override
  List<Object> get props => [];
}

final class MQTTInitial extends MQTTState {}

final class MQTTLoading extends MQTTState {}

final class MQTTMessageReceived extends MQTTState {
  final MqttResponseEntity message;
  const MQTTMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

final class MQTTError extends MQTTState {
  final String message;
  const MQTTError(this.message);

  @override
  List<Object> get props => [message];
}
