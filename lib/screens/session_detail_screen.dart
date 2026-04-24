import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';
import '../models/session.dart';
import '../models/message.dart';
import '../utils/formatters.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final session = appState.selectedSession;

    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text('No session selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Session: ${session.projectName}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            session.sessionId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${session.formattedDuration}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Messages: ${session.totalMessages}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Working Directory: ${session.environment.workingDirectory}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stats
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Cost',
                      session.stats.formattedCost,
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Tokens',
                      session.stats.formattedTokens,
                      Icons.text_fields,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Token Speed',
                      '${formatDoubleWithCommas(session.stats.tokensPerSecond, 1)} tok/s',
                      Icons.speed,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Prompt Tokens',
                      formatNumberWithCommas(session.stats.sessionPromptTokens),
                      Icons.input,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Completion Tokens',
                      formatNumberWithCommas(session.stats.sessionCompletionTokens),
                      Icons.output,
                      Colors.cyan,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tool calls
              const Text(
                'Tool Calls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      _buildToolStat('Agreed', session.stats.toolCallsAgreed, Colors.green),
                      _buildDivider(),
                      _buildToolStat('Rejected', session.stats.toolCallsRejected, Colors.orange),
                      _buildDivider(),
                      _buildToolStat('Failed', session.stats.toolCallsFailed, Colors.red),
                      _buildDivider(),
                      _buildToolStat('Succeeded', session.stats.toolCallsSucceeded, Colors.blue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Conversation
              const Text(
                'Conversation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildConversationList(session.messages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolStat(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            formatNumberWithCommas(count),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildConversationList(List<SessionMessage> messages) {
    if (messages.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No conversation messages',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: messages.map((msg) => _buildMessageCard(msg)).toList(),
    );
  }

  Widget _buildMessageCard(SessionMessage msg) {
    final isUser = msg.isUser;
    final isTool = msg.isToolCall;
    
    Color borderColor;
    String roleLabel;
    
    if (isTool) {
      borderColor = Colors.orange;
      roleLabel = msg.toolName ?? 'Tool';
    } else if (isUser) {
      borderColor = Colors.blue;
      roleLabel = 'User';
    } else {
      borderColor = Colors.green;
      roleLabel = 'Assistant';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (msg.timestamp != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${msg.timestamp!.hour}:${msg.timestamp!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (isTool) ...[
              if (msg.toolArguments != null && msg.toolArguments!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Args: ${msg.toolArguments!}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (msg.toolResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    msg.toolResult!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: msg.toolSuccess == true ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ] else ...[
              Text(
                msg.content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
