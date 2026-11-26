import 'package:firebase_messaging/firebase_messaging.dart';

abstract interface class NotificationPermissionService {
  Future<AuthorizationStatus> getPermissionStatus();

  Future<AuthorizationStatus> requestPermission();
}

class FirebaseMessagingService implements NotificationPermissionService {
  FirebaseMessagingService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  @override
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus;
  }
}
