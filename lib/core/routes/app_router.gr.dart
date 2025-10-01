// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:sockets_mqtt_app/features/home/presentation/home_screen.dart'
    as _i1;
import 'package:sockets_mqtt_app/features/mqtt/presentation/mqtt_screen.dart'
    as _i2;
import 'package:sockets_mqtt_app/features/websocket/presentation/websocket_screen.dart'
    as _i3;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.MQTTScreen]
class MQTTRoute extends _i4.PageRouteInfo<void> {
  const MQTTRoute({List<_i4.PageRouteInfo>? children})
    : super(MQTTRoute.name, initialChildren: children);

  static const String name = 'MQTTRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.MQTTScreen();
    },
  );
}

/// generated route for
/// [_i3.WebsocketScreen]
class WebsocketRoute extends _i4.PageRouteInfo<void> {
  const WebsocketRoute({List<_i4.PageRouteInfo>? children})
    : super(WebsocketRoute.name, initialChildren: children);

  static const String name = 'WebsocketRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.WebsocketScreen();
    },
  );
}
