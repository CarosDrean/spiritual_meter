import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_meter/main.dart';
import 'package:spiritual_meter/src/data/model/activity_log.dart';
import 'package:spiritual_meter/src/presentation/widget/app_section_card.dart';

import 'package:spiritual_meter/src/core/constant.dart';
import 'package:spiritual_meter/src/data/database/database_helper.dart';
import 'package:spiritual_meter/src/presentation/widget/home/prayer_gauge.dart';
import 'package:spiritual_meter/src/presentation/widget/home/timer_dialog.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Random _random = Random();

  bool _isPrayerOn = false;
  bool _isBibleReadingOn = false;

  DateTime? _timerStartTime;
  String? _activeTimerType;

  Duration _todayPrayerDuration = Duration.zero;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadTimerState();
    _loadPrayerToday();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveTimerState();
      if (_isPrayerOn || _isBibleReadingOn) {
        _showReminderNotification();
      }
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
      _cancelReminderNotification();
    }
  }

  Future<void> _showReminderNotification() async {
    String title = '';
    String body = '';

    if (_isPrayerOn) {
      title = 'Oración en curso';
      body =
          'No olvides retomar tu tiempo de oración. ¡Aún puedes conectarte con Dios!';
    } else if (_isBibleReadingOn) {
      title = 'Lectura bíblica en curso';
      body = 'No olvides seguir leyendo la Palabra. ¡Tu espíritu lo necesita!';
    }

    await flutterLocalNotificationsPlugin.cancel(0);

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(milliseconds: 500));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // id
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

  Future<void> _cancelReminderNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _loadPrayerToday() async {
    final now = DateTime.now();
    final logs = await _dbHelper.getDailyLogs(now);

    Duration prayerToday = Duration.zero;
    for (var log in logs) {
      if (log.activityType == kActivityTypePrayer) {
        prayerToday += Duration(seconds: log.durationInSeconds);
      }
    }

    setState(() {
      _todayPrayerDuration = prayerToday;
    });
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if ((_isPrayerOn || _isBibleReadingOn) &&
        _timerStartTime != null &&
        _activeTimerType != null) {
      prefs.setString('timerStartTime', _timerStartTime!.toIso8601String());
      prefs.setString('activeTimerType', _activeTimerType!);
    } else {
      prefs.remove('timerStartTime');
      prefs.remove('activeTimerType');
    }
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final startString = prefs.getString('timerStartTime');
    final activeType = prefs.getString('activeTimerType');

    if (startString != null && activeType != null) {
      final savedStart = DateTime.parse(startString);
      _timerStartTime = savedStart;
      _activeTimerType = activeType;

      if (activeType == kActivityTypePrayer) {
        _isPrayerOn = true;
        _isBibleReadingOn = false;
      } else if (activeType == kActivityTypeBibleReading) {
        _isBibleReadingOn = true;
        _isPrayerOn = false;
      }

      if (!_isDialogShowing) {
        _isDialogShowing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTimerDialog(
            activeType == kActivityTypePrayer
                ? 'Tiempo de Oración'
                : 'Tiempo de Lectura Bíblica',
          );
        });
      }
    } else {
      _resetTimerState();
    }
  }

  void _resetTimerState() {
    setState(() {
      _isPrayerOn = false;
      _isBibleReadingOn = false;
      _timerStartTime = null;
      _activeTimerType = null;
    });
    _isDialogShowing = false;
    _saveTimerState();
  }

  void _showTimerDialog(String dialogTitle) {
    if (_timerStartTime == null) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TimerDialog(
          title: dialogTitle,
          startTime: _timerStartTime!,
          onStop: (Duration finalDuration) async {
            if (_activeTimerType != null && finalDuration.inSeconds > 0) {
              final newLog = ActivityLog(
                activityType: _activeTimerType!,
                durationInSeconds: finalDuration.inSeconds,
                endTime: DateTime.now(),
              );
              await _dbHelper.insertActivityLog(newLog);
            }
            _resetTimerState();
          },
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  String getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  String getPrayerMessage(double minutes) {
    if (minutes == 0) {
      return getRandomMessage(kNoPrayerMessages);
    } else if (minutes < 30) {
      return getRandomMessage(kRedMessages);
    } else if (minutes < 60) {
      return getRandomMessage(kYellowMessages);
    } else {
      return getRandomMessage(kGreenMessages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(kAppName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSectionCard(
              title: kPhraseTitle,
              content: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(
                      "El espíritu a la verdad está dispuesto, pero la carne es débil.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              bottomButton: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agregar frase presionado')),
                  );
                },
                child: const Text(kAddPhraseButtonText),
              ),
            ),

            AppSectionCard(
              title: kStartSectionTitle,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          kPrayerText,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isPrayerOn,
                        onChanged: (bool value) {
                          setState(() {
                            _isPrayerOn = value;
                            if (value) {
                              _isBibleReadingOn = false;
                              _timerStartTime = DateTime.now();
                              _activeTimerType = kActivityTypePrayer;
                              _showTimerDialog('Tiempo de Oración');
                            } else {
                              _loadPrayerToday();
                              _resetTimerState();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.grey,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          kBibleReadingText,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isBibleReadingOn,
                        onChanged: (bool value) {
                          setState(() {
                            _isBibleReadingOn = value;
                            if (value) {
                              _isPrayerOn = false;
                              _timerStartTime = DateTime.now();
                              _activeTimerType = kActivityTypeBibleReading;
                              _showTimerDialog('Tiempo de Lectura Bíblica');
                            } else {
                              _resetTimerState();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              // bottomButton: addRecordButton,
            ),

            AppSectionCard(
              title: 'Como voy',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrayerGauge(
                    prayerTimeInSeconds: _todayPrayerDuration.inSeconds,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    getPrayerMessage(_todayPrayerDuration.inSeconds / 60),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
