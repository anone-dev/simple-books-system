/// Application configuration.
class AppConfig {
  /// Base URL for the API server.
  /// Change this to point to a different server instance.
  static String baseUrl = 'http://10.0.2.2:3100'; // Android emulator → host

  /// For iOS simulator, use 'http://localhost:3100'
  /// For physical device, use actual IP: 'http://192.168.x.x:3100'

  static const int pageSize = 5;
}
