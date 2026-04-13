import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:manager_app/data/models/user.dart';
import 'package:manager_app/core/utils/logger.dart';

class AuthService {
  static const String _tag = 'AuthService';

  final _auth = Supabase.instance.client.auth;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AppUser _mapSession(Session session, [User? user]) {
    final u = user ?? session.user;
    final meta = u.userMetadata ?? {};
    return AppUser(
      id: u.id, // proper UUID ✅
      name: meta['full_name'] as String? ??
            meta['name'] as String? ?? 'Manager',
      email: u.email ?? '',
      role: 'owner',
    );
  }

  Future<AppUser> login(String email, String password) async {
    AppLogger.i(_tag, 'login() email=$email');
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw Exception('Login failed: no session returned');
      }
      _currentUser = _mapSession(response.session!, response.user);
      AppLogger.i(_tag, 'login() success uid=${_currentUser!.id}');
      return _currentUser!;
    } on AuthException catch (e) {
      AppLogger.e(_tag, 'login() failed: ${e.message}');
      throw Exception(e.message);
    }
  }

  Future<AppUser> signup(String email, String password, String name) async {
    AppLogger.i(_tag, 'signup() email=$email | name=$name');
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      if (response.session == null) {
        // Email confirmation may be required — create a local user object
        // from the partial user data so the UI can continue.
        final u = response.user;
        if (u == null) throw Exception('Signup failed: user is null');
        _currentUser = AppUser(
          id: u.id,
          name: name.trim(),
          email: u.email ?? email,
          role: 'owner',
        );
        AppLogger.w(_tag, 'signup() email confirmation required');
        return _currentUser!;
      }
      _currentUser = _mapSession(response.session!, response.user);
      AppLogger.i(_tag, 'signup() success uid=${_currentUser!.id}');
      return _currentUser!;
    } on AuthException catch (e) {
      AppLogger.e(_tag, 'signup() failed: ${e.message}');
      throw Exception(e.message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    AppLogger.i(_tag, 'sendPasswordResetEmail() email=$email');
    try {
      await _auth.resetPasswordForEmail(email.trim());
      AppLogger.i(_tag, 'sendPasswordResetEmail() success');
    } on AuthException catch (e) {
      AppLogger.e(_tag, 'sendPasswordResetEmail() failed: ${e.message}');
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    AppLogger.i(_tag, 'logout()');
    await _auth.signOut();
    _currentUser = null;
    AppLogger.d(_tag, 'logout() complete');
  }

  /// Restore session from Supabase's persisted storage (called on app start).
  AppUser? restoreSession() {
    final session = _auth.currentSession;
    if (session == null) return null;
    _currentUser = _mapSession(session);
    AppLogger.i(_tag, 'restoreSession() uid=${_currentUser!.id}');
    return _currentUser;
  }
}
