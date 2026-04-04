import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_app/presentation/providers/auth_provider.dart';
import 'package:manager_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:manager_app/presentation/screens/splash/splash_screen.dart';
import 'package:manager_app/presentation/screens/auth/login_screen.dart';
import 'package:manager_app/presentation/screens/auth/signup_screen.dart';
import 'package:manager_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:manager_app/presentation/screens/main_shell.dart';
import 'package:manager_app/presentation/screens/menu/menu_screen.dart';
import 'package:manager_app/presentation/screens/orders/orders_screen.dart';
import 'package:manager_app/presentation/screens/profile/profile_screen.dart';
import 'package:manager_app/presentation/screens/slots/slots_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (prev, next) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      
      // While auth is still loading, stay on splash
      if (authState.isLoading) return null;
      
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup' || 
                           state.matchedLocation == '/forgot-password';
      final isSplashRoute = state.matchedLocation == '/';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && (isAuthRoute || isSplashRoute)) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) {
          final index = _indexFromLocation(state.matchedLocation);
          return MainShell(
            currentIndex: index,
            onTabChanged: (i) {
              context.go(_locationFromIndex(i));
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MenuScreen()),
          ),
          GoRoute(
            path: '/slots',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SlotsScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

int _indexFromLocation(String location) {
  switch (location) {
    case '/dashboard':
      return 0;
    case '/menu':
      return 1;
    case '/slots':
      return 2;
    case '/orders':
      return 3;
    case '/profile':
      return 4;
    default:
      return 0;
  }
}

String _locationFromIndex(int index) {
  switch (index) {
    case 0:
      return '/dashboard';
    case 1:
      return '/menu';
    case 2:
      return '/slots';
    case 3:
      return '/orders';
    case 4:
      return '/profile';
    default:
      return '/dashboard';
  }
}
