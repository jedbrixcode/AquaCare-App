import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
// import 'package:collection/collection.dart';

import '../../scheduled_autofeed/models/one_time_schedule_model.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/models/one_time_schedule_cache.dart';

class FirestoreScheduleRepository {
  FirestoreScheduleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? _getFirestoreInstance();

  final FirebaseFirestore? _firestore;
  
  static FirebaseFirestore? _getFirestoreInstance() {
    try {
      Firebase.app(); // Check if Firebase is initialized
      return FirebaseFirestore.instance;
    } catch (_) {
      return null; // Firebase not initialized
    }
  }
  static const String _rootCollection = 'Schedules';
  static const int _pageSize = 20;

  Query<Map<String, dynamic>>? getSchedulesQuery(int aquariumId) {
    final firestore = _firestore;
    if (firestore == null) return null;
    return firestore
        .collection(_rootCollection)
        .where('aquarium_id', isEqualTo: aquariumId.toString())
        .limit(_pageSize);
  }

  Stream<List<OneTimeSchedule>> getOneTimeSchedules(int aquariumId) {
    final controller = StreamController<List<OneTimeSchedule>>.broadcast();

    // If Firebase is not initialized, return cached data
    if (_firestore == null) {
      getCachedSchedules(aquariumId).then((cached) {
        if (cached != null) {
          controller.add(cached);
        } else {
          controller.add([]);
        }
      });
      return controller.stream;
    }

    List<OneTimeSchedule> mapSnapshotToSchedules(
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      final items =
          snap.docs
              .map((d) => OneTimeSchedule.fromJson(d.data(), id: d.id))
              .where((s) => s.aquariumId == aquariumId)
              .toList()
            ..sort(
              (a, b) => (a.scheduledAtLocal ?? DateTime(0)).compareTo(
                b.scheduledAtLocal ?? DateTime(0),
              ),
            );
      return items;
    }

    // Safe to use _firestore here because we checked for null above
    // Dart flow analysis promotes _firestore to non-null after the check
    final firestore = _firestore;
    final numericQuery = firestore
        .collection(_rootCollection)
        .where('aquarium_id', isEqualTo: aquariumId);
    final stringQuery = firestore
        .collection(_rootCollection)
        .where('aquarium_id', isEqualTo: aquariumId.toString());

    StreamSubscription? numericSub;
    StreamSubscription? stringSub;

    numericSub = numericQuery.snapshots().listen(
      (snap) async {
        if (snap.docs.isNotEmpty) {
          final items = mapSnapshotToSchedules(snap);
          controller.add(items);
          // persist to local for offline-first
          unawaited(cacheSchedules(aquariumId, items));
          await stringSub?.cancel();
        } else {
          stringSub ??= stringQuery.snapshots().listen((snap2) {
            final items = mapSnapshotToSchedules(snap2);
            controller.add(items);
            unawaited(cacheSchedules(aquariumId, items));
          });
        }
      },
      onError: (e) async {
        stringSub ??= stringQuery.snapshots().listen((snap2) {
          final items = mapSnapshotToSchedules(snap2);
          controller.add(items);
          unawaited(cacheSchedules(aquariumId, items));
        });
      },
    );

    controller.onCancel = () async {
      await numericSub?.cancel();
      await stringSub?.cancel();
    };

    return controller.stream;
  }

  Future<void> cacheSchedules(
    int aquariumId,
    List<OneTimeSchedule> items,
  ) async {
    final isarItems =
        items
            .where((e) => e.aquariumId == aquariumId)
            .map(
              (e) =>
                  OneTimeScheduleCache()
                    ..aquariumId = aquariumId.toString()
                    ..documentId = e.id
                    ..scheduleTime = e.scheduleTime
                    ..cycle = e.cycle
                    ..food = e.food
                    ..status = e.status,
            )
            .toList();
    await LocalStorageService.instance.cacheOneTimeSchedules(
      aquariumId.toString(),
      isarItems,
    );
  }

  Future<List<OneTimeSchedule>?> getCachedSchedules(int aquariumId) async {
    final cached = await LocalStorageService.instance.getOneTimeSchedules(
      aquariumId.toString(),
    );
    if (cached.isEmpty) return null;
    return cached
        .map(
          (c) => OneTimeSchedule(
            id: c.documentId,
            aquariumId: int.tryParse(c.aquariumId) ?? 0,
            scheduleTime: c.scheduleTime,
            cycle: c.cycle,
            food: c.food,
            status: c.status,
          ),
        )
        .toList();
  }
}
