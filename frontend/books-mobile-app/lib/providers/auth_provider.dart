import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Authentication state management.
class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  String? _token;
  String? _clientName;
  String? _clientEmail;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._api);

  String? get token => _token;
  String? get clientName => _clientName;
  String? get clientEmail => _clientEmail;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load saved token from SharedPreferences.
  Future<void> loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    if (_token != null) _api.token = _token;
    notifyListeners();
  }

  /// Register new client.
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _token = await _api.register(name, email, password);
      _clientName = name;
      _clientEmail = email;
      await _saveToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _token = await _api.login(email, password);
      _clientName = null;
      _clientEmail = email;
      await _saveToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with existing token.
  Future<void> loginWithToken(String token) async {
    _token = token;
    _api.token = token;
    await _saveToken(token);
    notifyListeners();
  }

  /// Logout and clear token.
  Future<void> logout() async {
    _token = null;
    _clientName = null;
    _clientEmail = null;
    _api.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }

  /// Reset server and clear session.
  Future<bool> resetServer() async {
    try {
      await _api.resetServer();
      await logout();
      return true;
    } catch (e) {
      _error = 'Failed to reset server.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    _api.token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
}
