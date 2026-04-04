import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manager_app/data/models/user.dart';
import 'package:manager_app/data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
      return AuthNotifier(ref.read(authServiceProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthService _service;
  static const _userKey = 'canteen_user';

  AuthNotifier(this._service) : super(const AsyncData(null)) {
    checkSession();
  }

  bool get isLoggedIn => state.valueOrNull != null;

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);
      if (userStr != null) {
        final userData = jsonDecode(userStr);
        state = AsyncData(AppUser.fromJson(userData));
      } else {
        state = const AsyncData(null);
      }
    } catch (_) {
      // Silent fail if no saved session
      state = const AsyncData(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _service.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      final user = await _service.signup(email, password, name);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      await _service.sendPasswordResetEmail(email);
      state = const AsyncData(null); // Keep state null because reset doesn't login
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (_) {}

    await _service.logout();
    state = const AsyncData(null);
  }
}
