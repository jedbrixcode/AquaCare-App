import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final connectivity.Connectivity _conn = connectivity.Connectivity();
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();
  StreamSubscription<List<connectivity.ConnectivityResult>>? _sub;

  Stream<bool> get onlineStream => _onlineController.stream;

  Future<void> initialize() async {
    // Emit initial
    final initial = await _conn.checkConnectivity();
    _onlineController.add(!_isNone(initial));
    // Listen live (v4+ emits List<ConnectivityResult>)
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

  Future<bool> isOnline() async {
    final res = await _conn.checkConnectivity();
    return !_isNone(res);
  }

  void dispose() {
    _sub?.cancel();
    _onlineController.close();
  }
}
