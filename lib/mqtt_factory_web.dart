import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient create(String server, int port) {
  // Use WebSocket for web
  return MqttBrowserClient('ws://$server/mqtt', '');
}
