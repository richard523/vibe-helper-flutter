import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';
import '../widgets/tool_usage_card.dart';
import '../widgets/enhanced_heatmap.dart';
import '../widgets/project_breakdown_card.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.filteredSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadAll(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Overview stats row
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          context,
                          'Total Spend',
                          '\$${formatDoubleWithCommas(appState.totalCost, 2)}',
                          Icons.monetization_on,
                          const Color(0xFF6B46C1),
                        ),
                      ),
                      Expanded(
                        child: _buildStatTile(
                          context,
                          'Total Tokens',
                          _formatTokens(appState.totalTokens),
                          Icons.text_fields,
                          const Color(0xFF06B6D4),
                        ),
                      ),
                      Expanded(
                        child: _buildStatTile(
                          context,
                          'Sessions',
                          formatNumberWithCommas(appState.totalSessions),
                          Icons.history,
                          const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: _buildStatTile(
                          context,
                          'Tool Calls',
                          formatNumberWithCommas(appState.totalToolCalls),
                          Icons.build,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cost & Token breakdown by project side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProjectBreakdownCard(
                      sessions: sessions,
                      title: 'Cost by Project',
                      unit: 'cost',
                      color: const Color(0xFF6B46C1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProjectBreakdownCard(
                      sessions: sessions,
                      title: 'Tokens by Project',
                      unit: 'tokens',
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tool usage + sessions by project side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ToolUsageCard(
                      agreed: appState.toolCallBreakdown['agreed'] ?? 0,
                      rejected: appState.toolCallBreakdown['rejected'] ?? 0,
                      failed: appState.toolCallBreakdown['failed'] ?? 0,
                      succeeded: sessions.fold(0, (sum, s) => sum + s.stats.toolCallsSucceeded),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProjectBreakdownCard(
                      sessions: sessions,
                      title: 'Sessions by Project',
                      unit: 'sessions',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Enhanced heatmap
              const Text(
                'Activity Heatmap',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EnhancedHeatmap(
                    sessions: sessions,
                    onSessionSelected: (session) {
                      appState.selectedSession = session;
                      Navigator.pushNamed(context, '/session');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) return '${formatDoubleWithCommas(tokens / 1000000, 1)}M';
    if (tokens >= 1000) return '${formatDoubleWithCommas(tokens / 1000, 1)}K';
    return formatNumberWithCommas(tokens);
  }
}
