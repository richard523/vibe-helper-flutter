import 'package:path/path.dart' as path;
import 'message.dart';
import '../utils/formatters.dart';

class Session {
  final String sessionId;
  final DateTime startTime;
  final DateTime endTime;
  final String? gitCommit;
  final String? gitBranch;
  final SessionEnvironment environment;
  final String username;
  final SessionStats stats;
  final int totalMessages;
  final String? title;
  String? directoryPath;
  List<SessionMessage> messages;

  Session({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    this.gitCommit,
    this.gitBranch,
    required this.environment,
    required this.username,
    required this.stats,
    required this.totalMessages,
    this.title,
    this.directoryPath,
    this.messages = const [],
  });

  String get id => sessionId;

  String get projectName {
    final dir = environment.workingDirectory;
    return path.basename(dir);
  }

  Duration get duration => endTime.difference(startTime);

  String get formattedDuration {
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

  factory Session.fromJson(Map<String, dynamic> json, {String? directoryPath, List<SessionMessage> messages = const []}) {
    return Session(
      sessionId: json['session_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      gitCommit: json['git_commit'] as String?,
      gitBranch: json['git_branch'] as String?,
      environment: SessionEnvironment.fromJson(json['environment'] as Map<String, dynamic>),
      username: json['username'] as String,
      stats: SessionStats.fromJson(json['stats'] as Map<String, dynamic>),
      totalMessages: json['total_messages'] as int,
      title: json['title'] as String?,
      directoryPath: directoryPath,
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'git_commit': gitCommit,
    'git_branch': gitBranch,
    'environment': environment.toJson(),
    'username': username,
    'stats': stats.toJson(),
    'total_messages': totalMessages,
    'title': title,
  };
}

class SessionEnvironment {
  final String workingDirectory;

  SessionEnvironment({required this.workingDirectory});

  factory SessionEnvironment.fromJson(Map<String, dynamic> json) {
    return SessionEnvironment(
      workingDirectory: json['working_directory'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'working_directory': workingDirectory,
  };
}

class SessionStats {
  final int steps;
  final int sessionPromptTokens;
  final int sessionCompletionTokens;
  final int toolCallsAgreed;
  final int toolCallsRejected;
  final int toolCallsFailed;
  final int toolCallsSucceeded;
  final int contextTokens;
  final int lastTurnPromptTokens;
  final int lastTurnCompletionTokens;
  final double lastTurnDuration;
  final double tokensPerSecond;
  final double inputPricePerMillion;
  final double outputPricePerMillion;
  final int sessionTotalLlmTokens;
  final int lastTurnTotalTokens;
  final double sessionCost;

  SessionStats({
    required this.steps,
    required this.sessionPromptTokens,
    required this.sessionCompletionTokens,
    required this.toolCallsAgreed,
    required this.toolCallsRejected,
    required this.toolCallsFailed,
    required this.toolCallsSucceeded,
    required this.contextTokens,
    required this.lastTurnPromptTokens,
    required this.lastTurnCompletionTokens,
    required this.lastTurnDuration,
    required this.tokensPerSecond,
    required this.inputPricePerMillion,
    required this.outputPricePerMillion,
    required this.sessionTotalLlmTokens,
    required this.lastTurnTotalTokens,
    required this.sessionCost,
  });

  int get totalToolCalls => toolCallsAgreed + toolCallsRejected + toolCallsFailed;

  String get formattedCost => '\$${formatDoubleWithCommas(sessionCost, 2)}';

  String get formattedTokens => formatNumberWithCommas(sessionTotalLlmTokens);

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      steps: json['steps'] as int? ?? 0,
      sessionPromptTokens: json['session_prompt_tokens'] as int? ?? 0,
      sessionCompletionTokens: json['session_completion_tokens'] as int? ?? 0,
      toolCallsAgreed: json['tool_calls_agreed'] as int? ?? 0,
      toolCallsRejected: json['tool_calls_rejected'] as int? ?? 0,
      toolCallsFailed: json['tool_calls_failed'] as int? ?? 0,
      toolCallsSucceeded: json['tool_calls_succeeded'] as int? ?? 0,
      contextTokens: json['context_tokens'] as int? ?? 0,
      lastTurnPromptTokens: json['last_turn_prompt_tokens'] as int? ?? 0,
      lastTurnCompletionTokens: json['last_turn_completion_tokens'] as int? ?? 0,
      lastTurnDuration: (json['last_turn_duration'] as num? ?? 0).toDouble(),
      tokensPerSecond: (json['tokens_per_second'] as num? ?? 0).toDouble(),
      inputPricePerMillion: (json['input_price_per_million'] as num? ?? 0).toDouble(),
      outputPricePerMillion: (json['output_price_per_million'] as num? ?? 0).toDouble(),
      sessionTotalLlmTokens: json['session_total_llm_tokens'] as int? ?? 0,
      lastTurnTotalTokens: json['last_turn_total_tokens'] as int? ?? 0,
      sessionCost: (json['session_cost'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'session_prompt_tokens': sessionPromptTokens,
    'session_completion_tokens': sessionCompletionTokens,
    'tool_calls_agreed': toolCallsAgreed,
    'tool_calls_rejected': toolCallsRejected,
    'tool_calls_failed': toolCallsFailed,
    'tool_calls_succeeded': toolCallsSucceeded,
    'context_tokens': contextTokens,
    'last_turn_prompt_tokens': lastTurnPromptTokens,
    'last_turn_completion_tokens': lastTurnCompletionTokens,
    'last_turn_duration': lastTurnDuration,
    'tokens_per_second': tokensPerSecond,
    'input_price_per_million': inputPricePerMillion,
    'output_price_per_million': outputPricePerMillion,
    'session_total_llm_tokens': sessionTotalLlmTokens,
    'last_turn_total_tokens': lastTurnTotalTokens,
    'session_cost': sessionCost,
  };
}
