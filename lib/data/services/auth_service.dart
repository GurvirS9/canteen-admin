import 'package:firebase_auth/firebase_auth.dart';
import 'package:manager_app/data/models/user.dart';
import 'package:manager_app/core/utils/logger.dart';

class AuthService {
  static const String _tag = 'AuthService';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AppUser _mapFirebaseUser(User user) {
    return AppUser(
      id: user.uid,
      name: user.displayName ?? 'Manager',
      email: user.email ?? '',
      role: 'manager',
      avatarUrl: user.photoURL,
    );
  }

  Future<AppUser> login(String email, String password) async {
    AppLogger.i(_tag, 'login() email=$email');
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _currentUser = _mapFirebaseUser(credential.user!);
        AppLogger.i(_tag, 'login() success: ${_currentUser!.email}');
        return _currentUser!;
      } else {
        throw Exception('Login failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.e(_tag, 'login() failed: ${e.message}');
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  Future<AppUser> signup(String email, String password, String name) async {
    AppLogger.i(_tag, 'signup() email=$email | name=$name');
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        _currentUser = _mapFirebaseUser(credential.user!);
        AppLogger.i(_tag, 'signup() success: ${_currentUser!.email}');
        return _currentUser!;
      } else {
        throw Exception('Signup failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.e(_tag, 'signup() failed: ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    AppLogger.i(_tag, 'sendPasswordResetEmail() email=$email');
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.i(_tag, 'sendPasswordResetEmail() success');
    } on FirebaseAuthException catch (e) {
      AppLogger.e(_tag, 'sendPasswordResetEmail() failed: ${e.message}');
      throw Exception(e.message ?? 'Failed to send reset email');
    }
  }

  Future<void> logout() async {
    AppLogger.i(_tag, 'logout()');
    await _firebaseAuth.signOut();
    _currentUser = null;
    AppLogger.d(_tag, 'logout() complete');
  }
}
