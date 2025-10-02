import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:sockets_mqtt_app/core/env/env.dart';
import 'package:sockets_mqtt_app/features/mqtt/data/datasources/mqtt_service.dart';
import 'package:sockets_mqtt_app/features/mqtt/data/repositories/mqtt_repository_impl.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/usecases/mqtt_publish_usecase.dart';
import 'package:sockets_mqtt_app/features/mqtt/domain/usecases/subscribe_mqtt_usecase.dart';
import 'package:sockets_mqtt_app/features/mqtt/presentation/bloc/mqtt_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class MQTTScreen extends StatelessWidget {
  const MQTTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MQTTBloc(
        subscribeMqttUsecase: SubscribeMqttUsecase(
          MqttRepositoryImpl(MQTTService(Env.mqttBroker, Env.clientID)),
        ),
        mqttPublishUsecase: MqttPublishUsecase(
          MqttRepositoryImpl(MQTTService(Env.mqttBroker, Env.clientID)),
        ),
      )..add(ConnectToMQTTEvent(Env.topic)),
      child: Scaffold(
        appBar: AppBar(title: const Text('MQTT')),
        body: _blocConsumer(),
      ),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<MQTTBloc, MQTTState>(
      listener: (_, __) {},
      builder: (context, state) {
        if (state is MQTTMessageReceived) {
          return Text('Mensaje recibido: ${state.message.payload}');
        }
        return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Text('Enviar mensaje'),
        const SizedBox(height: 100),
        _button(
          title: 'Enviar',
          onPressed: () {
            log('Entra en Enviar onPressed');
            context.read<MQTTBloc>().add(
              SendMessageMQTTEvent(Env.topic, {
                "user": "Jesús",
                "message": "Hola desde Flutter!",
                "timestamp": DateTime.now().toIso8601String(),
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _button({required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }
}
