import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'new_reminder_channel',
    'Recordatorios',
    description: 'Canal para notificaciones de recordatorios',
    importance: Importance.high,
  );

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
        'new_reminder_channel',
        'Recordatorios',
        channelDescription: 'Canal para notificaciones de recordatorios',
        importance: Importance.high,
        priority: Priority.high,
      );

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      if (await androidPlugin.areNotificationsEnabled() == false) {
        await androidPlugin.requestNotificationsPermission();
      }
      if (await androidPlugin.canScheduleExactNotifications() == false) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    // Lógica para manejar el toque de la notificación cuando la app está en primer plano
    // Aquí puedes usar una clave global para navegar, o un NavigatorService.
    // Ejemplo:
    // if (payload != null) {
    //   MyApp.navigatorKey.currentState?.pushNamed('/details', arguments: payload);
    // }
  }

  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification background payload: $payload');
    }
    // Lógica para manejar el toque de la notificación cuando la app está en segundo plano/terminada
    // Nota: No puedes acceder directamente al contexto de Flutter UI aquí.
    // Si necesitas navegación, usa rutas con nombres y NavigatorKey global, o una función de aislamiento.
  }

  Future<void> showReminder(String title, String body) async {
    await _plugin.cancel(0);
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: 5));

    await _plugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: _androidNotificationDetails,
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
        android: _androidNotificationDetails,
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
