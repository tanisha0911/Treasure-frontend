import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isLoading => _isLoading;

  // Dummy credentials for testing
  static const Map<String, Map<String, dynamic>> _dummyUsers = {
    'admin@treasurehunt.com': {
      'password': 'admin123',
      'id': '1',
      'name': 'Admin User',
      'email': 'admin@treasurehunt.com',
      'role': 'admin',
    },
    'coordinator@treasurehunt.com': {
      'password': 'coord123',
      'id': '2',
      'name': 'Coordinator User',
      'email': 'coordinator@treasurehunt.com',
      'role': 'coordinator',
    },
  };

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);
      final userData = prefs.getString(AppConfig.userKey);

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson({
          ...Map<String, dynamic>.from(
            Uri.splitQueryString(userData),
          ),
        });

        // Set token in API service
        ApiService.setAuthToken(token);

        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auto login error: $e');
      }
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check dummy credentials first
      if (_dummyUsers.containsKey(email)) {
        final userInfo = _dummyUsers[email]!;
        if (userInfo['password'] == password) {
          // Mock successful login
          await Future.delayed(
              const Duration(seconds: 1)); // Simulate network delay

          _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
          _user = User(
            id: userInfo['id'],
            name: userInfo['name'],
            email: userInfo['email'],
            role: userInfo['role'],
            createdAt: DateTime.now(),
          );

          // Set token in API service
          ApiService.setAuthToken(_token!);

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.tokenKey, _token!);
          await prefs.setString(AppConfig.userKey, _user!.toJson().toString());

          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If not a dummy user, try actual API call
      final authResponse = await ApiService.login(email, password);

      _token = authResponse.token;
      _user = authResponse.user;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenKey, _token!);
      await prefs.setString(AppConfig.userKey, _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(
      String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse =
          await ApiService.register(name, email, password, role);

      _token = authResponse.token;
      _user = authResponse.user;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenKey, _token!);
      await prefs.setString(AppConfig.userKey, _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _user = null;
      _token = null;

      // Clear API service token
      ApiService.clearAuthToken();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.tokenKey);
      await prefs.remove(AppConfig.userKey);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }

  bool hasRole(String role) {
    return _user?.role == role;
  }

  bool get isAdmin => hasRole('admin');
  bool get isCoordinator => hasRole('coordinator');

  // Helper method to get dummy credentials info
  static String getDummyCredentialsInfo() {
    return '''
Dummy Login Credentials:

Admin Account:
Email: admin@treasurehunt.com
Password: admin123

Coordinator Account:
Email: coordinator@treasurehunt.com  
Password: coord123
''';
  }
}
