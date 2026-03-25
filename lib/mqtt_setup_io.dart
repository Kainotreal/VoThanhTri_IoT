import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setupMqttClient(String server, int port, String clientIdentifier) {
  // Đối với mobile/desktop, sử dụng MqttServerClient, có hỗ trợ WebSocket
  // Cần thêm prefix ws:// nếu sử dụng WebSocket, tuỳ thuộc vào server
  final client = MqttServerClient.withPort(server, clientIdentifier, port);
  client.useWebSocket = true;
  return client;
}
