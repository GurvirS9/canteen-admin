import 'package:flutter_riverpod/flutter_riverpod.dart';
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


  AuthNotifier(this._service, this._ref) : super(const AsyncData(null)) {
    checkSession();
  }

  bool get isLoggedIn => state.valueOrNull != null;

  Future<void> checkSession() async {
    try {
      // Use Supabase's persisted session (primary source of truth)
      final restoredUser = _service.restoreSession();
      if (restoredUser != null) {
        state = AsyncData(restoredUser);
        _ref.read(shopProvider.notifier).loadMyShop(restoredUser.id);
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
    await _service.logout();
    state = const AsyncData(null);
  }
}
