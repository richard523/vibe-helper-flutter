import 'dart:io' as io;
import 'package:path/path.dart' as path;

class VibePaths {
  static String _homeDirOverride = '';
  
  static set homeDirOverride(String dir) {
    _homeDirOverride = dir;
  }

  static String get homeDir {
    if (_homeDirOverride.isNotEmpty) return _homeDirOverride;
    
    // Try environment variables in platform order
    // On Windows: USERPROFILE is the user's home directory
    // On Unix: HOME is the user's home directory
    final env = io.Platform.environment;
    
    if (io.Platform.isWindows) {
      final userProfile = env['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return userProfile;
      }
      final homeDrive = env['HOMEDRIVE'] ?? '';
      final homePath = env['HOMEPATH'] ?? '';
      final combined = homeDrive + homePath;
      if (combined.isNotEmpty) {
        return combined;
      }
      return 'C:\\Users';
    } else {
      return env['HOME'] ?? '/home';
    }
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
