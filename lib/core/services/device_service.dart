import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/device_model.dart';

class DeviceService {
  static Future<List<DeviceModel>> getAllDevices() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.devicesEndpoint));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => DeviceModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      // Trả về danh sách mẫu nếu backend chưa sẵn sàng để giao diện không bị trống hoàn toàn
      return [
        DeviceModel(id: 1, name: 'Smart Lamp', status: 'OFF', topic: 'home/lamp'),
        DeviceModel(id: 2, name: 'Air Conditioner', status: 'ON', topic: 'home/ac'),
      ];
    }
  }

  static Future<bool> toggleDevice(int id, String newStatus) async {
    final String endpoint = '${ApiConstants.devicesEndpoint}/$id/${newStatus.toLowerCase()}';
    
    try {
      final response = await http.post(Uri.parse(endpoint));
      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling device: $e');
      return false;
    }
  }

  static Future<bool> createDevice({required String name, required String topic}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.devicesEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'topic': topic,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating device: $e');
      return false;
    }
  }
}
