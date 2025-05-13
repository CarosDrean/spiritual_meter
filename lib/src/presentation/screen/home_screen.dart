import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_meter/src/presentation/widget/app_section_card.dart';

import 'package:spiritual_meter/src/core/constant.dart';
import 'package:spiritual_meter/src/data/database/database_helper.dart';
import 'package:spiritual_meter/src/data/model/activity_log.dart';
import 'package:spiritual_meter/src/presentation/widget/home/timer_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isPrayerOn = false;
  bool _isBibleReadingOn = false;
  String _currentStartSectionTitle = kStartSectionTitleDialog;

  DateTime? _timerStartTime;
  String? _activeTimerType;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if ((_isPrayerOn || _isBibleReadingOn) && _timerStartTime != null && _activeTimerType != null) {
      prefs.setString('timerStartTime', _timerStartTime!.toIso8601String());
      prefs.setString('activeTimerType', _activeTimerType!);
    } else {
      prefs.remove('timerStartTime');
      prefs.remove('activeTimerType');
    }
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStartTimeString = prefs.getString('timerStartTime');
    final savedActiveTimerType = prefs.getString('activeTimerType');

    if (savedStartTimeString != null && savedActiveTimerType != null) {
      final savedStartTime = DateTime.parse(savedStartTimeString);
      final currentTime = DateTime.now();
      final elapsedTime = currentTime.difference(savedStartTime);

      if (elapsedTime.inSeconds > 0) {
        setState(() {
          _activeTimerType = savedActiveTimerType;
          if (_activeTimerType == kActivityTypePrayer) {
            _isPrayerOn = true;
            _isBibleReadingOn = false;
            _currentStartSectionTitle = 'Orando...';
          } else if (_activeTimerType == kActivityTypeBibleReading) {
            _isBibleReadingOn = true;
            _isPrayerOn = false;
            _currentStartSectionTitle = 'Leyendo la Biblia...';
          }
        });

        _showTimerDialog(
          _activeTimerType == "prayer" ? 'Tiempo de Oración' : 'Tiempo de Lectura Bíblica',
          initialDuration: elapsedTime,
        );
      } else {
        _resetTimerState();
      }
    } else {
      _resetTimerState();
    }
  }

  void _resetTimerState() {
    setState(() {
      _isPrayerOn = false;
      _isBibleReadingOn = false;
      _currentStartSectionTitle = kStartSectionTitleDialog;
      _timerStartTime = null;
      _activeTimerType = null;
    });
    _saveTimerState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
      ),
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
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "El espíritu a la verdad está dispuesto, pero la carne es débil.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
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
                        child: Text(kPrayerText, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isPrayerOn,
                        onChanged: (bool value) {
                          setState(() {
                            _isPrayerOn = value;
                            if (value) {
                              _isBibleReadingOn = false;
                              _currentStartSectionTitle = 'Tiempo de Oración';
                              _timerStartTime = DateTime.now();
                              _activeTimerType = "prayer";
                              _showTimerDialog(_currentStartSectionTitle, initialDuration: null);
                            } else {
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
                        child: Text(kBibleReadingText, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isBibleReadingOn,
                        onChanged: (bool value) {
                          setState(() {
                            _isBibleReadingOn = value;
                            if (value) {
                              _isPrayerOn = false;
                              _currentStartSectionTitle = 'Tiempo de Lectura Bíblica';
                              _timerStartTime = DateTime.now();
                              _activeTimerType = "bibleReading";
                              _showTimerDialog(_currentStartSectionTitle, initialDuration: null);
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
                  Center(
                    child: Container(
                      width: 150, // Ancho del medidor
                      height: 75, // Altura del medidor
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200, // Color de fondo del placeholder
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Gráfico de progreso\n(Placeholder)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Que pasa no has orado nada hoy, recuerda que el poder del cristiano está en la oración, ¡Ora y vencerás, ora y las cosas saldrán mejor, mucho mejor!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(content: Text('Navegar a agregar registro (Inicio)')),
                  //       );
                  //     },
                  //     child: const Text('Ver Estadisticas'),
                  //   ),
                  // ),
                ],
              ),
              // bottomButton: addRecordButton,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTimerDialog(String dialogTitle, {Duration? initialDuration}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TimerDialog(
          title: dialogTitle,
          initialDuration: initialDuration,
          onStop: (Duration finalDuration) async {
            if (_activeTimerType != null && finalDuration.inSeconds > 0) {
              final newLog = ActivityLog(
                activityType: _activeTimerType!,
                durationInSeconds: finalDuration.inSeconds,
                endTime: DateTime.now(),
              );
              await _dbHelper.insertActivityLog(newLog); // ¡Guardar en la base de datos!
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Actividad guardada: ${_activeTimerType!}, ${finalDuration.inSeconds} segundos')),
              );
            }
            _resetTimerState();
          },
        );
      },
    );
  }
}