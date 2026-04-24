import 'dart:io';

import '../models/config.dart';
import '../utils/vibe_paths.dart';

class ConfigLoader {
  static final String _configPath = VibePaths.configFilePath;

  static Future<VibeConfig> loadConfig() async {
    final file = File(_configPath);

    if (!await file.exists()) {
      return VibeConfig(
        activeModel: '',
        models: [],
        providers: [],
      );
    }

    try {
      final content = await file.readAsString();
      return VibeConfig.fromToml(content);
    } catch (e) {
      print('Error loading config: $e');
      return VibeConfig(
        activeModel: '',
        models: [],
        providers: [],
      );
    }
  }

  static Future<List<String>> loadEnabledSkills() async {
    return _parseTomlArray('enabled_skills');
  }

  static Future<List<String>> loadDisabledSkills() async {
    return _parseTomlArray('disabled_skills');
  }

  static Future<List<String>> _parseTomlArray(String key) async {
    final file = File(_configPath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('$key =')) {
          // Parse array like: enabled_skills = ["skill1", "skill2"]
          final start = trimmed.indexOf('[');
          final end = trimmed.lastIndexOf(']');
          if (start >= 0 && end > start) {
            final arrayContent = trimmed.substring(start + 1, end);
            // Split by commas, remove quotes, trim
            return arrayContent
                .split(',')
                .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
                .where((s) => s.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      print('Error parsing $key: $e');
    }
    return [];
  }
}
