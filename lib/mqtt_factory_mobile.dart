import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient create(String server, int port) {
  return MqttServerClient(server, '');
}
