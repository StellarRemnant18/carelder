import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'screens/auth_gate.dart';

class CarelderApp extends StatelessWidget {
  const CarelderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return MaterialApp(
      title: 'CaringMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: controller.themeMode,
      home: const AuthGate(),
    );
  }
}
