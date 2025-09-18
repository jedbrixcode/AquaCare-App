import 'dart:async';

// Floor setup will be added here. This is a scaffold with clear APIs to use across ViewModels.

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  // Initialize database (Floor) once ready
  Future<void> initialize() async {
    // TODO: Build and open Floor database, DAOs, migrations
  }

  // Latest sensor values per aquarium
  Future<void> cacheLatestSensors({
    required String aquariumId,
    required double temperature,
    required double ph,
    required double turbidity,
    required int timestampMs,
  }) async {
    // TODO: Upsert into latest table
  }

  // Hourly logs
  Future<void> cacheHourlyLog({
    required String aquariumId,
    required int hourIndex,
    required double temperature,
    required double ph,
    required double turbidity,
  }) async {
    // TODO: Upsert into hourly table
  }

  // Daily/weekly averages
  Future<void> cacheAverage({
    required String aquariumId,
    required int dayIndex,
    required double temperature,
    required double ph,
    required double turbidity,
  }) async {
    // TODO: Upsert into averages table
  }

  // Readers
  Future<Map<String, dynamic>?> getLatestSensors(String aquariumId) async {
    // TODO: Query latest sensors table
    return null;
  }

  Future<List<Map<String, dynamic>>> getHourlyLogs(String aquariumId) async {
    // TODO: Query hourly table by aquariumId
    return const [];
  }

  Future<List<Map<String, dynamic>>> getAverages(String aquariumId) async {
    // TODO: Query averages table by aquariumId
    return const [];
  }
}
