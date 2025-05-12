// lib/utils/logger.dart

enum LogLevel {
  debug,
  info,
  warning,
  error
}

class Logger {
  static LogLevel _logLevel = LogLevel.info;
  final String _tag;

  // Constructor that requires a tag for context
  Logger(this._tag);

  // Set global log level
  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  // Debug level logs - most verbose
  void debug(String message) {
    if (_logLevel.index <= LogLevel.debug.index) {
      _log('🔍 DEBUG', message);
    }
  }

  // Info level logs - general information
  void info(String message) {
    if (_logLevel.index <= LogLevel.info.index) {
      _log('ℹ️ INFO', message);
    }
  }

  // Warning level logs - potential issues
  void warning(String message) {
    if (_logLevel.index <= LogLevel.warning.index) {
      _log('⚠️ WARNING', message);
    }
  }

  // Error level logs - definite problems
  void error(String message) {
    if (_logLevel.index <= LogLevel.error.index) {
      _log('❌ ERROR', message);
    }
  }

  // Internal logging method
  void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] $level [$_tag] $message');
  }

  // Additional utility methods

  // Log method entry with parameters
  void logMethodEntry(String methodName, [Map<String, dynamic>? params]) {
    if (_logLevel.index <= LogLevel.debug.index) {
      final paramsStr = params != null ? ', params: $params' : '';
      debug('Entering $methodName$paramsStr');
    }
  }

  // Log method exit with optional return value
  void logMethodExit(String methodName, [dynamic returnValue]) {
    if (_logLevel.index <= LogLevel.debug.index) {
      final returnStr = returnValue != null ? ' → returned: $returnValue' : '';
      debug('Exiting $methodName$returnStr');
    }
  }

  // Log API call attempts
  void logApiCall(String endpoint, String method, [Map<String, dynamic>? params]) {
    if (_logLevel.index <= LogLevel.debug.index) {
      final paramsStr = params != null ? ', body: $params' : '';
      debug('API $method → $endpoint$paramsStr');
    }
  }

  // Log API response
  void logApiResponse(String endpoint, int statusCode, dynamic data) {
    if (_logLevel.index <= LogLevel.debug.index) {
      // Truncate large responses
      final dataStr = _formatData(data);
      debug('API ← $endpoint (HTTP $statusCode): $dataStr');
    }
  }

  // Format data for logging, truncating large objects
  String _formatData(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      if (data.length > 10) {
        return '{Map with ${data.length} entries}';
      }

      final formattedEntries = data.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is String && value.length > 100) {
          return '$key: "${value.substring(0, 97)}..."';
        } else if (value is List) {
          return '$key: [List with ${value.length} items]';
        } else {
          return '$key: $value';
        }
      }).join(', ');

      return '{$formattedEntries}';
    }

    if (data is List) {
      if (data.length > 10) {
        return '[List with ${data.length} items]';
      }
      return data.toString();
    }

    if (data is String && data.length > 500) {
      return '"${data.substring(0, 100)}..." [${data.length} chars]';
    }

    return data.toString();
  }
}