import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/presentation/providers/debug_provider.dart';
import 'package:manager_app/presentation/providers/theme_provider.dart';
import 'package:manager_app/presentation/widgets/debug_overlay.dart';
import 'package:manager_app/core/router/router.dart';
import 'package:manager_app/core/theme/app_theme.dart';
import 'package:manager_app/core/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:manager_app/firebase_options.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  HttpOverrides.global = DevHttpOverrides();
  runApp(const ProviderScope(child: CanteenManagerApp()));
}

class CanteenManagerApp extends ConsumerStatefulWidget {
  const CanteenManagerApp({super.key});

  @override
  ConsumerState<CanteenManagerApp> createState() => _CanteenManagerAppState();
}

class _CanteenManagerAppState extends ConsumerState<CanteenManagerApp> {
  @override
  void initState() {
    super.initState();
    // Wire up the logger to the debug provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final debugNotifier = ref.read(debugProvider);
      AppLogger.init(debugNotifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Canteen Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDark ? AppColors.surfaceDark : AppColors.primary,
          child: Stack(
            children: [
              if (child != null) child else const SizedBox.shrink(),
              const DebugOverlay(),
            ],
          ),
        );
      },
    );
  }
}
