import 'dart:io';
import 'dart:async';

typedef FileChangeCallback = void Function();

class FileWatcher {
  final String directoryPath;
  final FileChangeCallback onChange;
  Timer? _timer;
  DateTime? _lastModification;
  Set<String>? _lastEntries;
  bool _started = false;

  FileWatcher({
    required this.directoryPath,
    required this.onChange,
    Duration interval = const Duration(seconds: 1),
  }) {
    print('FileWatcher: Initialized for $directoryPath');
    _start(interval);
  }

  void _start(Duration interval) {
    if (_started) return;
    _started = true;
    print('FileWatcher: Started monitoring $directoryPath (interval: ${interval.inSeconds}s)');
    _checkForChanges();
    _timer = Timer.periodic(interval, (_) => _checkForChanges());
  }

  Future<void> _checkForChanges() async {
    try {
      final dir = Directory(directoryPath);
      final exists = await dir.exists();
      
      if (!exists) {
        print('FileWatcher: Directory does not exist: $directoryPath');
        return;
      }

      final stat = await dir.stat();

      // If first check, just remember the state
      if (_lastModification == null) {
        _lastModification = stat.modified;
        print('FileWatcher: Initial modification time set for $directoryPath: $_lastModification');
        // Also initialize entries list on first check
        try {
          _lastEntries = (await dir.list().toList())
              .where((e) => e is Directory)
              .map((e) => e.path)
              .toSet();
          print('FileWatcher: Initial entries tracked for $directoryPath: ${_lastEntries!.length}');
        } catch (e) {
          print('FileWatcher: Error listing initial entries: $e');
        }
        return;
      }

      // Check for new/removed subdirectories
      bool entriesChanged = false;
      try {
        final currentEntries = (await dir.list().toList())
            .where((e) => e is Directory)
            .map((e) => e.path)
            .toSet();
        
        if (_lastEntries == null) {
          _lastEntries = currentEntries;
        } else if (_lastEntries!.length != currentEntries.length ||
                   !_lastEntries!.containsAll(currentEntries) ||
                   !currentEntries.containsAll(_lastEntries!)) {
          entriesChanged = true;
          _lastEntries = currentEntries;
        }
      } catch (e) {
        print('FileWatcher: Error listing entries: $e');
      }

      // Also check modification time for robustness
      bool wasModified = false;
      if (_lastModification != null && stat.modified.isAfter(_lastModification!)) {
        wasModified = true;
        _lastModification = stat.modified;
      } else if (_lastModification == null) {
        _lastModification = stat.modified;
      }

      if (entriesChanged || wasModified) {
        print('FileWatcher: Change detected in $directoryPath at $stat.modified');
        onChange();
      }
    } catch (e) {
      print('FileWatcher: Error checking $directoryPath: $e');
    }
  }

  void stop() {
    if (!_started) return;
    _timer?.cancel();
    _timer = null;
    _started = false;
    print('FileWatcher: Stopped monitoring $directoryPath');
  }
}
