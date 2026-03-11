import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Device Dashboard',
      home: const IoTDeviceDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IoTDeviceDashboard extends StatefulWidget {
  const IoTDeviceDashboard({super.key});

  @override
  State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
}

class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
  // QUAN TRỌNG: tính lại theo nền tảng để khỏi phải chỉnh tay mỗi lần
  String get _baseUrl {
    // trên web localhost chính là máy phát triển
    if (kIsWeb) return 'http://localhost:8080';
    // emulator Android dùng địa chỉ của host
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    // iOS simulator, desktop đều có thể dùng localhost
    return 'http://localhost:8080';
  }

  List<Device> _devices = [];
  
  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();
  final _payloadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  // Lấy danh sách thiết bị từ server
  Future<void> fetchDevices() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/devices'));
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        setState(() {
          _devices = list.map((json) => Device.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi fetchDevices: $e');
    }
  }

  // Tạo thiết bị mới
  Future<void> createDevice() async {
    if (_deviceNameController.text.isEmpty || _deviceTopicController.text.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _deviceNameController.text,
          'topic': _deviceTopicController.text,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _deviceNameController.clear();
        _deviceTopicController.clear();
        fetchDevices(); // Cập nhật lại danh sách ngay lập tức
      }
    } catch (e) {
      debugPrint('Lỗi createDevice: $e');
    }
  }

  // Điều khiển thiết bị
  Future<void> controlDevice(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/$id/control'),
        headers: {'Content-Type': 'text/plain'},
        body: _payloadController.text,
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lệnh đã gửi')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi controlDevice: $e');
    }
  }

  // Hiển thị lịch sử Telemetry
  Future<void> _showTelemetryDialog(int deviceId, String deviceName) async {
    List<Telemetry> telemetries = await fetchTelemetry(deviceId);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Telemetry - $deviceName'),
        content: SizedBox(
          width: double.maxFinite,
          child: telemetries.isEmpty
              ? const Text('Không có dữ liệu')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: telemetries.length,
                  itemBuilder: (context, index) {
                    final t = telemetries[index];
                    return ListTile(
                      title: Text(t.value),
                      subtitle: Text(t.timestamp),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Lấy dữ liệu Telemetry từ server
  Future<List<Telemetry>> fetchTelemetry(int deviceId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/telemetry/$deviceId'));
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((json) => Telemetry.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi fetchTelemetry: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Device Dashboard'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('📋 Danh sách thiết bị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Hiển thị danh sách Card thiết bị
            ..._devices.map((d) => Card(
                  color: Colors.blue.shade50,
                  elevation: 2,
                  child: ListTile(
                    title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Topic: ${d.topic}'),
                    trailing: ElevatedButton(
                      onPressed: () => controlDevice(d.id),
                      child: const Text('Gửi lệnh'),
                    ),
                    onTap: () => _showTelemetryDialog(d.id, d.name),
                  ),
                )),
            const Divider(height: 40),
            const Text('➕ Thêm thiết bị mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: 'Tên thiết bị')),
            TextField(controller: _deviceTopicController, decoration: const InputDecoration(labelText: 'Topic MQTT')),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
              onPressed: createDevice, 
              child: const Text('Tạo thiết bị')
            ),
            const SizedBox(height: 30),
            const Text('🎮 Nhập lệnh điều khiển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _payloadController, 
              decoration: const InputDecoration(hintText: 'Ví dụ: {"data": 20}', border: OutlineInputBorder())
            ),
          ],
        ),
      ),
    );
  }
}

// Model Device
class Device {
  final int id;
  final String name;
  final String topic;

  Device({required this.id, required this.name, required this.topic});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      topic: json['topic'] ?? '',
    );
  }
}

// Model Telemetry
class Telemetry {
  final String timestamp;
  final String value;

  Telemetry({required this.timestamp, required this.value});

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      timestamp: json['timestamp'] ?? '',
      value: json['value'] ?? '',
    );
  }
}