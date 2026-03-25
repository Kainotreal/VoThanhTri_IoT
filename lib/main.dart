import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_setup.dart'
    if (dart.library.io) 'mqtt_setup_io.dart'
    if (dart.library.html) 'mqtt_setup_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT LED Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LEDControllerPage(),
    );
  }
}

class LEDControllerPage extends StatefulWidget {
  const LEDControllerPage({super.key});

  @override
  State<LEDControllerPage> createState() => _LEDControllerPageState();
}

class _LEDControllerPageState extends State<LEDControllerPage> {
  // --- CẤU HÌNH MQTT ---
  final String server = '10.226.14.234'; // IP CỦA BẠN
  final int port = 8083; // Cổng WebSocket
  final String clientIdentifier = 'flutter_web_${DateTime.now().millisecondsSinceEpoch}';
  final String topicToPublish = '/topic/led'; // Topic chính xác
  final String topicToSubscribe = '/topic/led';

  late MqttClient client;
  String connectionState = 'Đang ngắt kết nối';
  bool isConnected = false;
  bool ledStatus = false;

  @override
  void initState() {
    super.initState();
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    setState(() {
      connectionState = 'Đang kết nối...';
    });

    // Khởi tạo client hỗ trợ đa nền tảng (Web/iOS/Android)
    client = setupMqttClient(server, port, clientIdentifier);
    client.keepAlivePeriod = 20;

    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    client.pongCallback = _pong;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      print('>>> Đang kết nối tới $server:$port...');
      await client.connect();
    } catch (e) {
      print('>>> LỖI KẾT NỐI: $e');
      _handleDisconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        // Cập nhật trạng thái theo phản hồi từ ESP32 (Logic ngược: '0' là ON)
        setState(() {
          ledStatus = (pt == '0');
        });
      });
      client.subscribe(topicToSubscribe, MqttQos.atMostOnce);
    } else {
      _handleDisconnect();
    }
  }

  void _publishMessage(String message) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa kết nối MQTT! Hãy thử lại.')),
      );
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topicToPublish, MqttQos.atMostOnce, builder.payload!);
    
    // Cập nhật giao diện ngay lập tức (Optimistic UI) 
    // Nếu logic bị ngược: '0' là ON, '1' là OFF
    setState(() {
      ledStatus = (message == '0');
    });
  }

  void _onConnected() {
    setState(() {
      connectionState = 'Đã kết nối';
      isConnected = true;
    });
    print('>>> MQTT CONNECTED SUCCESSFUL');
  }

  void _onDisconnected() {
    print('>>> MQTT DISCONNECTED');
    _handleDisconnect();
  }

  void _onSubscribed(String topic) {
    print('>>> Subscribed to $topic');
  }

  void _pong() {
    print('>>> Ping response received');
  }

  void _handleDisconnect() {
    setState(() {
      connectionState = 'Đã ngắt kết nối';
      isConnected = false;
    });
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'IOT CONTROL CENTER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.blue.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                _buildStatusChip(),
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBulbIcon(),
                          const SizedBox(height: 30),
                          Text(
                            ledStatus ? 'DEVICE ON' : 'DEVICE OFF',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: ledStatus ? Colors.amberAccent : Colors.white38,
                              shadows: ledStatus ? [const Shadow(color: Colors.amber, blurRadius: 20)] : [],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                  child: _ControlBtn(
                                    label: 'ON',
                                    isActive: ledStatus,
                                    color: Colors.greenAccent,
                                    onPressed: () => _publishMessage('0'), // Gửi '0' cho ON (Logic ngược)
                                  ),
                                ),
                                const SizedBox(width: 25),
                                Expanded(
                                  child: _ControlBtn(
                                    label: 'OFF',
                                    isActive: !ledStatus,
                                    color: Colors.redAccent,
                                    onPressed: () => _publishMessage('1'), // Gửi '1' cho OFF
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (!isConnected)
                  ElevatedButton.icon(
                    onPressed: _connectMqtt,
                    icon: const Icon(Icons.sync),
                    label: const Text('RETRY CONNECTION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            connectionState.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildBulbIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: ledStatus ? [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 60, spreadRadius: 10)] : [],
      ),
      child: Icon(
        Icons.lightbulb_outline_rounded,
        size: 150,
        color: ledStatus ? Colors.amberAccent : Colors.white10,
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onPressed;

  const _ControlBtn({required this.label, required this.isActive, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isActive ? color : Colors.white10),
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.black87 : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}