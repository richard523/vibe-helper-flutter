import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/session.dart';

class CostCard extends StatelessWidget {
  final List<Session> sessions;

  const CostCard({super.key, required this.sessions});

  double get totalCost => sessions.fold(0.0, (sum, s) => sum + s.stats.sessionCost);
  int get sessionCount => sessions.length;
  double get avgCostPerSession => sessionCount > 0 ? totalCost / sessionCount : 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Spend',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sessionCount sessions',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'avg \$${avgCostPerSession.toStringAsFixed(2)}/session',
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
            // Cumulative cost chart
            Expanded(
              child: _buildCumulativeChart(),
            ),
          ],
        ),
      ),
    );
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
      final cumulative = sorted.sublist(0, e.key + 1).fold(0.0, (sum, s) => sum + s.stats.sessionCost);
      return FlSpot(e.key.toDouble(), cumulative);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6B46C1),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B46C1).withOpacity(0.3),
                  Color(0xFF6B46C1).withOpacity(0.05),
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
          horizontalInterval: spots.isNotEmpty && spots.last.y > 1 
              ? (spots.last.y / 4).ceilToDouble() 
              : 1,
          getDrawingVerticalLine: (value) => FlLine(
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
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minX: 0,
        maxX: spots.isNotEmpty ? spots.last.x : 1,
        minY: 0,
        maxY: spots.isNotEmpty ? spots.last.y + (spots.last.y * 0.1) : 1,
      ),
    );
  }
}
