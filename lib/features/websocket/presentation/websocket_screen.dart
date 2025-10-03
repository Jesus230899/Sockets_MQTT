import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sockets_mqtt_app/features/websocket/data/datasources/sockets_service.dart';
import 'package:sockets_mqtt_app/features/websocket/presentation/bloc/websocket_bloc.dart';

@RoutePage()
class WebsocketScreen extends StatefulWidget {
  const WebsocketScreen({super.key});

  @override
  State<WebsocketScreen> createState() => _WebsocketScreenState();
}

class _WebsocketScreenState extends State<WebsocketScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final wsService = WebSocketsService(url: 'wss://echo.websocket.org');

    return BlocProvider(
      create: (context) => WebsocketBloc(service: wsService),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('WebSocket')),
            body: _body(context),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Acciones disponibles'),
          _actions(context),
          const SizedBox(height: 40),
          _content(context),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        _action(
          icon: Icons.login,
          title: 'Conectar',
          onPressed: () {
            context.read<WebsocketBloc>().add(WebSocketConnectRequestedEvent());
          },
        ),
        _action(
          icon: Icons.logout,
          title: 'Desconectar',
          onPressed: () {
            context.read<WebsocketBloc>().add(
              WebSocketDisconnectRequestedEvent(),
            );
          },
        ),
        _action(
          icon: Icons.refresh,
          title: 'Reconectar',
          onPressed: () {
            // Reconexión forzada mediante el servicio
            context.read<WebsocketBloc>().service.forceReconnect();
            context.read<WebsocketBloc>().add(WebSocketConnectRequestedEvent());
          },
        ),
      ],
    );
  }

  Widget _action({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(color: Colors.white)),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<WebsocketBloc, WebsocketState>(
          builder: (context, state) {
            String text = 'Desconectado';
            Color color = Colors.red;
            if (state is WebSocketConnecting) {
              text = 'Conectando...';
              color = Colors.orange;
            } else if (state is WebSocketConnected) {
              text = 'Conectado';
              color = Colors.green;
            } else if (state is WebSocketDisconnected) {
              text = 'Desconectado';
              color = Colors.red;
            } else if (state is WebsocketInitial) {
              text = 'Inicial';
              color = Colors.grey;
            }
            return Container(
              color: color.withValues(alpha: 0.1),
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(text, textAlign: TextAlign.center),
            );
          },
        ),

        // Widget que muestra errores si existen
        BlocBuilder<WebsocketBloc, WebsocketState>(
          builder: (context, state) {
            if (state is WebSocketDisconnected && state.error != null) {
              return Container(
                color: Colors.red.withValues(alpha: 0.1),
                padding: EdgeInsets.all(8),
                child: Text('Error: ${state.error}'),
              );
            }
            return SizedBox.shrink();
          },
        ),

        // Expanded ListView que muestra mensajes
        SizedBox(
          height: 200,
          child: BlocBuilder<WebsocketBloc, WebsocketState>(
            builder: (context, state) {
              List<String> messages = [];
              if (state is WebSocketConnected) {
                messages = state.messages;
              }
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(title: Text(messages[index]));
                },
              );
            },
          ),
        ),

        // Input para enviar mensajes y botón
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Mensaje a enviar'),
                  onSubmitted: (_) => _send(context.read<WebsocketBloc>()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _send(context.read<WebsocketBloc>()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _send(WebsocketBloc bloc) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    bloc.add(WebSocketSendMessageEvent(text));
    _controller.clear();
  }
}
