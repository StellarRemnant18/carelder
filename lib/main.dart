import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_state.dart';
import 'services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController();

  await FirebaseBootstrap.initialize(controller);

  runApp(AppScope(controller: controller, child: const CarelderApp()));
}
