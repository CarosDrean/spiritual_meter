import 'package:flutter/material.dart';

import 'package:spiritual_meter/core/constant.dart';

class MonthlyCalendarView extends StatelessWidget {
  final DateTime focusedMonth;
  final ValueChanged<DateTime>? onDaySelected;
  final Map<DateTime, Set<String>> activitiesByDay;

  const MonthlyCalendarView({
    super.key,
    required this.focusedMonth,
    required this.activitiesByDay,
    this.onDaySelected,
  });

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
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    final startWeekday = firstDayOfMonth.weekday % 7;

    final List<DateTime?> days = List.generate(startWeekday, (index) => null);
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(focusedMonth.year, focusedMonth.month, i));
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
            final hasActivity = activitiesByDay.containsKey(normalizedDay);
            final Set<String> activityTypes =
                activitiesByDay[normalizedDay] ?? {};

            return GestureDetector(
              onTap: () {
                if (onDaySelected != null) {
                  onDaySelected!(day);
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
