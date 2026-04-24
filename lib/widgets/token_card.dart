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
            // Token type filter tabs
            // (For now, just show the chart with both)
            // TODO: Add filter tabs for Both/Input/Output
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: _buildTokenBarChart(),
              ),
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

  Widget _buildTokenBarChart() {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Sort by date
    final sorted = [...sessions]..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Create data points for each session (input and output as separate bars would need grouped chart)
    // For simplicity, showing total tokens per session
    final spots = sorted.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: sorted[e.key].stats.sessionPromptTokens.toDouble(),
            width: 8,
            color: Color(0xFF06B6D4).withOpacity(0.7),
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: sorted[e.key].stats.sessionCompletionTokens.toDouble(),
            width: 8,
            color: Color(0xFF6B46C1).withOpacity(0.7),
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 2,
      );
    }).toList();

    final maxY = sorted.map((s) => (s.stats.sessionPromptTokens + s.stats.sessionCompletionTokens).toDouble()).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barGroups: spots,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                _formatTokens(value.toInt()),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
          getDrawingVerticalLine: (value) => const FlLine(
            color: Colors.grey,
            strokeWidth: 0.5,
            dashArray: [4],
          ),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 0.5,
            dashArray: [4],
          ),
        ),
        minY: 0,
        maxY: maxY * 1.1,
      ),
    );
  }
}
