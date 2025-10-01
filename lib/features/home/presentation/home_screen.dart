import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sockets_mqtt_app/core/routes/app_router.gr.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body(context));
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _button(
            title: 'WebSocket',
            onPressed: () => AutoRouter.of(context).push(WebsocketRoute()),
          ),
          const SizedBox(height: 10),
          _button(title: 'MQTT', onPressed: () {}),
        ],
      ),
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
