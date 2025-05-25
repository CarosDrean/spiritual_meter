import 'package:flutter/material.dart';

import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/services/database_helper.dart';

class MonthlyCalendarView extends StatefulWidget {
  final DateTime focusedMonth;
  final ValueChanged<DateTime>? onDaySelected;

  const MonthlyCalendarView({
    super.key,
    required this.focusedMonth,
    this.onDaySelected,
  });

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<DateTime, Set<String>> _activitiesByDay = {};

  @override
  void initState() {
    super.initState();
    _loadActiveDaysForMonth(widget.focusedMonth);
  }

  @override
  void didUpdateWidget(covariant MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth != widget.focusedMonth) {
      _loadActiveDaysForMonth(widget.focusedMonth);
    }
  }

  Future<void> _loadActiveDaysForMonth(DateTime month) async {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));

    final logs = await _dbHelper.getActivityLogsByDateRange(
      firstDayOfMonth,
      lastDayOfMonth,
    );

    final Map<DateTime, Set<String>> newActivitiesByDay = {};

    for (var log in logs) {
      final logDate = DateTime(
        log.endTime.year,
        log.endTime.month,
        log.endTime.day,
      );

      newActivitiesByDay.putIfAbsent(logDate, () => {});
      newActivitiesByDay[logDate]!.add(log.activityType);
    }

    setState(() {
      _activitiesByDay = newActivitiesByDay;
    });
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case kActivityTypePrayer:
        return Colors.blue.shade700;
      case kActivityTypeBibleReading:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(
      widget.focusedMonth.year,
      widget.focusedMonth.month,
      1,
    );
    final daysInMonth =
        DateTime(
          widget.focusedMonth.year,
          widget.focusedMonth.month + 1,
          0,
        ).day;

    final startWeekday = firstDayOfMonth.weekday % 7;

    final List<DateTime?> days = List.generate(startWeekday, (index) => null);
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(
        DateTime(widget.focusedMonth.year, widget.focusedMonth.month, i),
      );
    }

    const List<String> weekdays = [
      'dom',
      'lun',
      'mar',
      'mié',
      'jue',
      'vie',
      'sáb',
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              weekdays
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return Container();
            }

            final isToday =
                day.year == DateTime.now().year &&
                day.month == DateTime.now().month &&
                day.day == DateTime.now().day;

            final normalizedDay = DateTime(day.year, day.month, day.day);
            final hasActivity = _activitiesByDay.containsKey(normalizedDay);
            final Set<String> activityTypes =
                _activitiesByDay[normalizedDay] ?? {};

            return GestureDetector(
              onTap: () {
                if (widget.onDaySelected != null) {
                  widget.onDaySelected!(day);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(77)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border:
                      isToday
                          ? Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                          )
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color:
                            isToday
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (hasActivity)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...activityTypes.map((activityType) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getActivityColor(activityType),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
