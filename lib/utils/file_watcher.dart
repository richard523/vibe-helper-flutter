import 'dart:io';
import 'dart:async';

typedef FileChangeCallback = void Function();

class FileWatcher {
  final String directoryPath;
  final FileChangeCallback onChange;
  Timer? _timer;
  DateTime? _lastModification;
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
        return;
      }

      // Check if directory was modified
      if (stat.modified.isAfter(_lastModification!)) {
        _lastModification = stat.modified;
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
