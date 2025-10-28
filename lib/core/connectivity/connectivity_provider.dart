import 'package:aquacare_v5/core/services/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StreamProvider that exposes ConnectivityService’s onlineStream
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  // Make sure the service is initialized
  await ConnectivityService.instance.initialize();

  // When the provider is disposed, also clean up the service
  ref.onDispose(() {
    ConnectivityService.instance.dispose();
  });

  // Expose the service stream to Riverpod
  yield* ConnectivityService.instance.onlineStream;
});

/// Derived provider: returns true if offline, false if online
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref
      .watch(connectivityStreamProvider)
      .maybeWhen(
        data: (isOnline) => !isOnline,
        orElse: () => true, // Default to offline if unknown
      );
  return status;
});
