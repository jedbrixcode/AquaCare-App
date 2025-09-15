import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

final connectivityStreamProvider =
    StreamProvider<List<connectivity.ConnectivityResult>>((ref) {
      final conn = connectivity.Connectivity();
      return conn.onConnectivityChanged;
    });

final isOfflineProvider = Provider<bool>((ref) {
  final status = ref
      .watch(connectivityStreamProvider)
      .maybeWhen(
        data:
            (results) =>
                results.isEmpty ||
                results.contains(connectivity.ConnectivityResult.none),
        orElse: () => true,
      );
  return status;
});
