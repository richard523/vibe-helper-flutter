import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import '../models/session.dart';
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
          final content = await metaFile.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final session = Session.fromJson(json, directoryPath: entry.path);
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
}
