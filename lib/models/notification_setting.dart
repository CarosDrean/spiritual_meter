import 'package:flutter/material.dart';

class NotificationSetting {
  final String id;
  final String type;
  final String label;
  TimeOfDay timeOfDay;
  bool isEnabled;

  NotificationSetting({
    required this.id,
    required this.type,
    required this.label,
    required this.timeOfDay,
    this.isEnabled = true,
  });

  NotificationSetting copyWith({
    bool? isEnabled,
    TimeOfDay? timeOfDay,
  }) {
    return NotificationSetting(
      id: id,
      type: type,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
      'isEnabled': isEnabled,
      'label': label,
    };
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      id: json['id'],
      type: json['type'],
      timeOfDay: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isEnabled: json['isEnabled'],
      label: json['label'],
    );
  }
}