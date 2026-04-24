import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import '../models/session.dart';
import '../models/message.dart';
import '../utils/vibe_paths.dart';

class SessionLoader {
  static Future<List<Session>> loadAllSessions() async {
    final sessionDir = VibePaths.sessionLogsDirectory;
    
    print('SessionLoader: Loading sessions from $sessionDir');
    
    final dir = Directory(sessionDir);

    if (!await dir.exists()) {
      print('SessionLoader: Session directory does not exist at $sessionDir');
      return [];
    }

    try {
      final entries = await dir.list().toList();
      print('SessionLoader: Found ${entries.length} entries');
      
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
                print('SessionLoader: Skipping invalid message line: $e');
              }
            }
          }
          
          final session = Session.fromJson(metaJson, 
            directoryPath: entry.path,
            messages: messages,
          );
          sessions.add(session);
        } catch (e) {
          print('SessionLoader: Failed to parse ${metaFile.path}: $e');
        }
      }

      // Sort by startTime descending (newest first)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      print('SessionLoader: Loaded ${sessions.length} sessions');
      return sessions;
    } catch (e) {
      print('SessionLoader: Error loading sessions: $e');
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
