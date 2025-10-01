import 'package:flutter/material.dart';
import 'package:sockets_mqtt_app/core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // Se usa para mantener el tamaño de fuente fijo y evitar que cambie con la configuración del sistema
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter().config(),
        builder: (_, child) => child ?? const CircularProgressIndicator(),
      ),
    );
  }
}
