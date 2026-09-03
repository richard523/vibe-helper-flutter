import 'package:flutter/material.dart';

import '../models/session.dart';

class ActivityHeatmap extends StatelessWidget {
  final List<Session> sessions;
  final Function(Session)? onSessionSelected;

  const ActivityHeatmap({
    super.key,
    required this.sessions,
    this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No activity data',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Sort sessions by startTime descending (newest first)
    final sortedSessions = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));

    // Group sessions by date (UTC) for first-session lookup
    final sessionsByDate = <DateTime, Session>{};
    for (final session in sortedSessions) {
      final dateKey = DateTime.utc(session.startTime.year, session.startTime.month, session.startTime.day);
      // Keep the first (newest) session for each date
      if (!sessionsByDate.containsKey(dateKey)) {
        sessionsByDate[dateKey] = session;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Activity Heatmap',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Heatmap - horizontal scroll, weeks as vertical columns
            // Height: 7 cells * 14px + 6 spacings * 3px = 116px
            SizedBox(
              height: 116,
              child: _buildHeatmap(
                sessionsByDate: sessionsByDate,
                now: DateTime.now().toUtc(),
                sessions: sessions,
                onSessionSelected: onSessionSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap({
    required Map<DateTime, Session> sessionsByDate,
    required DateTime now,
    required List<Session> sessions,
    Function(Session)? onSessionSelected,
  }) {
    final utcNow = now.toUtc();

    // Get date range - normalize to UTC midnight for consistent date keys
    final dates = sessions.map((s) => DateTime.utc(s.startTime.year, s.startTime.month, s.startTime.day)).toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Count sessions per day using UTC dates
    final countByDay = <DateTime, int>{};
    for (final session in sessions) {
      final dateKey = DateTime.utc(session.startTime.year, session.startTime.month, session.startTime.day);
      countByDay.update(dateKey, (value) => value + 1, ifAbsent: () => 1);
    }

    // Build cells from minDate to maxDate
    final allCells = <DayCell>[];
    var current = DateTime.utc(minDate.year, minDate.month, minDate.day);
    final end = DateTime.utc(maxDate.year, maxDate.month, maxDate.day);
    
    while (current.isBefore(end) || current == end) {
      allCells.add(DayCell(
        date: current,
        count: countByDay[current] ?? 0,
      ));
      current = current.add(const Duration(days: 1));
    }

    // Pad start to align to Sunday (weekday 7)
    // In Dart: weekday 1=Mon, 2=Tue, ..., 7=Sun
    final startWeekday = minDate.weekday; // 1-7
    final paddingDays = (startWeekday % 7); // Days to prepend to reach Sunday
    final paddedCells = List.filled(paddingDays, const DayCell(date: null, count: -1)) + allCells;

    // Split into weeks of 7 days
    final heatmapWeeks = <List<DayCell>>[];
    for (var i = 0; i < paddedCells.length; i += 7) {
      final weekEnd = (i + 7) < paddedCells.length ? i + 7 : paddedCells.length;
      final week = paddedCells.sublist(i, weekEnd);
      // Pad to 7 days
      while (week.length < 7) {
        week.add(const DayCell(date: null, count: -1));
      }
      heatmapWeeks.add(week);
    }

    // Build week column widgets
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 3,
        children: heatmapWeeks.map((week) => _buildWeekColumn(
          week: week,
          now: utcNow,
          sessionsByDate: sessionsByDate,
          onSessionSelected: onSessionSelected,
        )).toList(),
      ),
    );
  }

  Widget _buildWeekColumn({
    required List<DayCell> week,
    required DateTime now,
    required Map<DateTime, Session> sessionsByDate,
    Function(Session)? onSessionSelected,
  }) {
    return Column(
      spacing: 3,
      mainAxisSize: MainAxisSize.min,
      children: week.map((cell) {
        // Don't draw box for future days or padding
        if (cell.count < 0 || (cell.date != null && cell.date!.isAfter(now))) {
          return Container(width: 14, height: 14);
        }
        
        // Find first session for this date
        final session = cell.date != null ? sessionsByDate[cell.date] : null;
        
        if (session != null && onSessionSelected != null) {
          return GestureDetector(
            onTap: () => onSessionSelected(session),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _colorForCount(cell.count),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _colorForCount(cell.count),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  Color _colorForCount(int count) {
    if (count < 0) return Colors.transparent;
    if (count == 0) return const Color(0xFF10B981).withOpacity(0.08);
    if (count == 1) return const Color(0xFF10B981).withOpacity(0.3);
    if (count <= 3) return const Color(0xFF10B981).withOpacity(0.5);
    if (count <= 6) return const Color(0xFF10B981).withOpacity(0.7);
    return const Color(0xFF10B981);
  }
}

class DayCell {
  final DateTime? date;
  final int count;

  const DayCell({required this.date, required this.count});
}
