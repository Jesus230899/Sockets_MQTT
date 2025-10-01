import 'package:auto_route/auto_route.dart';
import 'package:sockets_mqtt_app/core/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: WebsocketRoute.page),
    AutoRoute(page: MQTTRoute.page),
  ];
}
