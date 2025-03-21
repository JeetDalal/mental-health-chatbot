import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mental_health_chatbot/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String name, String email, String password) async {
    _setLoadingState(true);
    final url = Uri.parse('$BASE_URL/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        await _saveToken(_token!);
        _setErrorMessage(null);
      } else {
        _setErrorMessage(data['message'] ?? 'Registration failed');
      }
    } catch (error) {
      _setErrorMessage('Something went wrong. Please try again.');
      _setLoadingState(false);
      return false;
    } finally {
      _setLoadingState(false);
    }
    return true;
  }

  Future<bool> login(String email, String password) async {
    _setLoadingState(true);
    final url = Uri.parse('$BASE_URL/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        await _saveToken(_token!);
        _setErrorMessage(null);
      } else {
        _setErrorMessage(data['message'] ?? 'Login failed');
      }
    } catch (error) {
      _setErrorMessage('Something went wrong. Please try again.');
      _setLoadingState(false);
      return false;
    } finally {
      _setLoadingState(false);
    }
    return true;
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void _setLoadingState(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
