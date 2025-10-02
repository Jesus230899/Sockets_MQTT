import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/entities/mqtt_response_entity.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/usecases/mqtt_publish_usecase.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/usecases/subscribe_mqtt_usecase.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  final SubscribeMqttUsecase subscribeMqttUsecase;
  final MqttPublishUsecase mqttPublishUsecase;
  MQTTBloc({
    required this.subscribeMqttUsecase,
    required this.mqttPublishUsecase,
  }) : super(MQTTInitial()) {
    on<ConnectToMQTTEvent>(_onConnect);
    on<NewMessageMQTTEvent>(_onNewMessage);
    on<SendMessageMQTTEvent>(_onSendMesage);
  }

  Future<void> _onConnect(
    ConnectToMQTTEvent event,
    Emitter<MQTTState> emit,
  ) async {
    log('Entra en _onConnect');
    emit(MQTTLoading());
    final stream = await subscribeMqttUsecase(event.topic);
    if (stream == null) {
      log('No se pudo conectar al broker');
      emit(MQTTError("No se pudo conectar al broker"));
      return;
    }
    await emit.forEach(stream, onData: (data) => MQTTMessageReceived(data));
  }

  void _onNewMessage(NewMessageMQTTEvent event, Emitter emit) {
    emit(MQTTMessageReceived(event.message));
  }

  void _onSendMesage(SendMessageMQTTEvent event, Emitter emit) {
    mqttPublishUsecase(topic: event.topic, data: event.payload);
  }
}
