
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/asset.dart';

class AssetPriceChart extends StatelessWidget {
  const AssetPriceChart({
    super.key,
    required this.priceHistory,
  });

  final List<AssetPricePoint> priceHistory;

  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final sortedHistory = [...priceHistory]
      ..sort((a, b) {
        final aDate = a.recordedAt;
        final bDate = b.recordedAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return -1;
        if (bDate == null) return 1;

        return aDate.compareTo(bDate);
      });

    if (sortedHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 38,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'No price history available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Price updates will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final prices = sortedHistory.map((item) => item.price).toList();

    final latestPrice = prices.last;
    final firstPrice = prices.first;

    final priceChange = latestPrice - firstPrice;

    final hasIncreased = priceChange >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CHART HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasIncreased
                      ? const Color(0xFFEAF7F0)
                      : const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${hasIncreased ? '+' : ''}${_formatPrice(priceChange)}',
                  style: TextStyle(
                    color: hasIncreased
                        ? const Color(0xFF16834A)
                        : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Latest recorded price',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _formatPrice(latestPrice),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          // CHART
          SizedBox(
            height: 170,
            width: double.infinity,
            child: CustomPaint(
              painter: _PriceChartPainter(
                prices: prices,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CHART FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sortedHistory.first.recordedAt == null
                    ? 'Earlier'
                    : _formatDate(
                        sortedHistory.first.recordedAt!,
                      ),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
              Text(
                sortedHistory.last.recordedAt == null
                    ? 'Latest'
                    : _formatDate(
                        sortedHistory.last.recordedAt!,
                      ),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _PriceChartPainter extends CustomPainter {
  const _PriceChartPainter({
    required this.prices,
  });

  final List<double> prices;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    const horizontalPadding = 8.0;
    const verticalPadding = 12.0;

    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - verticalPadding * 2;

    final minimum = prices.reduce(
      (a, b) => a < b ? a : b,
    );

    final maximum = prices.reduce(
      (a, b) => a > b ? a : b,
    );

    final range = maximum - minimum;

    final effectiveRange = range == 0 ? 1.0 : range;

    // GRID LINES
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = verticalPadding +
          (chartHeight / 3) * i;

      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    // CHART POINTS
    final points = <Offset>[];

    for (int i = 0; i < prices.length; i++) {
      final x = prices.length == 1
          ? size.width / 2
          : horizontalPadding +
              (chartWidth / (prices.length - 1)) * i;

      final normalized =
          (prices[i] - minimum) / effectiveRange;

      final y = verticalPadding +
          chartHeight * (1 - normalized);

      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      final dotPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        points.first,
        5,
        dotPaint,
      );

      return;
    }

    // LINE PATH
    final linePath = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    // AREA FILL
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33D62839),
          Color(0x00D62839),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawPath(fillPath, fillPaint);

    // PRICE LINE
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // LATEST PRICE POINT
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      points.last,
      5,
      dotPaint,
    );

    final outerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      points.last,
      7,
      outerDotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter oldDelegate) {
    if (oldDelegate.prices.length != prices.length) {
      return true;
    }

    for (int i = 0; i < prices.length; i++) {
      if (oldDelegate.prices[i] != prices[i]) {
        return true;
      }
    }

    return false;
  }
}