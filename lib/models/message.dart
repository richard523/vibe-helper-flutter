import 'dart:convert';

class SessionMessage {
  final String? role;
  final String content;
  final DateTime? timestamp;
  final String? toolCallId;
  final String? toolName;
  final Map<String, dynamic>? toolArguments;
  final String? toolResult;
  final bool? toolSuccess;
  final String? reasoningContent;

  SessionMessage({
    this.role,
    required this.content,
    this.timestamp,
    this.toolCallId,
    this.toolName,
    this.toolArguments,
    this.toolResult,
    this.toolSuccess,
    this.reasoningContent,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isToolResult => role == 'tool';
  bool get isToolRequest => isAssistant && toolName != null;
  bool get isToolCall => toolName != null;

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    String? toolName;
    Map<String, dynamic>? toolArguments;
    String? toolResult;
    bool? toolSuccess;
    String? toolCallId;

    final role = json['role'] as String?;
    final content = json['content'] as String? ?? '';

    // Assistant tool_calls array
    final toolCalls = json['tool_calls'];
    if (toolCalls is List && toolCalls.isNotEmpty) {
      final first = toolCalls.first as Map<String, dynamic>;
      final fn = first['function'] as Map<String, dynamic>?;
      if (fn != null) {
        toolName = fn['name'] as String?;
        final args = fn['arguments'];
        if (args is String) {
          try {
            toolArguments = jsonDecode(args) as Map<String, dynamic>;
          } catch (_) {
            toolArguments = {'_raw': args};
          }
        } else if (args is Map) {
          toolArguments = Map<String, dynamic>.from(args);
        }
      }
    }

    // Tool result message (role == "tool")
    if (role == 'tool') {
      toolName = json['name'] as String? ?? toolName;
      toolResult = content;
      toolCallId = json['tool_call_id'] as String?;
      // Infer success unless content signals an error/cancellation
      final lc = content.toLowerCase();
      toolSuccess = !(lc.contains('<tool_error>') ||
          lc.contains('<user_cancellation>'));
    }

    return SessionMessage(
      role: role,
      content: content,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      toolCallId: toolCallId ?? (json['tool_call_id'] as String?),
      toolName: toolName,
      toolArguments: toolArguments,
      toolResult: toolResult,
      toolSuccess: toolSuccess,
      reasoningContent: json['reasoning_content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp?.toIso8601String(),
    'tool_call_id': toolCallId,
    'tool_name': toolName,
    'tool_arguments': toolArguments,
    'tool_result': toolResult,
    'tool_success': toolSuccess,
    'reasoning_content': reasoningContent,
  };
}
