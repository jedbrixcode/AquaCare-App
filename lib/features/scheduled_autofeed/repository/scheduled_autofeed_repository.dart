import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aquacare_v5/core/config/backend_config.dart';
import '../models/feeding_schedule_model.dart';

class ScheduledAutofeedRepository {
  final String baseUrl = BackendConfig.baseUrl;

  // Get all feeding schedules for an aquarium
  Future<List<FeedingSchedule>> getFeedingSchedules(String aquariumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/aquarium/$aquariumId/feeding_schedules'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FeedingSchedule.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load feeding schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching feeding schedules: $e');
    }
  }

  // Add a new feeding schedule
  Future<FeedingSchedule> addFeedingSchedule({
    required String aquariumId,
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aquarium/$aquariumId/feeding_schedules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'aquarium_id': aquariumId,
          'time': time,
          'cycles': cycles,
          'food_type': foodType,
          'is_enabled': isEnabled,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return FeedingSchedule.fromJson(data);
      } else {
        throw Exception(
          'Failed to add feeding schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error adding feeding schedule: $e');
    }
  }

  // Update an existing feeding schedule
  Future<FeedingSchedule> updateFeedingSchedule({
    required String aquariumId,
    required String scheduleId,
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/aquarium/$aquariumId/feeding_schedules/$scheduleId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'time': time,
          'cycles': cycles,
          'food_type': foodType,
          'is_enabled': isEnabled,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FeedingSchedule.fromJson(data);
      } else {
        throw Exception(
          'Failed to update feeding schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating feeding schedule: $e');
    }
  }

  // Delete a feeding schedule
  Future<void> deleteFeedingSchedule({
    required String aquariumId,
    required String scheduleId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/aquarium/$aquariumId/feeding_schedules/$scheduleId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete feeding schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting feeding schedule: $e');
    }
  }

  // Toggle a feeding schedule enabled/disabled
  Future<FeedingSchedule> toggleFeedingSchedule({
    required String aquariumId,
    required String scheduleId,
    required bool isEnabled,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/aquarium/$aquariumId/feeding_schedules/$scheduleId/toggle',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_enabled': isEnabled}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FeedingSchedule.fromJson(data);
      } else {
        throw Exception(
          'Failed to toggle feeding schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error toggling feeding schedule: $e');
    }
  }

  // Get auto feeder status for an aquarium
  Future<AutoFeederStatus> getAutoFeederStatus(String aquariumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/aquarium/$aquariumId/auto_feeder/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AutoFeederStatus.fromJson(data);
      } else {
        throw Exception(
          'Failed to load auto feeder status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching auto feeder status: $e');
    }
  }

  // Toggle auto feeder enabled/disabled
  Future<AutoFeederStatus> toggleAutoFeeder({
    required String aquariumId,
    required bool isEnabled,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/aquarium/$aquariumId/auto_feeder/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'enabled': isEnabled}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AutoFeederStatus.fromJson(data);
      } else {
        throw Exception('Failed to toggle auto feeder: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling auto feeder: $e');
    }
  }
}
