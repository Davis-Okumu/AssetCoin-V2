import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class KycSummaryChart extends StatelessWidget {
  const KycSummaryChart({super.key, required this.data});

  final List<KycSummaryPoint> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, item) => sum + item.count);

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
            'KYC Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Current customer verification status',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 18),
          if (data.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No KYC data available.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CustomPaint(
                        painter: _KycDonutPainter(data: data, total: total),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.toString(),
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...data
                .take(6)
                .map(
                  (item) => _LegendRow(
                    status: item.status,
                    count: item.count,
                    color: _statusColor(item.status),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('verified') || normalized.contains('approved')) {
      return const Color(0xFF16A34A);
    }

    if (normalized.contains('rejected')) {
      return const Color(0xFFDC2626);
    }

    if (normalized.contains('review')) {
      return const Color(0xFF7C3AED);
    }

    return const Color(0xFFD97706);
  }
}

class _KycDonutPainter extends CustomPainter {
  _KycDonutPainter({required this.data, required this.total});

  final List<KycSummaryPoint> data;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2 - 12;

    const strokeWidth = 22.0;

    var start = -1.5708;

    for (final item in data) {
      final sweep = (item.count / total) * 3.141592653589793 * 2;

      final paint = Paint()
        ..color = _color(item.status)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );

      start += sweep;
    }
  }

  static Color _color(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('verified') || normalized.contains('approved')) {
      return const Color(0xFF16A34A);
    }

    if (normalized.contains('rejected')) {
      return const Color(0xFFDC2626);
    }

    if (normalized.contains('review')) {
      return const Color(0xFF7C3AED);
    }

    return const Color(0xFFD97706);
  }

  @override
  bool shouldRepaint(covariant _KycDonutPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.status,
    required this.count,
    required this.color,
  });

  final String status;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.replaceAll('_', ' '),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
