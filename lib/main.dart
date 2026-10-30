import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleDeviceCheckProvider(),
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
