import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

/// Singleton Connectivity Service
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final connectivity.Connectivity _conn = connectivity.Connectivity();
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<connectivity.ConnectivityResult>>? _sub;

  /// Public stream for online/offline changes
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Initialize once at app startup (e.g., in main())
  Future<void> initialize() async {
    final initial = await _conn.checkConnectivity();
    _onlineController.add(!_isNone(initial));

    _sub = _conn.onConnectivityChanged.listen((results) {
      _onlineController.add(!_isNone(results));
    });
  }

  bool _isNone(dynamic results) {
    if (results is List<connectivity.ConnectivityResult>) {
      return results.isEmpty ||
          results.contains(connectivity.ConnectivityResult.none);
    }
    if (results is connectivity.ConnectivityResult) {
      return results == connectivity.ConnectivityResult.none;
    }
    return true;
  }

  /// One-time connectivity check
  Future<bool> isOnline() async {
    final res = await _conn.checkConnectivity();
    return !_isNone(res);
  }

  void dispose() {
    _sub?.cancel();
    _onlineController.close();
  }
}
