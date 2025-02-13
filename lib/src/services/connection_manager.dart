import 'dart:async';
import 'dart:io';

class ConnectionManager {
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Timer? _timer;

  Stream<bool> get connectionStream => _connectionController.stream;

  void startMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 30), (_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _connectionController.add(result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } catch (_) {
      _connectionController.add(false);
    }
  }

  void dispose() {
    _timer?.cancel();
    _connectionController.close();
  }
}
