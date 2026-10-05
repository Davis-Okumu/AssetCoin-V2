import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class RegistrationChart extends StatelessWidget {
  const RegistrationChart({super.key, required this.data});
  final List<RegistrationPoint> data;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Registrations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Customer registration activity over time',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 15),
          if (data.isEmpty)
            const SizedBox(
              height: 230,
              child: Center(
                child: Text(
                  'No registration data available.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            SizedBox(
              height: 230,
              child: CustomPaint(
                painter: _RegistrationPainter(data),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RegistrationPainter extends CustomPainter {
  _RegistrationPainter(this.data);
  final List<RegistrationPoint> data;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const right = 10.0;
    const top = 10.0;
    const bottom = 30.0;
    final width = math.max(1.0, size.width - left - right).toDouble();
    final height = math.max(1.0, size.height - top - bottom).toDouble();
    final maxCount = data.fold<double>(
      0,
      (maximum, item) => math.max(maximum, item.count.toDouble()),
    );
    final ceiling = maxCount <= 0 ? 1.0 : maxCount;
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 4; i++) {
      final y = top + height * (i / 4);
      canvas.drawLine(Offset(left, y), Offset(left + width, y), gridPaint);
      textPainter.text = TextSpan(
        text: (ceiling * (4 - i) / 4).round().toString(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
    final gap = data.length <= 1
        ? 0.0
        : math.min(8.0, width / data.length * .18);
    final barWidth = math.max(4.0, (width / data.length) - gap);
    for (var i = 0; i < data.length; i++) {
      final x = left + (width / data.length) * i + gap / 2;
      final barHeight = (data[i].count / ceiling) * height;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top + height - barHeight, barWidth, barHeight),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, barPaint);
      if (i == 0 || i == data.length - 1 || i == data.length ~/ 2) {
        textPainter.text = TextSpan(
          text: data[i].label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x + barWidth / 2 - textPainter.width / 2, top + height + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RegistrationPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
