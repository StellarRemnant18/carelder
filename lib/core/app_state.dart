import 'package:flutter/material.dart';

import '../models/app_models.dart';

/// Lightweight in-memory application state.
/// Replace or extend this with a persistent repository when backend work starts.
class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _waterIntakeMl = 0;
  final List<MedicationEntry> _medications = <MedicationEntry>[];
  final List<AppNotification> _notifications = <AppNotification>[];

  ThemeMode get themeMode => _themeMode;
  int get waterIntakeMl => _waterIntakeMl;
  List<MedicationEntry> get medications =>
      List<MedicationEntry>.unmodifiable(_medications);
  List<AppNotification> get notifications =>
      List<AppNotification>.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((item) => !item.isRead).length;

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void addWater(int millilitres) {
    if (millilitres <= 0) return;
    _waterIntakeMl += millilitres;
    notifyListeners();
  }

  void resetWater() {
    if (_waterIntakeMl == 0) return;
    _waterIntakeMl = 0;
    notifyListeners();
  }

  void addMedication(MedicationEntry entry) {
    _medications.insert(0, entry);
    notifyListeners();
  }

  void toggleMedication(String id, bool completed) {
    final index = _medications.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _medications[index] = _medications[index].copyWith(isCompleted: completed);
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index < 0 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    if (_notifications.every((item) => item.isRead)) return;
    for (var index = 0; index < _notifications.length; index++) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearNotifications() {
    if (_notifications.isEmpty) return;
    _notifications.clear();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!.notifier!;
  }
}
