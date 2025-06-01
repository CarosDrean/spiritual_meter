import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> showReminder(String title, String body) async {
    await _plugin.cancel(0);
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(milliseconds: 500));

    await _plugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(0);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    bool repeatsDaily = true,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatsDaily ? DateTimeComponents.time : null,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
