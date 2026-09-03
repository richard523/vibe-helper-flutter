import 'package:flutter/material.dart';

import '../models/session.dart';
import '../utils/formatters.dart';

class EnhancedHeatmap extends StatelessWidget {
  final List<Session> sessions;
  final Function(Session)? onSessionSelected;

  const EnhancedHeatmap({
    super.key,
    required this.sessions,
    this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text('No activity', style: TextStyle(color: Colors.grey)),
      );
    }

    // Sort newest first
    final sorted = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));

    // Aggregate per day: count, total cost, most expensive session, total tokens
    final dayData = <DateTime, _DayAgg>{};
    for (final s in sorted) {
      final key = DateTime.utc(s.startTime.year, s.startTime.month, s.startTime.day);
      final agg = dayData[key] ?? _DayAgg(date: key);
      agg.count++;
      agg.totalCost += s.stats.sessionCost;
      agg.totalTokens += s.stats.sessionTotalLlmTokens;
      if (s.stats.sessionCost > agg.maxCost) {
        agg.maxCost = s.stats.sessionCost;
        agg.mostExpensive = s;
      }
      dayData[key] = agg;
    }

    // Date range
    final dates = dayData.keys.toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? b : b);
    final globalMaxCost = dayData.values.map((e) => e.totalCost).reduce((a, b) => a > b ? a : b);

    // Build cells (minDate..maxDate inclusive)
    final cells = <_DayAgg?>[];
    var current = DateTime.utc(minDate.year, minDate.month, minDate.day);
    final end = DateTime.utc(maxDate.year, maxDate.month, maxDate.day);
    while (current.isBefore(end) || current == end) {
      cells.add(dayData[current]);
      current = current.add(const Duration(days: 1));
    }

    // Pad to Sunday alignment
    final padStart = (minDate.weekday % 7);
    cells.insertAll(0, List.filled(padStart, null));

    // Split into weeks
    final weeks = <List<_DayAgg?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, (i + 7 > cells.length) ? cells.length : i + 7);
      while (week.length < 7) week.add(null);
      weeks.add(week);
    }

    // Month labels
    final monthLabels = _buildMonthLabels(weeks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels row
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: SizedBox(
            height: 16,
            child: Row(
              spacing: 3,
              children: monthLabels,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Day labels + grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels
            SizedBox(
              width: 26,
              child: Column(
                spacing: 3,
                children: [
                  const SizedBox(height: 14, child: Text('Mon', style: TextStyle(fontSize: 8, color: Colors.grey))),
                  const SizedBox(height: 14, child: Text('')),
                  const SizedBox(height: 14, child: Text('Wed', style: TextStyle(fontSize: 8, color: Colors.grey))),
                  const SizedBox(height: 14, child: Text('')),
                  const SizedBox(height: 14, child: Text('Fri', style: TextStyle(fontSize: 8, color: Colors.grey))),
                  const SizedBox(height: 14, child: Text('')),
                  const SizedBox(height: 14, child: Text('')),
                ],
              ),
            ),
            // Scrollable grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 3,
                  children: weeks.map((week) => _buildWeekColumn(week, globalMaxCost)).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          spacing: 4,
          children: [
            const Text('Less', style: TextStyle(fontSize: 9, color: Colors.grey)),
            ..._legendColors.map((c) => Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
            )),
            const Text('More', style: TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(width: 16),
            const Text('Color = daily spend', style: TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMonthLabels(List<List<_DayAgg?>> weeks) {
    final labels = <Widget>[];
    String? lastMonth;
    for (final week in weeks) {
      final firstDay = week.firstWhere((c) => c != null, orElse: () => null);
      if (firstDay != null) {
        final monthName = _monthName(firstDay.date.month);
        if (monthName != lastMonth) {
          labels.add(SizedBox(
            width: 17, // cell width + spacing
            child: Text(monthName, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ));
          lastMonth = monthName;
        } else {
          labels.add(const SizedBox(width: 17));
        }
      } else {
        labels.add(const SizedBox(width: 17));
      }
    }
    return labels;
  }

  Widget _buildWeekColumn(List<_DayAgg?> week, double globalMaxCost) {
    return Column(
      spacing: 3,
      mainAxisSize: MainAxisSize.min,
      children: week.map((cell) {
        if (cell == null) {
          return const SizedBox(width: 14, height: 14);
        }
        final now = DateTime.now().toUtc();
        if (cell.date.isAfter(now)) {
          return const SizedBox(width: 14, height: 14);
        }

        final color = _colorForCost(cell.totalCost, globalMaxCost);
        final dateStr = '${cell.date.year}-${cell.date.month.toString().padLeft(2, '0')}-${cell.date.day.toString().padLeft(2, '0')}';
        final tooltip = '$dateStr\n'
            '${cell.count} session${cell.count > 1 ? 's' : ''}\n'
            'Spend: \$${formatDoubleWithCommas(cell.totalCost, 2)}\n'
            'Tokens: ${formatNumberWithCommas(cell.totalTokens)}'
            '${cell.mostExpensive != null ? '\nTop session: \$${cell.mostExpensive!.stats.sessionCost.toStringAsFixed(2)} — ${cell.mostExpensive!.projectName}' : ''}';

        if (cell.mostExpensive != null && onSessionSelected != null) {
          final session = cell.mostExpensive!;
          final callback = onSessionSelected!;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: tooltip,
              waitDuration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: () => callback(session),
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }
        return Tooltip(
          message: tooltip,
          waitDuration: const Duration(milliseconds: 150),
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _colorForCost(double cost, double maxCost) {
    if (cost <= 0) return const Color(0xFF6B46C1).withOpacity(0.06);
    final ratio = (cost / maxCost).clamp(0.0, 1.0);
    if (ratio < 0.15) return const Color(0xFF6B46C1).withOpacity(0.2);
    if (ratio < 0.35) return const Color(0xFF6B46C1).withOpacity(0.4);
    if (ratio < 0.6) return const Color(0xFF6B46C1).withOpacity(0.6);
    if (ratio < 0.85) return const Color(0xFF6B46C1).withOpacity(0.8);
    return const Color(0xFF6B46C1);
  }

  static const _legendColors = [
    Color(0x106B46C1), Color(0x336B46C1), Color(0x996B46C1), Color(0xCC6B46C1), Color(0xFF6B46C1),
  ];

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

class _DayAgg {
  final DateTime date;
  int count = 0;
  double totalCost = 0;
  int totalTokens = 0;
  double maxCost = -1;
  Session? mostExpensive;

  _DayAgg({required this.date});
}
