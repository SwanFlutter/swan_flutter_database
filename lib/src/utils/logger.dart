enum LogLevel { debug, info, warning, error }

class Logger {
  final LogLevel minLevel;

  Logger({this.minLevel = LogLevel.info});

  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    if (level.index >= minLevel.index) {
      print('${DateTime.now()} [$level] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
