
import 'package:flutter/services.dart';

class HealthConnectService {
  static const MethodChannel _channel =
      MethodChannel('caringmate/health_connect');

  Future<String> checkAvailability() async {
    final result = await _channel.invokeMethod<String>(
      'checkAvailability',
    );

    return result ?? 'unknown';
  }

  Future<Map<String, bool>> requestPermissions() async {
    final result = await _channel.invokeMapMethod<String, bool>(
      'requestPermissions',
    );

    return result ?? {};
  }
}
