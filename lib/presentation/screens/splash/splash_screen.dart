import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/presentation/providers/auth_provider.dart';
import 'package:manager_app/core/theme/app_colors.dart';
import 'package:manager_app/core/utils/logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    AppLogger.i('SplashScreen', 'Starting session check with 3s timeout');
    
    try {
      // Artificial delay to show the beautiful splash
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // Use wait with a 3-second timeout
      await ref.read(authStateProvider.notifier).checkSession().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          AppLogger.w('SplashScreen', 'Session check timed out after 3s');
          // If it times out, the authState will likely still be 'loading'
          // We can force it to navigate by updating the state or letting it resolve.
        },
      );
      
      AppLogger.i('SplashScreen', 'Session check completed');
    } catch (e) {
      AppLogger.e('SplashScreen', 'Error during session check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 32),
              const Text(
                'CANTEEN MANAGER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, duration: 600.ms, delay: 300.ms)
                  .fadeIn(duration: 600.ms, delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                'Command Center',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms),
              const SizedBox(height: 64),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
