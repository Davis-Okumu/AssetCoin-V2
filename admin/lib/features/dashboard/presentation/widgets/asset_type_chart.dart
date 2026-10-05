import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/dashboard.dart';

class AssetTypeChart extends StatelessWidget {
  const AssetTypeChart({super.key, required this.data});

  final List<AssetTypeSummary> data;

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
            'Assets by Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Distribution of registered real-world assets',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          if (data.isEmpty)
            const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'No asset type data available.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            _Bars(data: data),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.data});

  final List<AssetTypeSummary> data;

  @override
  Widget build(BuildContext context) {
    final maxCount = data.fold<int>(
      0,
      (maximum, item) => math.max(maximum, item.count),
    );

    final ceiling = maxCount == 0 ? 1 : maxCount;

    return Column(
      children: data.take(8).map((item) {
        final ratio = item.count / ceiling;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _title(item.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  Text(
                    item.count.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: ratio.clamp(0, 1).toDouble(),
                  backgroundColor: const Color(0xFFEFF6FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static String _title(String value) {
    if (value.isEmpty) {
      return 'Unknown';
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}'
                    '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
