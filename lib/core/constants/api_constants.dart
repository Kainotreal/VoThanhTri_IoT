class ApiConstants {
  // Thay đổi IP này thành IP máy tính của bạn nếu chạy trên thiết bị thật
  // Hoặc 10.0.2.2 nếu chạy trên giả lập Android
  static const String baseUrl = 'http://192.168.1.4:8080/api';
  
  static const String devicesEndpoint = '$baseUrl/devices';
}
