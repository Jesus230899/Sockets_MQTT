import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class WebsocketScreen extends StatelessWidget {
  const WebsocketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket')),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: [Text('WebSocket Screen')]);
  }
}
