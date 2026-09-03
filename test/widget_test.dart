import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vibe_helper/models/message.dart';

void main() {
  group('SessionMessage.fromJson', () {
    test('parses assistant tool-call request from tool_calls array', () {
      final json = {
        'role': 'assistant',
        'content': '',
        'tool_calls': [
          {
            'id': 'abc123',
            'type': 'function',
            'function': {
              'name': 'grep',
              'arguments': '{"pattern": "teleport", "path": "."}',
            },
          },
        ],
        'message_id': 1,
      };
      final msg = SessionMessage.fromJson(json);

      expect(msg.role, 'assistant');
      expect(msg.isToolRequest, isTrue);
      expect(msg.isToolResult, isFalse);
      expect(msg.toolName, 'grep');
      expect(msg.toolArguments, {'pattern': 'teleport', 'path': '.'});
    });

    test('parses tool-result message (role == "tool")', () {
      final json = {
        'role': 'tool',
        'content': 'matches: \nmatch_count: 0\nwas_truncated: False',
        'injected': false,
        'name': 'grep',
        'tool_call_id': 'abc123',
      };
      final msg = SessionMessage.fromJson(json);

      expect(msg.isToolResult, isTrue);
      expect(msg.isToolRequest, isFalse);
      expect(msg.toolName, 'grep');
      expect(msg.toolCallId, 'abc123');
      expect(msg.toolResult, contains('match_count: 0'));
      expect(msg.toolSuccess, isTrue);
    });

    test('infers tool failure from <tool_error> / <user_cancellation>', () {
      final fail = SessionMessage.fromJson({
        'role': 'tool',
        'content': '<tool_error>boom</tool_error>',
        'name': 'bash',
        'tool_call_id': 'x',
      });
      expect(fail.toolSuccess, isFalse);

      final cancel = SessionMessage.fromJson({
        'role': 'tool',
        'content': '<user_cancellation>User cancelled</user_cancellation>',
        'name': 'bash',
        'tool_call_id': 'y',
      });
      expect(cancel.toolSuccess, isFalse);
    });

    test('assistant with content + tool_calls keeps both', () {
      final json = {
        'role': 'assistant',
        'content': 'Let me search the codebase.',
        'tool_calls': [
          {
            'id': 'z',
            'type': 'function',
            'function': {'name': 'grep', 'arguments': '{"pattern":"foo"}'},
          },
        ],
      };
      final msg = SessionMessage.fromJson(json);

      expect(msg.content, 'Let me search the codebase.');
      expect(msg.isToolRequest, isTrue);
      expect(msg.toolName, 'grep');
    });

    test('plain user message has no tool fields', () {
      final msg = SessionMessage.fromJson({
        'role': 'user',
        'content': 'Hello',
      });
      expect(msg.isUser, isTrue);
      expect(msg.isToolRequest, isFalse);
      expect(msg.isToolResult, isFalse);
      expect(msg.toolName, isNull);
    });
  });
}
