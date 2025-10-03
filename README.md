# sockets_mqtt_app
Este es un proyecto para una aplicación que sirva de ejemplo para la integración de:
1. WebSockets (wss://echo.websocket.org)
2. MQTT (Mosquitto o HiveMQ Clud)
3. BLoC
4. Clean Architecture (DDD)

## Que es WebSockets?
Es una conexión directa a un servidor, con un canal abierto/persistente, en este ejemplo usaremos la libreria "web_socket_channel":
1. La app se conecta a un servidor WebSocket con un canal persistente
2. Se escuchan los nuevos eventos o mensajes a través de un stream en tiempo real
3. Enviamos datos a traves del uso de sink

Desventajas:
1. Conexiones inestables, si la red es inestable el canal se cierra
2. Algunos servidores cierran el canal si no hay interacción, para ello se necesita implementar mensajes "keep-alive" para mantener una conexión viva.

Manejo de errores:
Se usará onError y onDone para cachar fallas en la red, en caso de haber fallas se cierra el canal y se trata de reconectar


## Que es MQTT?
Es una conexión hacia un Broker (un servidor intermediario) usando un cliente donde te te suscribes a topics y tambien publicas a topics. ("topics" es como el tema de la conversacion, como si fuera un canal de Twitch), en este ejemplo usaré la libreria "mqtt_client":
1. Se define el host/puerto del broker al que se va a conectar
2. Se define el ClientID, tiene que ser único
3. Se definen los topics a los que nos vamos a suscribir
4. Con "client.updates?.listen(...)" escuchamos los nuevos cambios. Nos regresa un objeto que contiene el topic y el payload
5. Se publican mensajes con MqttClientPayloadBuilder donde mandamos un payload que puede ser texto plano un jSON encodeado

Desventajas:
1. Conexiones inestables, si la red es inestable el Broker marca al cliente como desconectado
2. Se debe de configurar el QoS de acuerdo al caso
3. Se tiene que convertir a JSON o String manualmente

Manejo de errores:
Se usará onDisconnected y se revisa el ConnectionStatus para validar fallos, en caso de fallos se aplica reconección y suscripción a los topics necesarios



## Generación de nuevas rutas
1. Necesitas limpiar el generador, en caso de que haya algun tipo de conflicto
- flutter packages pub run build_runner clean
2. Generar nuevas rutas
- flutter packages pub run build_runner build --delete-conflicting-outputs


