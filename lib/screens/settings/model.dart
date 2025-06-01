import 'package:flutter/material.dart';

class StaticNotificationSetting {
  final String id;
  final String type;
  TimeOfDay timeOfDay;
  bool isEnabled;
  final String label;

  StaticNotificationSetting({
    required this.id,
    required this.type,
    required this.timeOfDay,
    this.isEnabled = true,
    required this.label,
  });

  StaticNotificationSetting copyWith({
    bool? isEnabled,
    TimeOfDay? timeOfDay,
  }) {
    return StaticNotificationSetting(
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

  factory StaticNotificationSetting.fromJson(Map<String, dynamic> json) {
    return StaticNotificationSetting(
      id: json['id'],
      type: json['type'],
      timeOfDay: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isEnabled: json['isEnabled'],
      label: json['label'],
    );
  }
}