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
  static const last7Days = TimeRangeOption._(label: 'Last 7 Days', daysAgo: 7);
  static const last30Days = TimeRangeOption._(label: 'Last 30 Days', daysAgo: 30);

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
      label: 'Custom ${startDate.toString().substring(0, 10)} - ${endDate.toString().substring(0, 10)}',
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
    isLoading = true;
    await Future.wait([
      _loadSessions(),
      _loadConfig(),
      _loadSkills(),
    ]);
    isLoading = false;
    startWatching();
  }

  Future<void> _loadSessions() async {
    sessions = await SessionLoader.loadAllSessions();
  }

  Future<void> _loadConfig() async {
    config = await ConfigLoader.loadConfig();
  }

  Future<void> _loadSkills() async {
    skills = await SkillLoader.loadAllSkills();
  }

  void startWatching() {
    _sessionWatcher = FileWatcher(
      directoryPath: VibePaths.sessionLogsDirectory,
      onChange: () async {
        await _loadSessions();
      },
    );
    
    _configWatcher = FileWatcher(
      directoryPath: VibePaths.vibeDirectory,
      onChange: () async {
        await Future.wait([
          _loadConfig(),
          _loadSkills(),
        ]);
      },
    );
  }

  void stopWatching() {
    _sessionWatcher?.stop();
    _configWatcher?.stop();
    _sessionWatcher = null;
    _configWatcher = null;
  }

  // Stats computed properties
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
