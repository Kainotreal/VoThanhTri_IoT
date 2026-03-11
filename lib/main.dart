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
  // CẬP NHẬT QUAN TRỌNG: Trỏ trực tiếp về IP máy tính Windows của Trí
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    
    // iPhone thật không dùng được localhost. 
    // Trí hãy đảm bảo IP này trùng với IPv4 khi gõ ipconfig trên máy tính.
    return 'http://192.168.1.4:8080'; 
  }

  List<Device> _devices = [];
  bool _isLoading = false;
  
  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();
  final _payloadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // Lấy danh sách thiết bị từ server
  Future<void> fetchDevices() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/devices'))
          .timeout(const Duration(seconds: 5)); // Không để app bị treo nếu mất mạng
      
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        setState(() {
          _devices = list.map((json) => Device.fromJson(json)).toList();
        });
      } else {
        _showSnackBar('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Không thể kết nối tới $_baseUrl. Kiểm tra Wifi!');
      debugPrint('Lỗi fetchDevices: $e');
    } finally {
      setState(() => _isLoading = false);
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
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _deviceNameController.clear();
        _deviceTopicController.clear();
        _showSnackBar('Thêm thiết bị thành công');
        fetchDevices(); 
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tạo: $e');
    }
  }

  // Điều khiển thiết bị
  Future<void> controlDevice(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/$id/control'),
        headers: {'Content-Type': 'text/plain'},
        body: _payloadController.text,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _showSnackBar('Lệnh đã gửi thành công');
      }
    } catch (e) {
      _showSnackBar('Gửi lệnh thất bại: $e');
    }
  }

  // Lấy dữ liệu Telemetry từ server
  Future<List<Telemetry>> fetchTelemetry(int deviceId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/telemetry/$deviceId'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((json) => Telemetry.fromJson(json)).toList();
      }
    } catch (e) {
      _showSnackBar('Lỗi tải Telemetry: $e');
    }
    return [];
  }

  Future<void> _showTelemetryDialog(int deviceId, String deviceName) async {
    List<Telemetry> telemetries = await fetchTelemetry(deviceId);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lịch sử - $deviceName'),
        content: SizedBox(
          width: double.maxFinite,
          child: telemetries.isEmpty
              ? const Text('Không có dữ liệu mới.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: telemetries.length,
                  itemBuilder: (context, index) {
                    final t = telemetries[index];
                    return ListTile(
                      leading: const Icon(Icons.sensors, color: Colors.blue),
                      title: Text(t.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(t.timestamp),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Device Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(onPressed: fetchDevices, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchDevices,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text('📋 Danh sách thiết bị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._devices.map((d) => Card(
                    color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 10),
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
                  TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: 'Tên thiết bị (VD: Den Phong Khach)')),
                  TextField(controller: _deviceTopicController, decoration: const InputDecoration(labelText: 'Topic (VD: /home/light)')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade200, foregroundColor: Colors.black),
                    onPressed: createDevice, 
                    child: const Text('Tạo thiết bị ngay')
                  ),
                  const SizedBox(height: 30),
                  const Text('🎮 Nhập lệnh điều khiển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _payloadController, 
                    decoration: const InputDecoration(hintText: 'Ví dụ: ON hoặc {"data": 20}', border: OutlineInputBorder())
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class Device {
  final int id;
  final String name;
  final String topic;
  Device({required this.id, required this.name, required this.topic});
  factory Device.fromJson(Map<String, dynamic> json) => Device(id: json['id'] ?? 0, name: json['name'] ?? '', topic: json['topic'] ?? '');
}

class Telemetry {
  final String timestamp;
  final String value;
  Telemetry({required this.timestamp, required this.value});
  factory Telemetry.fromJson(Map<String, dynamic> json) => Telemetry(timestamp: json['timestamp'] ?? '', value: json['value'] ?? '');
}