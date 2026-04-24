import 'dart:io' as io;
import 'package:path/path.dart' as path;

class VibePaths {
  static String _homeDirOverride = '';
  
  static set homeDirOverride(String dir) {
    _homeDirOverride = dir;
  }

  static String get homeDir {
    if (_homeDirOverride.isNotEmpty) return _homeDirOverride;
    // Use Platform.environment for HOME which handles cross-platform properly
    return io.Platform.environment['HOME'] ?? '/home';
  }

  static const String vibeDir = '.vibe';
  static const String logsDir = 'logs';
  static const String sessionDir = 'session';
  static const String configFile = 'config.toml';
  static const String skillsDir = 'skills';
  static const String skillFile = 'SKILL.md';

  static String get vibeDirectory => path.join(homeDir, vibeDir);

  static String get configFilePath => path.join(vibeDirectory, configFile);

  static String get sessionLogsDirectory => path.join(vibeDirectory, logsDir, sessionDir);

  static String get skillsDirectory => path.join(vibeDirectory, skillsDir);
}
