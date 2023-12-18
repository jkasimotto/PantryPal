import 'dart:developer' as developer;

// File: lib/services/logger.dart
class Logger {
  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    developer.log('$timestamp: $message');
  }
}