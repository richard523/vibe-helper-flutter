import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/session.dart';
import '../utils/formatters.dart';

class TokenCard extends StatelessWidget {
  final List<Session> sessions;

  const TokenCard({super.key, required this.sessions});

  int get totalTokens => sessions.fold(0, (sum, s) => sum + s.stats.sessionTotalLlmTokens);
  int get totalInput => sessions.fold(0, (sum, s) => sum + s.stats.sessionPromptTokens);
  int get totalOutput => sessions.fold(0, (sum, s) => sum + s.stats.sessionCompletionTokens);
  double get avgTokensPerSecond {
    final speeds = sessions.map((s) => s.stats.tokensPerSecond);
    if (speeds.isEmpty) return 0;
    return speeds.reduce((a, b) => a + b) / speeds.length;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tokens',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTokens(totalTokens),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatDoubleWithCommas(avgTokensPerSecond, 0)} tok/s avg',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${_formatTokens(totalInput)} in / ${_formatTokens(totalOutput)} out',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _buildCumulativeChart(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) {
      return '${formatDoubleWithCommas(tokens / 1000000, 1)}M';
    } else if (tokens >= 1000) {
      return '${formatDoubleWithCommas(tokens / 1000, 1)}K';
    } else {
      return formatNumberWithCommas(tokens);
    }
  }

  Widget _buildCumulativeChart() {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Sort by startTime ascending for cumulative chart
    final sorted = [...sessions]..sort((a, b) => a.startTime.compareTo(b.startTime));

    final spots = sorted.asMap().entries.map((e) {
      final cumulative = sorted.sublist(0, e.key + 1).fold(0, (sum, s) => sum + s.stats.sessionTotalLlmTokens);
      return FlSpot(e.key.toDouble(), cumulative.toDouble());
    }).toList();

    final maxY = spots.last.y;

    // Show ~4 labels
    final labelInterval = sorted.length > 4 ? (sorted.length / 4).ceil() : 1;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF06B6D4),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF06B6D4).withOpacity(0.3),
                  Color(0xFF06B6D4).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY > 1 ? (maxY / 4).ceilToDouble() : 1,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 0.5,
            dashArray: [4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY > 1 ? (maxY / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) return const SizedBox();
                return Text(
                  _formatTokens(value.toInt()),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: labelInterval.toDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sorted.length) return const SizedBox();
                final s = sorted[idx];
                final m = s.startTime.month.toString().padLeft(2, '0');
                final d = s.startTime.day.toString().padLeft(2, '0');
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$m/$d',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minX: 0,
        maxX: spots.isNotEmpty ? spots.last.x : 1,
        minY: 0,
        maxY: maxY + (maxY * 0.1),
      ),
    );
  }
}
