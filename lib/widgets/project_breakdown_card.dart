import 'package:flutter/material.dart';

import '../models/session.dart';
import '../utils/formatters.dart';

class ProjectBreakdownCard extends StatefulWidget {
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

  @override
  State<ProjectBreakdownCard> createState() => _ProjectBreakdownCardState();
}

class _ProjectBreakdownCardState extends State<ProjectBreakdownCard> {
  bool _expanded = false;

  List<MapEntry<String, double>> get _breakdown {
    final map = <String, double>{};
    for (final s in widget.sessions) {
      final value = widget.unit == 'cost'
          ? s.stats.sessionCost
          : widget.unit == 'tokens'
              ? s.stats.sessionTotalLlmTokens.toDouble()
              : 1.0;
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
    final displayCount = _expanded ? data.length : 8;
    final display = data.take(displayCount).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (data.length > 8)
                  TextButton.icon(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16),
                    label: Text(
                      _expanded
                          ? 'Show top 8'
                          : '+ ${data.length - 8} more',
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: _expanded ? 600 : 260),
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
                              backgroundColor: widget.color.withOpacity(0.1),
                              color: widget.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            widget.unit == 'cost'
                                ? '\$${formatDoubleWithCommas(entry.value, 2)}'
                                : widget.unit == 'tokens'
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
