import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/presentation/providers/theme_provider.dart';
import 'package:manager_app/core/router/router.dart';
import 'package:manager_app/core/theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: CanteenManagerApp()));
}

class CanteenManagerApp extends ConsumerWidget {
  const CanteenManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Canteen Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
