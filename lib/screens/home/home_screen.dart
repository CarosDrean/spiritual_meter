import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spiritual_meter/models/activity_log.dart';
import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/screens/home/widgets/prayer_gauge.dart';
import 'package:spiritual_meter/screens/home/widgets/timer_dialog.dart';
import 'package:spiritual_meter/screens/widgets/app_section_card.dart';
import 'package:spiritual_meter/screens/widgets/register.dart';
import 'package:spiritual_meter/screens/widgets/scroll_section.dart';

import 'home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel = context.read<HomeViewModel>();

    Future.microtask(() async {
      await viewModel.loadTimerState();
      showDialogOnInit();

      viewModel.loadRecordsToday();
    });
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
      viewModel.saveTimerState();
      if (viewModel.isPrayerOn || viewModel.isBibleReadingOn) {
        viewModel.showReminderNotification();
      }
    } else if (state == AppLifecycleState.resumed) {
      viewModel.loadTimerState();
      viewModel.cancelReminderNotification();
      viewModel.loadRecordsToday();
    }
  }

  void showDialogOnInit() {
    if (viewModel.timerStartTime != null && viewModel.activeTimerType != null) {
      if (!viewModel.isDialogShowing) {
        viewModel.setDialogShowing(true);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTimerDialog(
            viewModel.activeTimerType == kActivityTypePrayer
                ? 'Tiempo de Oración'
                : 'Tiempo de Lectura Bíblica',
          );
        });
      }
    } else {
      viewModel.stopTimer();
    }
  }

  void _showTimerDialog(String dialogTitle) {
    if (viewModel.timerStartTime == null) return;

    viewModel.setDialogShowing(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return TimerDialog(
          title: dialogTitle,
          startTime: viewModel.timerStartTime!,
          onStop: (finalDuration) async {
            if (viewModel.activeTimerType != null &&
                finalDuration.inSeconds > 0) {
              final newLog = ActivityLog(
                activityType: viewModel.activeTimerType!,
                durationInSeconds: finalDuration.inSeconds,
                endTime: DateTime.now(),
              );
              await viewModel.saveLog(newLog);
            }

            await viewModel.loadRecordsToday();

            viewModel.stopTimer();
            await viewModel.clearTimerState();
          },
        );
      },
    ).then((_) {
      viewModel.setDialogShowing(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(title: const Text(kAppName)),
          body: ScrollSection(
            child: Column(
              children: [
                AppSectionCard(
                  title: 'Como voy',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrayerGauge(
                        prayerTimeInSeconds:
                        model.todayPrayerDuration.inSeconds,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          model.getPrayerMessage(
                            model.todayPrayerDuration.inMinutes.toDouble(),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                            value: model.isPrayerOn,
                            onChanged: (bool value) async {
                              if (value) {
                                model.startPrayerTimer();
                                _showTimerDialog('Tiempo de Oración');
                              } else {
                                model.loadRecordsToday();
                                model.stopTimer();
                                await model.clearTimerState();
                              }
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
                            value: model.isBibleReadingOn,
                            onChanged: (bool value) async {
                              if (value) {
                                model.startBibleReadingTimer();
                                _showTimerDialog('Tiempo de Lectura Bíblica');
                              } else {
                                model.loadRecordsToday();
                                model.stopTimer();
                                await model.clearTimerState();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // bottomButton: addRecordButton,
                ),

                AppSectionCard(
                  title: 'Registro dia',
                  content: Column(
                    children: [
                      Register(
                        text: 'Tiempo orado:',
                        duration: model.todayPrayerDuration,
                      ),
                      const SizedBox(height: 8),
                      Register(
                        text: 'Tiempo lectura bíblica:',
                        duration: model.todayBibleReadingDuration,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
