import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MQTTScreen extends StatelessWidget {
  const MQTTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT')),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: [Text('MQTT Screen')]);
  }
}
