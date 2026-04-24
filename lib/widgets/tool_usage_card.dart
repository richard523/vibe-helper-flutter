import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ToolUsageCard extends StatelessWidget {
  final int agreed;
  final int rejected;
  final int failed;
  final int succeeded;

  const ToolUsageCard({
    super.key,
    required this.agreed,
    required this.rejected,
    required this.failed,
    this.succeeded = 0,
  });

  int get total => agreed + rejected + failed + succeeded;

  @override
  Widget build(BuildContext context) {
    // Only show categories with data
    final chartData = [
      if (succeeded > 0) _ChartItem('Succeeded', succeeded, Colors.green),
      if (rejected > 0) _ChartItem('Rejected', rejected, Colors.orange),
      if (failed > 0) _ChartItem('Failed', failed, Colors.red),
    ];

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
                      'Tool Calls',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (rejected > 0)
                      Text(
                        '$rejected rejected',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    if (failed > 0)
                      Text(
                        '$failed failed',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (chartData.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    // Donut chart
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: chartData.map((item) =>
                            PieChartSectionData(
                              value: item.count.toDouble(),
                              color: item.color,
                              radius: 16,
                            )
                          ).toList(),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: chartData.map((item) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.label} (${item.count})',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final int count;
  final Color color;

  _ChartItem(this.label, this.count, this.color);
}
