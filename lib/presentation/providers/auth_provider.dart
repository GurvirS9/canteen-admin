import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manager_app/data/models/user.dart';
import 'package:manager_app/data/services/auth_service.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
      return AuthNotifier(ref.read(authServiceProvider), ref);
    });

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthService _service;
  final Ref _ref;
  static const _userKey = 'canteen_user';

  AuthNotifier(this._service, this._ref) : super(const AsyncData(null)) {
    checkSession();
  }

  bool get isLoggedIn => state.valueOrNull != null;

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);
      // First try Supabase's persisted session (primary source of truth)
      final restoredUser = _service.restoreSession();
      if (restoredUser != null) {
        state = AsyncData(restoredUser);
        _ref.read(shopProvider.notifier).loadMyShop(restoredUser.id);
        return;
      }
      // Fall back to cached JSON (covers edge cases)
      if (userStr != null) {
        final userData = jsonDecode(userStr);
        final user = AppUser.fromJson(userData);
        state = AsyncData(user);
        _ref.read(shopProvider.notifier).loadMyShop(user.id);
      } else {
        state = const AsyncData(null);
      }
    } catch (_) {
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
      // Auto-load the shop owned by this user
      _ref.read(shopProvider.notifier).loadMyShop(user.id);
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
      // New managers have no shop yet — mark shops as loaded (empty) so the
      // router redirect detects myShop == null and navigates to /onboarding.
      _ref.read(shopProvider.notifier).markShopsLoaded([]);
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
