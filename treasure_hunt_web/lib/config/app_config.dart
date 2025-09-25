class AppConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';

  // Production URLs - update these when deploying
  static const String prodBaseUrl = 'https://your-backend-url.vercel.app/api';
  static const String prodSocketUrl = 'https://your-backend-url.vercel.app';

  // Use production URLs in release mode
  static String get apiBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : baseUrl;
  }

  static String get socketBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodSocketUrl : socketUrl;
  }

  // App constants
  static const String appName = 'Treasure Hunt';
  static const int refreshInterval = 300000; // 5 minutes in milliseconds
  static const int socketReconnectInterval = 10000; // 10 seconds

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}
