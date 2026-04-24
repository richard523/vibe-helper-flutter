import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';
import '../widgets/cost_card.dart';
import '../widgets/token_card.dart';
import '../widgets/activity_card.dart';
import '../widgets/tool_usage_card.dart';
import '../widgets/session_list.dart';
import '../widgets/project_filter.dart';
import '../widgets/time_range_filter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filteredSessions = appState.filteredSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Helper'),
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
            spacing: 16,
            children: [
              // Filters row (matches original toolbar)
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: ProjectFilter()),
                    const SizedBox(width: 16),
                    const Expanded(flex: 2, child: TimeRangeFilter()),
                    const Spacer(flex: 1),
                    // Appearance toggle placeholder
                    IconButton(
                      icon: const Icon(Icons.brightness_6),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              if (appState.isLoading)
                const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
              else ...[
                // Top row: Cost + Tokens (280px height in original)
                SizedBox(
                  height: 280,
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: CostCard(sessions: filteredSessions),
                      ),
                      Expanded(
                        child: TokenCard(sessions: filteredSessions),
                      ),
                    ],
                  ),
                ),

                // Second row: Activity + Tool Usage (280px height in original)
                SizedBox(
                  height: 280,
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: ActivityCard(sessions: filteredSessions),
                      ),
                      Expanded(
                        child: ToolUsageCard(
                          agreed: appState.toolCallBreakdown['agreed'] ?? 0,
                          rejected: appState.toolCallBreakdown['rejected'] ?? 0,
                          failed: appState.toolCallBreakdown['failed'] ?? 0,
                          succeeded: filteredSessions.fold(
                            0, (sum, s) => sum + s.stats.toolCallsSucceeded
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Session list
                SessionList(
                  sessions: filteredSessions,
                  onSessionSelected: (session) {
                    appState.selectedSession = session;
                    Navigator.pushNamed(context, '/session');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
