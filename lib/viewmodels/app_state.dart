import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/config.dart';
import '../models/skill.dart';
import '../services/session_loader.dart';
import '../services/config_loader.dart';
import '../services/skill_loader.dart';
import '../utils/vibe_paths.dart';
import '../utils/file_watcher.dart';

// Simple enum-like class for time range filter
class TimeRangeOption {
  final String label;
  final int? daysAgo;

  const TimeRangeOption._({
    required this.label,
    this.daysAgo,
  });

  // Singleton instances
  static const allTime = TimeRangeOption._(label: 'All Time');
  static const today = TimeRangeOption._(label: 'Today', daysAgo: 0);
  static const last7Days = TimeRangeOption._(label: '7 Days', daysAgo: 7);
  static const last30Days = TimeRangeOption._(label: '30 Days', daysAgo: 30);

  static const List<TimeRangeOption> presets = [today, last7Days, last30Days, allTime];

  // Computed date range
  DateTime? get startDate {
    if (daysAgo == null) return null;
    final now = DateTime.now();
    if (daysAgo == 0) {
      return DateTime(now.year, now.month, now.day);
    }
    return now.subtract(Duration(days: daysAgo!));
  }

  DateTime? get endDate {
    if (daysAgo == null) return null;
    return DateTime.now();
  }

  TimeRangeOption copyWithCustom(DateTime startDate, DateTime endDate) {
    return TimeRangeOption._(
      label: 'Custom',
      daysAgo: null,
    );
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeRangeOption && other.label == label;
  }

  @override
  int get hashCode => label.hashCode;
}

class AppState with ChangeNotifier {
  // Sessions
  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;
  set sessions(List<Session> value) {
    _sessions = value;
    notifyListeners();
  }

  List<Session> get filteredSessions {
    final now = DateTime.now();
    return _sessions.where((session) {
      final matchesProject = selectedProject == null || session.projectName == selectedProject;
      
      bool matchesTime = true;
      final start = timeRange.startDate;
      if (start != null) {
        final end = timeRange.endDate ?? now;
        matchesTime = session.startTime.isAfter(start) && 
                     session.startTime.isBefore(end);
      }
      
      return matchesProject && matchesTime;
    }).toList();
  }

  List<String> get projects => 
      _sessions.map((s) => s.projectName).toSet().toList()..sort();

  // Config
  VibeConfig _config = VibeConfig(activeModel: '', models: [], providers: []);
  VibeConfig get config => _config;
  set config(VibeConfig value) {
    _config = value;
    notifyListeners();
  }

  // Skills
  List<Skill> _skills = [];
  List<Skill> get skills => _skills;
  set skills(List<Skill> value) {
    _skills = value;
    notifyListeners();
  }

  // Filters
  String? _selectedProject;
  String? get selectedProject => _selectedProject;
  set selectedProject(String? value) {
    _selectedProject = value;
    notifyListeners();
  }

  TimeRangeOption _timeRange = TimeRangeOption.allTime;
  TimeRangeOption get timeRange => _timeRange;
  set timeRange(TimeRangeOption value) {
    _timeRange = value;
    notifyListeners();
  }

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Selected session
  Session? _selectedSession;
  Session? get selectedSession => _selectedSession;
  set selectedSession(Session? value) {
    _selectedSession = value;
    notifyListeners();
  }

  // File watchers
  FileWatcher? _sessionWatcher;
  FileWatcher? _configWatcher;

  Future<void> loadAll() async {
    print('AppState: Starting full reload...');
    isLoading = true;
    await Future.wait([
      _loadSessions(),
      _loadConfig(),
      _loadSkills(),
    ]);
    isLoading = false;
    print('AppState: Full reload complete. Loaded ${sessions.length} sessions, ${skills.length} skills');
    startWatching();
  }

  Future<void> _loadSessions() async {
    print('AppState: Loading sessions...');
    sessions = await SessionLoader.loadAllSessions();
    print('AppState: Sessions updated (${sessions.length} total)');
  }

  Future<void> _loadConfig() async {
    print('AppState: Loading config...');
    config = await ConfigLoader.loadConfig();
    print('AppState: Config updated');
  }

  Future<void> _loadSkills() async {
    print('AppState: Loading skills...');
    skills = await SkillLoader.loadAllSkills();
    print('AppState: Skills updated (${skills.length} total)');
  }

  void startWatching() {
    print('AppState: Starting file watchers...');
    _sessionWatcher = FileWatcher(
      directoryPath: VibePaths.sessionLogsDirectory,
      onChange: () async {
        print('AppState: Session directory changed, reloading...');
        await _loadSessions();
      },
    );
    
    _configWatcher = FileWatcher(
      directoryPath: VibePaths.vibeDirectory,
      onChange: () async {
        print('AppState: Config directory changed, reloading...');
        await Future.wait([
          _loadConfig(),
          _loadSkills(),
        ]);
      },
    );
    print('AppState: File watchers started');
  }

  void stopWatching() {
    print('AppState: Stopping file watchers...');
    _sessionWatcher?.stop();
    _configWatcher?.stop();
    _sessionWatcher = null;
    _configWatcher = null;
    print('AppState: File watchers stopped');
  }

  // Stats computed properties (using filteredSessions like original)
  double get totalCost => 
      filteredSessions.fold(0.0, (sum, s) => sum + s.stats.sessionCost);

  int get totalTokens => 
      filteredSessions.fold(0, (sum, s) => sum + s.stats.sessionTotalLlmTokens);

  int get totalSessions => filteredSessions.length;

  int get totalToolCalls => 
      filteredSessions.fold(0, (sum, s) => sum + s.stats.totalToolCalls);

  double get averageTokensPerSecond {
    final speeds = filteredSessions.map((s) => s.stats.tokensPerSecond);
    if (speeds.isEmpty) return 0;
    return speeds.reduce((a, b) => a + b) / speeds.length;
  }

  List<MapEntry<String, double>> get costByProject {
    final map = <String, double>{};
    for (final session in filteredSessions) {
      map.update(
        session.projectName,
        (value) => value + session.stats.sessionCost,
        ifAbsent: () => session.stats.sessionCost,
      );
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  Map<String, int> get toolCallBreakdown {
    return {
      'agreed': filteredSessions.fold(0, (sum, s) => sum + s.stats.toolCallsAgreed),
      'rejected': filteredSessions.fold(0, (sum, s) => sum + s.stats.toolCallsRejected),
      'failed': filteredSessions.fold(0, (sum, s) => sum + s.stats.toolCallsFailed),
    };
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}
