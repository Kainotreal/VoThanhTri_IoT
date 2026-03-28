import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_factory.dart';

class MqttHandler {
  final String server = '10.52.238.234';
  final int port = 1883; 
  MqttClient? client;
  final StreamController<MqttConnectionState> connectionStateController = StreamController<MqttConnectionState>.broadcast();

  Stream<MqttConnectionState> get connectionState => connectionStateController.stream;

  Future<void> connect() async {
    try {
      print('Connecting to MQTT: $server:$port');
      client = createMqttClient(server, port);
      client!.keepAlivePeriod = 20;
      client!.autoReconnect = true;
      client!.resubscribeOnAutoReconnect = true;
      client!.onDisconnected = onDisconnected;
      client!.onConnected = onConnected;
      client!.onSubscribed = onSubscribed;
      client!.pongCallback = pong;

      final connMess = MqttConnectMessage()
          .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client!.connectionMessage = connMess;

      print('MQTT: Attempting to connect to $server...');
      await client!.connect();
      print('MQTT: Connection attempt finished. State: ${client!.connectionStatus!.state}');
      connectionStateController.add(client!.connectionStatus!.state);
    } catch (e) {
      print('MQTT connection error: $e');
      connectionStateController.add(MqttConnectionState.disconnected);
      client?.disconnect();
    }
  }

  void onConnected() {
    print('MQTT Connected');
    connectionStateController.add(MqttConnectionState.connected);
  }

  void onDisconnected() {
    print('MQTT Disconnected');
    connectionStateController.add(MqttConnectionState.disconnected);
  }
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
