import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';

import '../../aquarium/viewmodel/aquarium_dashboard_viewmodel.dart';

class SettingsState {
  final bool globalNotificationsEnabled;
  const SettingsState({required this.globalNotificationsEnabled});

  SettingsState copyWith({bool? globalNotificationsEnabled}) => SettingsState(
    globalNotificationsEnabled:
        globalNotificationsEnabled ?? this.globalNotificationsEnabled,
  );
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(this._repo)
    : super(const SettingsState(globalNotificationsEnabled: true));

  final AquariumRepository _repo;

  Future<void> toggleGlobalNotifications(bool enabled) async {
    state = state.copyWith(globalNotificationsEnabled: enabled);
    try {
      // Check if Firebase is initialized
      try {
        Firebase.app();
      } catch (_) {
        // Firebase not initialized - skip FCM operations
        await _repo.setAllAquariumNotifications(enabled: enabled);
        return;
      }
      
      // Try to access FirebaseMessaging - wrap in try-catch as it might throw
      try {
        if (enabled) {
          await FirebaseMessaging.instance.subscribeToTopic('aquacare_alerts');
        } else {
          await FirebaseMessaging.instance.unsubscribeFromTopic(
            'aquacare_alerts',
          );
        }
      } catch (e) {
        // FirebaseMessaging not available - continue without FCM
        // UI state is already updated, just update repo settings
      }
      
      await _repo.setAllAquariumNotifications(enabled: enabled);
    } catch (_) {
      // swallow; UI should already reflect latest desired state and repo will retry on next change
    }
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
      final repo = ref.watch(aquariumRepositoryProvider);
      return SettingsViewModel(repo);
    });
