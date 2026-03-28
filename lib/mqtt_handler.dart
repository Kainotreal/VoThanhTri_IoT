import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_factory.dart';

class MqttHandler {
  final String server = '10.52.238.234';
  final int port = 1883; 
  MqttClient? client;

  Future<void> connect() async {
    try {
      print('Connecting to MQTT: $server:$port');
      client = createMqttClient(server, port);
      client!.port = port;
      client!.onDisconnected = onDisconnected;
      client!.onConnected = onConnected;
      client!.onSubscribed = onSubscribed;
      client!.pongCallback = pong;

      final connMess = MqttConnectMessage()
          .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client!.connectionMessage = connMess;

      await client!.connect();
    } catch (e) {
      print('MQTT connection error: $e');
      client?.disconnect();
    }
  }

  void onConnected() => print('MQTT Connected');
  void onDisconnected() => print('MQTT Disconnected');
  void onSubscribed(String topic) => print('Subscribed to $topic');
  void pong() => print('Ping response received');

  void publish(String topic, String message) {
    if (client == null || client!.connectionStatus!.state != MqttConnectionState.connected) {
      print('MQTT Not connected. Attempting reconnect...');
      connect();
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
