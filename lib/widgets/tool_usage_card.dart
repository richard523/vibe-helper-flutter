import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ToolUsageCard extends StatelessWidget {
  final int agreed;
  final int rejected;
  final int failed;

  const ToolUsageCard({
    super.key,
    required this.agreed,
    required this.rejected,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    final total = agreed + rejected + failed;
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tool Usage',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No tool calls yet',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tool Usage',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: agreed.toDouble(),
                      color: Colors.green,
                      title: '${(agreed / total * 100).toStringAsFixed(0)}%',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      value: rejected.toDouble(),
                      color: Colors.orange,
                      title: '${(rejected / total * 100).toStringAsFixed(0)}%',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      value: failed.toDouble(),
                      color: Colors.red,
                      title: '${(failed / total * 100).toStringAsFixed(0)}%',
                      radius: 15,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Agreed', Colors.green, agreed),
                const SizedBox(width: 16),
                _buildLegend('Rejected', Colors.orange, rejected),
                const SizedBox(width: 16),
                _buildLegend('Failed', Colors.red, failed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $count', style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
