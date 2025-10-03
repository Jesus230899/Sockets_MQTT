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
    // final bloc = BlocProvider.of<WebsocketBloc>(context);

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
            context.read<WebsocketBloc>().add(
              WebSocketConnectRequestedEvent(),
            ); // event: conectar
          },
        ),
        _action(
          icon: Icons.logout,
          title: 'Desconectar',
          onPressed: () {
            context.read<WebsocketBloc>().add(
              WebSocketDisconnectRequestedEvent(),
            ); // event: desconectar
          },
        ),
        _action(
          icon: Icons.refresh,
          title: 'Reconectar',
          onPressed: () {
            // Reconexión forzada mediante el servicio
            context
                .read<WebsocketBloc>()
                .service
                .forceReconnect(); // forzamos reconexión desde servicio
            context.read<WebsocketBloc>().add(
              WebSocketConnectRequestedEvent(),
            ); // pedimos conectar
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
        // Widget que muestra el estado de conexión
        BlocBuilder<WebsocketBloc, WebsocketState>(
          builder: (context, state) {
            // por defecto mostramos desconectado
            String text = 'Desconectado'; // texto default
            Color color = Colors.red; // color default
            if (state is WebSocketConnecting) {
              text = 'Conectando...'; // texto si conectando
              color = Colors.orange; // color naranja
            } else if (state is WebSocketConnected) {
              text = 'Conectado'; // texto si conectado
              color = Colors.green; // color verde
            } else if (state is WebSocketDisconnected) {
              text = 'Desconectado'; // texto si desconectado
              color = Colors.red; // color rojo
            } else if (state is WebsocketInitial) {
              text = 'Inicial'; // estado inicial
              color = Colors.grey; // color gris
            }
            return Container(
              color: color.withOpacity(0.1), // fondo con opacidad
              padding: EdgeInsets.all(8), // padding
              width: double.infinity, // ancho completo
              child: Text(text, textAlign: TextAlign.center), // texto centrado
            );
          },
        ),

        // Widget que muestra errores si existen
        BlocBuilder<WebsocketBloc, WebsocketState>(
          builder: (context, state) {
            if (state is WebSocketDisconnected && state.error != null) {
              // si hay error lo mostramos
              return Container(
                color: Colors.red.withOpacity(0.1), // fondo en rojo claro
                padding: EdgeInsets.all(8), // padding
                child: Text(
                  'Error: ${state.error}',
                ), // mostrar mensaje de error
              );
            }
            return SizedBox.shrink(); // widget vacío si no hay error
          },
        ),

        // Expanded ListView que muestra mensajes
        SizedBox(
          height: 200,
          child: BlocBuilder<WebsocketBloc, WebsocketState>(
            builder: (context, state) {
              List<String> messages = []; // lista por defecto
              if (state is WebSocketConnected) {
                messages =
                    state.messages; // usamos mensajes del estado conectado
              }
              return ListView.builder(
                reverse: true, // que muestre primero los últimos
                itemCount: messages.length, // cantidad de items
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]), // mensaje
                  );
                },
              );
            },
          ),
        ),

        // Input para enviar mensajes y botón
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // padding
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller, // controlador del input
                  decoration: InputDecoration(
                    hintText: 'Mensaje a enviar',
                  ), // placeholder
                  onSubmitted: (_) =>
                      _send(context.read<WebsocketBloc>()), // enviar al submit
                ),
              ),
              IconButton(
                icon: Icon(Icons.send), // icono enviar
                onPressed: () =>
                    _send(context.read<WebsocketBloc>()), // enviar al presionar
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper para enviar mensajes al BLoC.
  void _send(WebsocketBloc bloc) {
    final text = _controller.text.trim(); // texto del input
    if (text.isEmpty) return; // si está vacío, no hacemos nada
    bloc.add(
      WebSocketSendMessageEvent(text),
    ); // despachamos evento para enviar mensaje
    _controller.clear(); // limpiamos el input
  }
}
