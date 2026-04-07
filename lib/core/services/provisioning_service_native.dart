import 'dart:async';
import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ProvisioningServiceImpl {
  static final Logger _logger = Logger();

  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<bool> provisionDevice({
    required String deviceName,
    required String pop,
    required String ssid,
    required String password,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call("Đang yêu cầu quyền truy cập...");
      if (!await requestPermissions()) {
        _logger.e("Chưa được cấp quyền Bluetooth/Vị trí");
        return false;
      }

      // 1. Tìm thiết bị qua Bluetooth
      onStatusUpdate?.call("Đang quét tìm $deviceName...");
      BluetoothDevice? targetDevice;
      
      // Bắt đầu quét
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      final scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.platformName == deviceName || r.device.advName == deviceName) {
            targetDevice = r.device;
          }
        }
      });

      // Đợi tìm thấy thiết bị hoặc timeout
      int retry = 0;
      while (targetDevice == null && retry < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        retry++;
      }
      
      await FlutterBluePlus.stopScan();
      scanSubscription.cancel();

      if (targetDevice == null) {
        onStatusUpdate?.call("Không tìm thấy thiết bị Bluetooth.");
        return false;
      }

      // 2. Thiết lập Provisioning (API v1.0.0)
      onStatusUpdate?.call("Đang kết nối tới thiết bị...");
      final transport = TransportBLE(targetDevice!);
      final security = Security1(pop: pop);
      final espProv = EspProv(transport: transport, security: security);

      onStatusUpdate?.call("Đang thực hiện bắt tay bảo mật...");
      await espProv.establishSession();
      
      onStatusUpdate?.call("Đang gửi thông tin WiFi...");
      await espProv.sendWifiConfig(ssid: ssid, password: password);
      
      onStatusUpdate?.call("Đang áp dụng cấu hình...");
      await espProv.applyWifiConfig();
      
      onStatusUpdate?.call("Hoàn tất! Đang đợi thiết bị kết nối WiFi...");
      await Future.delayed(const Duration(seconds: 3));
      
      await espProv.dispose();
      return true;
    } catch (e) {
      _logger.e("Lỗi Provisioning Native: $e");
      onStatusUpdate?.call("Lỗi: ${e.toString()}");
      return false;
    }
  }
}
