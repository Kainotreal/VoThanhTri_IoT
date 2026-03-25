import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient setupMqttClient(String server, int port, String clientIdentifier) {
  // Đối với Web, sử dụng MqttBrowserClient
  final client = MqttBrowserClient('ws://$server', clientIdentifier);
  client.port = port;
  client.websocketPath = '/mqtt';
  return client;
}
