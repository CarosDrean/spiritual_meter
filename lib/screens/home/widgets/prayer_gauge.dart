import 'dart:math' as math;

import 'package:flutter/material.dart';

class PrayerGaugePainter extends CustomPainter {
  final double prayerTimeInMinutes;
  final Color needleColor;
  final Color pivotColor;

  PrayerGaugePainter({
    required this.prayerTimeInMinutes,
    required this.needleColor,
    required this.pivotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The center of the semi-circle will be at the bottom center of the drawing area
    final Offset center = Offset(size.width / 2, size.height);
    final double radius = size.width / 2;

    final Color redColor = Colors.red;
    final Color yellowColor = Colors.yellow;
    final Color greenColor = Colors.green;

    final Paint arcPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 35.0;

    final double sectionSweepAngle = math.pi / 3; // 60 degrees

    // Draw the arcs from left to right in the bottom semi-circle
    // Starting from 180 degrees (math.pi) and sweeping counter-clockwise

    // Red: 0 to 29 minutes (Left section)
    arcPaint.color = redColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start angle (180 degrees, horizontal left)
      sectionSweepAngle, // Sweep angle (60 degrees counter-clockwise)
      false,
      arcPaint,
    );

    // Yellow: 30 to 59 minutes (Middle section)
    arcPaint.color = yellowColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + sectionSweepAngle, // Start angle (120 degrees)
      sectionSweepAngle, // Sweep angle (60 degrees counter-clockwise)
      false,
      arcPaint,
    );

    // Green: 60+ minutes (Right section)
    arcPaint.color = greenColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + 2 * sectionSweepAngle, // Start angle (60 degrees)
      sectionSweepAngle, // Sweep angle (60 degrees counter-clockwise)
      false,
      arcPaint,
    );

    // --- Draw the Needle ---
    final double clampedPrayerTime = prayerTimeInMinutes.clamp(0.0, 90.0);

    // Calculate the needle angle.
    // 0 min -> 180 degrees (pi), 90 min -> 0 degrees.
    // The angle decreases from pi to 0 as time increases from 0 to 90.
    final double needleAngle = math.pi - (clampedPrayerTime / 90.0) * math.pi;

    final double needleLength = radius * 0.8;
    final Offset needleEndPoint = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy - needleLength * math.sin(needleAngle),
    );

    final Paint needlePaint =
        Paint()
          ..color = needleColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.0;

    canvas.drawLine(center, needleEndPoint, needlePaint);

    final Paint pivotPaint =
        Paint()
          ..color = pivotColor
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6.0, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant PrayerGaugePainter oldDelegate) {
    return oldDelegate.prayerTimeInMinutes != prayerTimeInMinutes;
  }
}

class PrayerGauge extends StatelessWidget {
  final int prayerTimeInSeconds;

  const PrayerGauge({super.key, required this.prayerTimeInSeconds});

  double get prayerTimeInMinutes => prayerTimeInSeconds / 60.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final needleColor =
        brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    final pivotColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: 180,
        height: 100,
        child: CustomPaint(
          painter: PrayerGaugePainter(
            prayerTimeInMinutes: prayerTimeInMinutes,
            needleColor: needleColor,
            pivotColor: pivotColor,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
