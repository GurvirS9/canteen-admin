import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_app/data/models/user.dart';
import 'package:manager_app/core/utils/demo_data.dart';
import 'package:manager_app/data/services/api_config.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<AppUser> login(String email, String password) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentUser = DemoData.demoManager;
      return _currentUser!;
    }

    final response = await http.post(
      Uri.parse(ApiConfig.url('/auth/login')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      _currentUser = AppUser.fromJson(jsonDecode(response.body));
      return _currentUser!;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    if (!ApiConfig.isDemoMode) {
      try {
        await http.post(Uri.parse(ApiConfig.url('/auth/logout')));
      } catch (_) {}
    }
    _currentUser = null;
  }
}
