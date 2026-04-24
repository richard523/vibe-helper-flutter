class SessionMessage {
  final String? role;
  final String content;
  final DateTime? timestamp;
  final String? toolCallId;
  final String? toolName;
  final Map<String, dynamic>? toolArguments;
  final String? toolResult;
  final bool? toolSuccess;

  SessionMessage({
    this.role,
    required this.content,
    this.timestamp,
    this.toolCallId,
    this.toolName,
    this.toolArguments,
    this.toolResult,
    this.toolSuccess,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isToolCall => toolName != null;

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      role: json['role'] as String?,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : null,
      toolCallId: json['tool_call_id'] as String?,
      toolName: json['tool_name'] as String?,
      toolArguments: json['tool_arguments'] as Map<String, dynamic>?,
      toolResult: json['tool_result'] as String?,
      toolSuccess: json['tool_success'] as bool?,
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
  };
}
