import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../core/app_state.dart';
import '../models/app_models.dart';
import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize(AppController controller) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('Firebase Core initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    await _initializeAppCheck();
    _initializeCrashlytics();
    await _initializePerformance();
    await _initializeRemoteConfig();
    await _initializeMessaging(controller);
    await logEvent('caringmate_app_initialized');
  }

  static Future<void> _initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
      );
    } catch (error) {
      debugPrint('App Check setup warning: $error');
    }
  }

  static void _initializeCrashlytics() {
    try {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    } catch (error) {
      debugPrint('Crashlytics setup warning: $error');
    }
  }

  static Future<void> _initializePerformance() async {
    try {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    } catch (error) {
      debugPrint('Performance setup warning: $error');
    }
  }

  static Future<void> _initializeRemoteConfig() async {
    try {
      final config = FirebaseRemoteConfig.instance;
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await config.fetchAndActivate();
    } catch (error) {
      debugPrint('Remote Config setup warning: $error');
    }
  }

  static Future<void> _initializeMessaging(AppController controller) async {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? 'New notification';
        final body =
            message.notification?.body ??
            'A new message was received by CaringMate.';
        controller.addNotification(
          AppNotification(
            id:
                message.messageId ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            body: body,
            receivedAt: DateTime.now(),
          ),
        );
      });

      // Keep the token private. Send it to a trusted backend only when a
      // registration flow and appropriate security rules are implemented.
      await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('Cloud Messaging setup warning: $error');
    }
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analytics event failed ($name): $error');
    }
  }
}
