import 'dart:async';

class ProvisioningServiceImpl {
  static Future<bool> requestPermissions() async {
    return true; // Luôn trả về true trên Web
  }

  static Future<bool> provisionDevice({
    required String deviceName,
    required String pop,
    required String ssid,
    required String password,
    Function(String)? onStatusUpdate,
  }) async {
    onStatusUpdate?.call("Bluetooth không hỗ trợ trên trình duyệt.");
    await Future.delayed(const Duration(seconds: 2));
    onStatusUpdate?.call("Vui lòng sử dụng điện thoại thật để cài đặt.");
    return false;
  }
}
