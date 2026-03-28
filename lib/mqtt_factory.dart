import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_factory_stub.dart'
    if (dart.library.io) 'mqtt_factory_mobile.dart'
    if (dart.library.html) 'mqtt_factory_web.dart';

MqttClient createMqttClient(String server, int port) => create(server, port);
