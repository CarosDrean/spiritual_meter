import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constant.dart';

class WeeklyChartPlaceholder extends StatelessWidget {
  const WeeklyChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ChartGridPainter(),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ChartLinePainter(
                line1Color: kChartLineColor1,
                line2Color: kChartLineColor2,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 16, height: 8, color: kChartLineColor1),
                      const SizedBox(width: 4),
                      Text('Oración', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 16, height: 8, color: kChartLineColor2),
                      const SizedBox(width: 4),
                      Text('Lectura', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CustomPainters (no necesitan cambios significativos) ---
class _ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = kChartGridColor.withAlpha((255 * 0.5).round())
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);

    for (int i = 1; i <= 5; i++) {
      final double y = size.height - (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (int i = 1; i <= 6; i++) {
      final double x = (size.width / 7) * i + (size.width / 14);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final TextPainter textPainterY = TextPainter(textDirection: TextDirection.ltr);
    const TextStyle textStyleY = TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 10);
    for (int i = 0; i <= 100; i += 20) {
      textPainterY.text = TextSpan(text: '$i', style: textStyleY);
      textPainterY.layout();
      final y = size.height - (i / 100) * size.height;
      textPainterY.paint(canvas, Offset(-textPainterY.width - 4, y - textPainterY.height / 2));
    }

    final List<String> days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final TextPainter textPainterX = TextPainter(textDirection: TextDirection.ltr);
    const TextStyle textStyleX = TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 10);
    for (int i = 0; i < days.length; i++) {
      textPainterX.text = TextSpan(text: days[i], style: textStyleX);
      textPainterX.layout();
      final x = (size.width / 7) * i + (size.width / 14);
      textPainterX.paint(canvas, Offset(x - textPainterX.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartLinePainter extends CustomPainter {
  final Color line1Color;
  final Color line2Color;

  _ChartLinePainter({required this.line1Color, required this.line2Color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..color = line1Color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint paint2 = Paint()
      ..color = line2Color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final List<double> data1 = [20, 45, 30, 60, 50, 70, 40];
    final List<double> data2 = [10, 30, 25, 40, 35, 50, 30];

    final Path path1 = Path();
    final Path path2 = Path();

    final double xStep = size.width / (data1.length - 1);
    double initialX = 0;

    path1.moveTo(initialX, size.height - (data1[0] / 100) * size.height);
    for (int i = 1; i < data1.length; i++) {
      final x = initialX + xStep * i;
      final y = size.height - (data1[i] / 100) * size.height;
      path1.lineTo(x, y);
    }
    canvas.drawPath(path1, paint1);

    path2.moveTo(initialX, size.height - (data2[0] / 100) * size.height);
    for (int i = 1; i < data2.length; i++) {
      final x = initialX + xStep * i;
      final y = size.height - (data2[i] / 100) * size.height;
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}