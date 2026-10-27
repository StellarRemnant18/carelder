import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(const CARELDERApp());
}

class CARELDERApp extends StatelessWidget {
  const CARELDERApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CARELDER',
      home: Scaffold(
        appBar: AppBar(title: const Text('CARELDER')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              throw Exception('Test Crash');
            },
            child: const Text('Test Crash'),
          ),
        ),
      ),
    );
  }
}
