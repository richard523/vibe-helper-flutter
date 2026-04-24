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
    _start(interval);
  }

  void _start(Duration interval) {
    if (_started) return;
    _started = true;
    _checkForChanges();
    _timer = Timer.periodic(interval, (_) => _checkForChanges());
  }

  Future<void> _checkForChanges() async {
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) return;

      final stat = await dir.stat();

      // If first check, just remember the state
      if (_lastModification == null) {
        _lastModification = stat.modified;
        return;
      }

      // Check if directory was modified
      if (stat.modified.isAfter(_lastModification!)) {
        _lastModification = stat.modified;
        onChange();
      }
    } catch (e) {
      // print('FileWatcher error: $e');
      // Directory might not exist yet
    }
  }

  void stop() {
    if (!_started) return;
    _timer?.cancel();
    _timer = null;
    _started = false;
  }
}
