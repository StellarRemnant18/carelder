import 'package:flutter/foundation.dart';

@immutable
class MedicationEntry {
  const MedicationEntry({
    required this.id,
    required this.name,
    required this.schedule,
    this.notes = '',
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final String schedule;
  final String notes;
  final bool isCompleted;

  MedicationEntry copyWith({bool? isCompleted}) {
    return MedicationEntry(
      id: id,
      name: name,
      schedule: schedule,
      notes: notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
