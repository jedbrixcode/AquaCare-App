import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AutoFeedRepository {
  AutoFeedRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> toggleCamera({
    required String backendUrl,
    required String aquariumId,
    required bool on,
  }) async {
    final onParam = on ? 'True' : 'False';
    final url = Uri.parse(
      '$backendUrl/aquarium/$aquariumId/camera_switch/$onParam',
    );
    try {
      final resp = await _client.post(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Camera toggle request timed out');
        },
      );
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // Log error but don't throw - allow app to continue
        debugPrint('Camera toggle failed with HTTP ${resp.statusCode}');
        return false;
      }
      return true;
    } on SocketException catch (e) {
      // Handle connection errors including "Connection reset by peer"
      debugPrint('Camera connection failed: ${e.message} (${e.osError?.message ?? ''})');
      return false;
    } on http.ClientException catch (e) {
      // Handle HTTP client exceptions (often wraps SocketException)
      debugPrint('Camera client error: ${e.message}');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('Camera toggle timeout: ${e.message}');
      return false;
    } on HttpException catch (e) {
      debugPrint('Camera HTTP error: ${e.message}');
      return false;
    } on FormatException catch (e) {
      debugPrint('Camera format error: ${e.message}');
      return false;
    } catch (e) {
      // Catch any other exceptions to prevent app crash
      debugPrint('Camera error: $e');
      return false;
    }
  }

  Future<bool> connectFeeder({
    required String backendUrl,
    required String aquariumId,
  }) async {
    // WebSocket removed; treat connectivity as HTTP-only for now
    // Optionally, perform a lightweight HTTP check here if available
    return true;
  }

  bool get isWsConnected => true;

  Future<bool> startManualFeeding({
    required String backendUrl,
    required String aquariumId,
    required String food,
  }) async {
    try {
      final url = Uri.parse(
        '$backendUrl/aquarium/$aquariumId/manual/hold_feed',
      );
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'food': food}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopManualFeeding({
    required String backendUrl,
    required String aquariumId,
  }) async {
    // No explicit stop endpoint provided; treat release as client-side state only
    return true;
  }

  Future<bool> sendRotationFeeding({
    required String backendUrl,
    required String aquariumId,
    required int rotations,
    required String food,
  }) async {
    try {
      final url = Uri.parse(
        '$backendUrl/aquarium/$aquariumId/manual/cycle_feed',
      );
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'food': food, 'cycle': rotations.toString()}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  void disconnect() {}
}

class CameraState {
  final bool isCameraOn;

  CameraState({this.isCameraOn = false});

  CameraState copyWith({bool? isCameraOn}) {
    return CameraState(isCameraOn: isCameraOn ?? this.isCameraOn);
  }
}
