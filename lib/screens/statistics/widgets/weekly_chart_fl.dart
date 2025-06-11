import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PrayerReadingLineChart extends StatelessWidget {
  final List<double> prayerTimes;
  final List<double> readingTimes;
  final List<String> last7DaysLabels;

  const PrayerReadingLineChart({
    super.key,
    required this.prayerTimes,
    required this.readingTimes,
    required this.last7DaysLabels,
  });

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  String formatMinutesToMinSec(double minutes) {
    int min = minutes.floor();
    int sec = ((minutes - min) * 60).round();
    return '${min}m ${sec}s';
  }

  double _calculateMaxY() {
    final maxPrayer = prayerTimes.isNotEmpty ? prayerTimes.reduce((a, b) => a > b ? a : b) : 0;
    final maxReading = readingTimes.isNotEmpty ? readingTimes.reduce((a, b) => a > b ? a : b) : 0;
    final max = [maxPrayer, maxReading, 50].reduce((a, b) => a > b ? a : b);
    return (max * 1.1).ceilToDouble(); // margin of 10%
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.blue, 'Oración'),
            const SizedBox(width: 12),
            _legendItem(Colors.green, 'Lectura'),
            const SizedBox(width: 12),
            _legendItem(Colors.red, 'Mínimo'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              maxY: _calculateMaxY(),
              minY: 0,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      if (index >= 0 && index < last7DaysLabels.length) {
                        return Text(
                          last7DaysLabels[index],
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                    interval: 1,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      String formattedTime = formatMinutesToMinSec(spot.y);
                      return LineTooltipItem(
                        formattedTime,
                        TextStyle(
                          color: spot.bar.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    prayerTimes.length,
                    (i) => FlSpot(i.toDouble(), prayerTimes[i]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: List.generate(
                    readingTimes.length,
                    (i) => FlSpot(i.toDouble(), readingTimes[i]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.green,
                  dotData: FlDotData(show: true),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 50,
                    color: Colors.red,
                    strokeWidth: 2,
                    dashArray: [5, 10],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Mínimo aceptable',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
