import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import '../models/session.dart';
import '../models/message.dart';
import '../utils/vibe_paths.dart';

class SessionLoader {
  static final String _sessionDir = VibePaths.sessionLogsDirectory;

  static Future<List<Session>> loadAllSessions() async {
    final dir = Directory(_sessionDir);

    if (!await dir.exists()) {
      return [];
    }

    try {
      final entries = await dir.list().toList();
      final sessions = <Session>[];

      for (final entry in entries) {
        if (entry is! Directory) continue;
        
        final metaFile = File(path.join(entry.path, 'meta.json'));
        if (!await metaFile.exists()) continue;

        try {
          final metaContent = await metaFile.readAsString();
          final metaJson = jsonDecode(metaContent) as Map<String, dynamic>;
          
          // Load messages
          final messagesFile = File(path.join(entry.path, 'messages.jsonl'));
          final messages = <SessionMessage>[];
          if (await messagesFile.exists()) {
            final messagesContent = await messagesFile.readAsString();
            for (final line in messagesContent.split('\n')) {
              if (line.trim().isEmpty) continue;
              try {
                final msgJson = jsonDecode(line.trim()) as Map<String, dynamic>;
                messages.add(SessionMessage.fromJson(msgJson));
              } catch (e) {
                // Skip invalid lines
              }
            }
          }
          
          final session = Session.fromJson(metaJson, 
            directoryPath: entry.path,
            messages: messages,
          );
          sessions.add(session);
        } catch (e) {
          print('Failed to parse ${metaFile.path}: $e');
        }
      }

      // Sort by startTime descending (newest first)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return sessions;
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  static Future<Session?> loadSession(String sessionId) async {
    final sessions = await loadAllSessions();
    return sessions.cast<Session?>().firstWhere(
          (s) => s?.sessionId == sessionId,
          orElse: () => null,
        );
  }

  /// Load sessions for a specific project
  static Future<List<Session>> loadSessionsForProject(String projectName) async {
    final allSessions = await loadAllSessions();
    return allSessions.where((s) => s.projectName == projectName).toList();
  }
}
