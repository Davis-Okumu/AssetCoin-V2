import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class AssetActivityChart extends StatelessWidget {
  const AssetActivityChart({super.key, required this.data});
  final List<AssetActivityPoint> data;
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
            'Asset Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Asset submissions over time',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 14),
          data.isEmpty
              ? const SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      'No activity data available.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                )
              : SizedBox(
                  height: 260,
                  child: CustomPaint(
                    painter: _AssetChartPainter(data),
                    child: const SizedBox.expand(),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AssetChartPainter extends CustomPainter {
  _AssetChartPainter(this.data);
  final List<AssetActivityPoint> data;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 16.0;
    const top = 18.0;
    const bottom = 34.0;
    final chartWidth = math.max(1.0, size.width - left - right).toDouble();
    final chartHeight = math.max(1.0, size.height - top - bottom).toDouble();
    final maxValue = data.fold<double>(
      0,
      (maximum, item) => math.max(maximum, item.count.toDouble()),
    );
    final ceiling = maxValue <= 0 ? 1.0 : maxValue;
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(.08)
      ..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 4; i++) {
      final y = top + chartHeight * (i / 4);
      canvas.drawLine(Offset(left, y), Offset(left + chartWidth, y), gridPaint);
      textPainter.text = TextSpan(
        text: (ceiling * (4 - i) / 4).round().toString(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
    if (data.length == 1) {
      final x = left + chartWidth / 2;
      final y = top + chartHeight - (data.first.count / ceiling) * chartHeight;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = const Color(0xFF2563EB),
      );
      return;
    }
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = left + chartWidth * (i / (data.length - 1));
      final y = top + chartHeight - (data[i].count / ceiling) * chartHeight;
      points.add(Offset(x, y));
    }
    final area = Path()..moveTo(points.first.dx, top + chartHeight);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(points.last.dx, top + chartHeight)
      ..close();
    canvas.drawPath(area, fillPaint);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, Paint()..color = Colors.white);
      canvas.drawCircle(points[i], 3, Paint()..color = const Color(0xFF2563EB));
      if (i == 0 || i == points.length - 1 || i == points.length ~/ 2) {
        textPainter.text = TextSpan(
          text: data[i].label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2, top + chartHeight + 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AssetChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
