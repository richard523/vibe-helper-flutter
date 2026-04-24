import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../viewmodels/app_state.dart';
import '../widgets/tool_usage_card.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total Stats
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOverviewStat(
                          'Total Cost',
                          '\$${formatDoubleWithCommas(appState.totalCost, 2)}',
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildOverviewStat(
                          'Total Tokens',
                          formatNumberWithCommas(appState.totalTokens),
                          Icons.text_fields,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildOverviewStat(
                          'Sessions',
                          formatNumberWithCommas(appState.totalSessions),
                          Icons.history,
                          Colors.purple,
                        ),
                      ),
                      Expanded(
                        child: _buildOverviewStat(
                          'Tool Calls',
                          formatNumberWithCommas(appState.totalToolCalls),
                          Icons.build,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Cost by Project Chart
              const Text(
                'Cost by Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildCostByProjectChart(appState.costByProject),

              const SizedBox(height: 24),

              // Tool Usage
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: ToolUsageCard(
                  agreed: appState.toolCallBreakdown['agreed'] ?? 0,
                  rejected: appState.toolCallBreakdown['rejected'] ?? 0,
                  failed: appState.toolCallBreakdown['failed'] ?? 0,
                ),
              ),

              const SizedBox(height: 24),

              // Activity Heatmap placeholder
              const Text(
                'Activity Heatmap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Activity heatmap coming soon',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCostByProjectChart(List<MapEntry<String, double>> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Card(
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.first.value + (data.first.value * 0.1),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '\$${formatDoubleWithCommas(value, 2)}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) => Text(
                data[value.toInt()].key,
                style: const TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.value,
                    width: 12,
                    color: Colors.purple,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
            )
            .toList(),
      ),
      ),
    );
  }
}
