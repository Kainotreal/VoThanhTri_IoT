import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Tài khoản Admin mặc định
  static const String adminEmail = 'admin';
  static const String adminPassword = '123456';

  /// Lưu thông tin đăng ký/đăng nhập vào bộ nhớ local
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyIsLoggedIn, true);
    print("Session saved for: $email");
  }

  /// Kiểm tra thông tin đăng nhập
  static Future<bool> validateLogin(String email, String password) async {
    // Kiểm tra tài khoản admin mặc định
    if (email == adminEmail && password == adminPassword) {
      await saveCredentials(adminEmail, adminPassword);
      return true;
    }

    // Ở đây có thể thêm logic kiểm tra với DB hoặc SharedPreferences nếu cần
    // Hiện tại chúng ta giả định mọi email/password hợp lệ đều cho phép vào 
    // và admin là tài khoản đặc biệt được xác định cứng.
    return true; 
  }

  /// Lấy email đã lưu
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Đăng xuất - Xóa session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
