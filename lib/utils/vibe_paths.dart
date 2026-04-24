import 'package:path/path.dart' as path;

class VibePaths {
  static const String vibeDir = '.vibe';
  static const String logsDir = 'logs';
  static const String sessionDir = 'session';
  static const String configFile = 'config.toml';
  static const String skillsDir = 'skills';
  static const String skillFile = 'SKILL.md';

  static String get homeDir {
    // Use environment variable HOME which is set on Linux/Unix
    return const String.fromEnvironment('HOME', defaultValue: '/home');
  }

  static String get vibeDirectory => path.join(homeDir, vibeDir);

  static String get configFilePath => path.join(vibeDirectory, configFile);

  static String get sessionLogsDirectory => path.join(vibeDirectory, logsDir, sessionDir);

  static String get skillsDirectory => path.join(vibeDirectory, skillsDir);
}
