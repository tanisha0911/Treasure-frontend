import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../providers/app_provider.dart';

class PeriodicUpdateService {
  static const Duration _updateInterval = Duration(minutes: 7); // 7 minutes
  static Timer? _timer;
  static AppProvider? _appProvider;
  static bool _isRunning = false;

  static void start(AppProvider appProvider) {
    if (_isRunning) {
      stop();
    }

    _appProvider = appProvider;
    _isRunning = true;

    if (kDebugMode) {
      print(
          'Starting periodic updates every ${_updateInterval.inMinutes} minutes');
    }

    // Start the timer
    _timer = Timer.periodic(_updateInterval, (timer) {
      _performUpdate();
    });

    // Also perform an initial update
    _performUpdate();
  }

  static void stop() {
    if (kDebugMode) {
      print('Stopping periodic updates');
    }

    _timer?.cancel();
    _timer = null;
    _appProvider = null;
    _isRunning = false;
  }

  static bool get isRunning => _isRunning;

  static void _performUpdate() {
    if (_appProvider == null) return;

    if (kDebugMode) {
      print('Performing periodic update at ${DateTime.now()}');
    }

    try {
      // Refresh all data
      _appProvider!.refreshData();

      if (kDebugMode) {
        print('Periodic update completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during periodic update: $e');
      }
    }
  }

  static void forceUpdate() {
    if (kDebugMode) {
      print('Force updating data...');
    }
    _performUpdate();
  }

  static Duration get nextUpdateIn {
    if (_timer == null || !_isRunning) {
      return Duration.zero;
    }

    // Calculate remaining time until next update
    final elapsed = Duration(
        milliseconds: _timer!.tick * _updateInterval.inMilliseconds ~/ 1000);
    final remaining = _updateInterval - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String get nextUpdateText {
    if (!_isRunning) return 'Updates paused';

    final remaining = nextUpdateIn;
    if (remaining == Duration.zero) return 'Updating...';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return 'Next update in ${minutes}m ${seconds}s';
    } else {
      return 'Next update in ${seconds}s';
    }
  }
}

// Widget to display update status
class UpdateStatusWidget extends StatefulWidget {
  const UpdateStatusWidget({super.key});

  @override
  State<UpdateStatusWidget> createState() => _UpdateStatusWidgetState();
}

class _UpdateStatusWidgetState extends State<UpdateStatusWidget> {
  Timer? _displayTimer;

  @override
  void initState() {
    super.initState();
    // Update the display every second
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PeriodicUpdateService.isRunning) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh,
            size: 16,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            PeriodicUpdateService.nextUpdateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
