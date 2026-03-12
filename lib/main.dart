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

    // Dùng IP Tailscale của máy tính (trivo)
    return 'http://100.114.50.44:8080';
  }

  List<Device> _devices = [];
  bool _isLoading = false;
  Map<int, TextEditingController> _deviceControllers = {};

  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();

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
      final response = await http.get(Uri.parse('$_baseUrl/devices')).timeout(
          const Duration(seconds: 5)); // Không để app bị treo nếu mất mạng

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
    if (_deviceNameController.text.isEmpty ||
        _deviceTopicController.text.isEmpty) return;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/devices'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _deviceNameController.text,
              'topic': _deviceTopicController.text,
            }),
          )
          .timeout(const Duration(seconds: 5));

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
      final response = await http
          .post(
            Uri.parse('$_baseUrl/devices/$id/control'),
            headers: {'Content-Type': 'text/plain'},
            body: _deviceControllers[id]?.text ?? '',
          )
          .timeout(const Duration(seconds: 5));

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
      final response = await http
          .get(Uri.parse('$_baseUrl/telemetry/$deviceId'))
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
        title: Text('Dữ liệu thiết bị - $deviceName'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: telemetries.isEmpty
              ? const Center(child: Text('Không có dữ liệu.'))
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng số bản ghi: ${telemetries.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (telemetries.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Giá trị mới nhất: ${telemetries.first.value}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Thời gian: ${telemetries.first.timestamp}',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Data List
                    Expanded(
                      child: ListView.builder(
                        itemCount: telemetries.length,
                        itemBuilder: (context, index) {
                          final t = telemetries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with ID and timestamp
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'ID: ${t.id ?? index + 1}',
                                          style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        t.timestamp,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Main value
                                  Text(
                                    'Nội dung: ${t.value}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  // Show all raw data if available
                                  if (t.rawData != null &&
                                      t.rawData!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Dữ liệu đầy đủ:',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          ...t.rawData!.entries
                                              .where((e) =>
                                                  e.key != 'id' &&
                                                  e.key != 'timestamp' &&
                                                  e.key != 'value')
                                              .map(
                                                (entry) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${entry.key}:',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          entry.value
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .black54),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          if (telemetries.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                fetchDevices(); // Refresh data
              },
              child: const Text('Làm mới'),
            ),
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
                    // Device List Section
                    const Text('Danh sách thiết bị',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ..._devices.map((d) => Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 15),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Device Name
                                Text(
                                  d.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                // MQTT Topic
                                Text(
                                  'MQTT Topic: ${d.topic}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                // Command Input and Buttons Section
                                TextField(
                                  controller: _deviceControllers[d.id] ??=
                                      TextEditingController(),
                                  decoration: InputDecoration(
                                    hintText: 'Nhập lệnh',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => controlDevice(d.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text('Gửi lệnh'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showTelemetryDialog(d.id, d.name),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text('Xem dữ liệu'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: 30),

                    // Add New Device Section
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add new device',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _deviceNameController,
                              decoration: InputDecoration(
                                labelText: 'Tên thiết bị',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _deviceTopicController,
                              decoration: InputDecoration(
                                labelText: 'Topic MQTT',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: createDevice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Tạo thiết bị'),
                              ),
                            ),
                          ],
                        ),
                      ),
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
  factory Device.fromJson(Map<String, dynamic> json) => Device(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      topic: json['topic'] ?? '');
}

class Telemetry {
  final int? id;
  final String timestamp;
  final String value;
  final int? deviceId;
  final Map<String, dynamic>? rawData;

  Telemetry(
      {this.id,
      required this.timestamp,
      required this.value,
      this.deviceId,
      this.rawData});

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    // Store all raw data for complete display
    Map<String, dynamic> allData = Map<String, dynamic>.from(json);

    return Telemetry(
      id: json['id'],
      timestamp: json['timestamp'] ?? json['created_at'] ?? '',
      value:
          json['value'] ?? json['data'] ?? json['payload'] ?? json.toString(),
      deviceId: json['device_id'],
      rawData: allData,
    );
  }
}
