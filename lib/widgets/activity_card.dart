import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/session.dart';

class ActivityCard extends StatelessWidget {
  final List<Session> sessions;

  const ActivityCard({super.key, required this.sessions});

  int get sessionCount => sessions.length;
  Duration get totalDuration => Duration(
    seconds: sessions.fold(0, (sum, s) => sum + s.duration.inSeconds),
  );
  Duration get avgDuration => sessionCount > 0 
      ? Duration(seconds: totalDuration.inSeconds ~/ sessionCount)
      : Duration.zero;

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
                      'Activity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$sessionCount sessions',
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
                    Text(
                      'avg ${_formatDuration(avgDuration)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'total ${_formatDuration(totalDuration)}',
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
            // Heatmap
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildHeatmap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildHeatmap() {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No activity',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Get date range
    final dates = sessions.map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Count sessions per day
    final countByDay = <DateTime, int>{};
    for (final date in dates) {
      countByDay.update(date, (value) => value + 1, ifAbsent: () => 1);
    }

    // Build heatmap grid (7 columns = week)
    // Start from minDate''s week
    final startOfWeek = minDate.subtract(Duration(days: minDate.weekday - 1));
    
    final List<List<int>> weeks = [];
    var current = startOfWeek;
    final end = maxDate;
    
    var currentWeek = <int>[];
    
    while (current.isBefore(end) || current == end) {
      final dayCount = countByDay[current] ?? 0;
      currentWeek.add(dayCount);
      
      // End of week
      if (current.weekday == DateTime.sunday) {
        // Pad week to 7 days
        while (currentWeek.length < 7) {
          currentWeek.add(-1); // Padding
        }
        weeks.add(currentWeek);
        currentWeek = [];
      }
      
      current = current.add(const Duration(days: 1));
    }
    
    // Add last partial week
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(-1);
      }
      weeks.add(currentWeek);
    }

    return Row(
      spacing: 3,
      children: weeks.map((week) => Column(
        spacing: 3,
        mainAxisSize: MainAxisSize.min,
        children: week.map((count) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _colorForCount(count),
            borderRadius: BorderRadius.circular(2),
          ),
          child: count >= 0 ? null : null,
        )).toList(),
      )).toList(),
    );
  }

  Color _colorForCount(int count) {
    if (count < 0) return Colors.transparent;
    if (count == 0) return Color(0xFF10B981).withOpacity(0.08);
    if (count == 1) return Color(0xFF10B981).withOpacity(0.3);
    if (count <= 3) return Color(0xFF10B981).withOpacity(0.5);
    if (count <= 6) return Color(0xFF10B981).withOpacity(0.7);
    return Color(0xFF10B981);
  }
}
