import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:spiritual_meter/screens/statistics/statistics_viewmodel.dart';
import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/screens/statistics/widgets/day_activity_bottom_sheet.dart';
import 'package:spiritual_meter/screens/statistics/widgets/register.dart';
import 'package:spiritual_meter/screens/statistics/widgets/weekly_chart_fl.dart';
import 'package:spiritual_meter/screens/statistics/widgets/monthly_calendar_view.dart';
import 'package:spiritual_meter/screens/widgets/app_section_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late StatisticsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<StatisticsViewModel>();

    Future.microtask(() async {
      await viewModel.loadDailyStatistics();
      await viewModel.loadTimesLast7Days();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsViewModel>(
      builder: (context, model, child) {
        final List<String> last7DaysLabels = model.getLast7DaysLabels();

        return Scaffold(
          appBar: AppBar(title: const Text('Estadísticas')),
          body: SingleChildScrollView(
            child: Column(
              children: [
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

                AppSectionCard(
                  title: kStatisticsTitle,
                  content: SizedBox(
                    height: 200,
                    child: PrayerReadingLineChart(
                      prayerTimes: model.prayerTimesLast7Days,
                      readingTimes: model.readingTimesLast7Days,
                      last7DaysLabels: last7DaysLabels,
                    ),
                  ),
                ),

                AppSectionCard(
                  title: 'Registro del mes',
                  content: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left),
                            onPressed: model.previousMonth,
                          ),
                          Text(
                            DateFormat(
                              'MMMM - yyyy',
                              'es',
                            ).format(model.focusedMonth),
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: model.nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MonthlyCalendarView(
                        focusedMonth: model.focusedMonth,
                        onDaySelected: (selectedDay) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.3,
                                minChildSize: 0.2,
                                maxChildSize: 0.5,
                                expand: false,
                                builder: (
                                  BuildContext context,
                                  ScrollController scrollController,
                                ) {
                                  return DayActivityBottomSheet(
                                    selectedDay: selectedDay,
                                    dbHelper: model.dbHelper,
                                    scrollController: scrollController,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
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
