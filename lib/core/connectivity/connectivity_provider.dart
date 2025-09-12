import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final status = ref
      .watch(connectivityStreamProvider)
      .maybeWhen(data: (s) => s, orElse: () => ConnectivityResult.none);
  return status == ConnectivityResult.none;
});
