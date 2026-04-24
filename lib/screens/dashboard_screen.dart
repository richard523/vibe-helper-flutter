import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';
import '../widgets/cost_card.dart';
import '../widgets/token_card.dart';
import '../widgets/session_list.dart';
import '../widgets/project_filter.dart';
import '../widgets/time_range_filter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Helper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadAll(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ProjectFilter(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TimeRangeFilter(),
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CostCard(
                          totalCost: appState.totalCost,
                          totalSessions: appState.totalSessions,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TokenCard(
                          totalTokens: appState.totalTokens,
                          avgTokensPerSecond: appState.averageTokensPerSecond,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Session List
                Expanded(
                  child: SessionList(
                    sessions: appState.filteredSessions,
                    onSessionSelected: (session) {
                      appState.selectedSession = session;
                      // TODO: Navigate to session detail
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
