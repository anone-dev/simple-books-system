/// Application configuration.
class AppConfig {
  /// Base URL for the API server.
  /// Change this to point to a different server instance.
  static String baseUrl = 'http://10.0.2.2:5001'; // Android emulator → host

  /// For iOS simulator, use 'http://localhost:5001'
  /// For physical device, use actual IP: 'http://192.168.x.x:5001'

  static const int pageSize = 5;
}
