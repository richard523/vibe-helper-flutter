import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/session.dart';
import '../utils/formatters.dart';

class ProjectBreakdownCard extends StatelessWidget {
  final List<Session> sessions;
  final String title;
  final String unit;
  final Color color;

  const ProjectBreakdownCard({
    super.key,
    required this.sessions,
    required this.title,
    required this.unit,
    required this.color,
  });

  List<MapEntry<String, double>> get _breakdown {
    final map = <String, double>{};
    for (final s in sessions) {
      final value = unit == 'cost'
          ? s.stats.sessionCost
          : unit == 'tokens'
              ? s.stats.sessionTotalLlmTokens.toDouble()
              : 1.0; // sessions
      map.update(s.projectName, (v) => v + value, ifAbsent: () => value);
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  @override
  Widget build(BuildContext context) {
    final data = _breakdown;
    if (data.isEmpty) {
      return Card(
        child: SizedBox(
          height: 180,
          child: Center(child: Text('No data', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final maxVal = data.first.value;
    // Show top 8 projects
    final display = data.take(8).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: display.length,
                itemBuilder: (context, index) {
                  final entry = display[index];
                  final pct = (entry.value / maxVal).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(entry.key,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 14,
                              backgroundColor: color.withOpacity(0.1),
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            unit == 'cost'
                                ? '\$${formatDoubleWithCommas(entry.value, 2)}'
                                : unit == 'tokens'
                                    ? _formatTokens(entry.value.toInt())
                                    : entry.value.toInt().toString(),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (data.length > 8)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+ ${data.length - 8} more projects',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) return '${formatDoubleWithCommas(tokens / 1000000, 1)}M';
    if (tokens >= 1000) return '${formatDoubleWithCommas(tokens / 1000, 1)}K';
    return formatNumberWithCommas(tokens);
  }
}
