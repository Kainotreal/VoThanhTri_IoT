import 'dart:async';
// Sử dụng conditional import để chọn file logic phù hợp theo nền tảng
import 'provisioning_service_web.dart' 
  if (dart.library.io) 'provisioning_service_native.dart';

class ProvisioningService {
  /// Yêu cầu các quyền cần thiết cho Bluetooth/Vị trí
  static Future<bool> requestPermissions() async {
    return ProvisioningServiceImpl.requestPermissions();
  }

  /// Bắt đầu luồng Provisioning (Cấp quyền WiFi cho ESP32)
  static Future<bool> provisionDevice({
    required String deviceName,
    required String pop,
    required String ssid,
    required String password,
    Function(String)? onStatusUpdate,
  }) async {
    return ProvisioningServiceImpl.provisionDevice(
      deviceName: deviceName,
      pop: pop,
      ssid: ssid,
      password: password,
      onStatusUpdate: onStatusUpdate,
    );
  }
}
