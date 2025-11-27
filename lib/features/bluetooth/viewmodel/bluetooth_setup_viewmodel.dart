import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:aquacare_v5/core/services/bluetooth_service.dart';

class BluetoothSetupState {
  final String statusMessage;
  final bool isScanning;
  final bool isConnected;
  final List<blue.BluetoothDevice> devices;
  final AsyncValue<void> sendingState;

  BluetoothSetupState({
    required this.statusMessage,
    required this.isScanning,
    required this.isConnected,
    required this.devices,
    required this.sendingState,
  });

  BluetoothSetupState copyWith({
    String? statusMessage,
    bool? isScanning,
    bool? isConnected,
    List<blue.BluetoothDevice>? devices,
    AsyncValue<void>? sendingState,
  }) {
    return BluetoothSetupState(
      statusMessage: statusMessage ?? this.statusMessage,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      devices: devices ?? this.devices,
      sendingState: sendingState ?? this.sendingState,
    );
  }

  factory BluetoothSetupState.initial() => BluetoothSetupState(
    statusMessage: 'Initializing Bluetooth...',
    isScanning: false,
    isConnected: false,
    devices: const [],
    sendingState: const AsyncData(null),
  );
}

class BluetoothSetupViewModel extends StateNotifier<BluetoothSetupState> {
  BluetoothSetupViewModel(this._service) : super(BluetoothSetupState.initial());

  final BluetoothService _service;

  StreamSubscription<List<blue.BluetoothDevice>>? _devicesSub;
  StreamSubscription<blue.BluetoothConnectionState>? _connSub;
  StreamSubscription<String>? _statusSub;

  Future<void> initialize() async {
    final ok = await _service.initialize();
    state = state.copyWith(
      statusMessage:
          ok
              ? 'Bluetooth initialized. Tap "Scan for TankPi" to find devices.'
              : 'Failed to initialize Bluetooth. Please check permissions.',
    );
    _bindStreams();
  }

  void _bindStreams() {
    _devicesSub?.cancel();
    _connSub?.cancel();
    _statusSub?.cancel();

    _devicesSub = _service.devicesStream.listen((devices) {
      state = state.copyWith(devices: List.unmodifiable(devices));
    });
    _connSub = _service.connectionStream.listen((conn) {
      state = state.copyWith(
        isConnected: conn == blue.BluetoothConnectionState.connected,
      );
    });
    _statusSub = _service.statusStream.listen((msg) {
      state = state.copyWith(statusMessage: msg);
    });
  }

  Future<void> startScan() async {
    if (state.isScanning) return;
    state = state.copyWith(
      isScanning: true,
      statusMessage:
          'Scanning for devices... (Ensure that the device is powered on and advertising)',
    );
    // Run scan asynchronously to avoid blocking UI thread
    try {
      await _service.startScan();
      // Wait a bit for devices to be discovered via stream
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(isScanning: false);
      if (state.devices.isEmpty) {
        state = state.copyWith(
          statusMessage:
              'No devices found. Ensure TankPi is powered and advertising.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        statusMessage: 'Scan error: $e',
      );
    }
  }

  Future<bool> connect(blue.BluetoothDevice device) async {
    try {
      final ok = await _service.connectToDevice(device);
      if (!ok) {
        state = state.copyWith(statusMessage: 'Failed to connect to device');
      }
      return ok;
    } catch (e) {
      // Handle PlatformException when bluetooth is turned off
      if (e.toString().contains('Bluetooth must be turned on')) {
        state = state.copyWith(
          statusMessage: 'Bluetooth must be turned on to connect',
          isConnected: false,
        );
      } else {
        state = state.copyWith(
          statusMessage: 'Connection error: $e',
          isConnected: false,
        );
      }
      return false;
    }
  }

  void disconnect() {
    _service.disconnect();
    state = state.copyWith(
      isConnected: false,
      statusMessage: 'Disconnected from TankPi device',
    );
  }

  Future<void> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    state = state.copyWith(sendingState: const AsyncLoading());
    try {
      // Create JSON string
      final jsonPayload = jsonEncode({'ssid': ssid, 'password': password});

      // Pass JSON string to service
      final ok = await _service.sendRawData(jsonPayload);

      if (!ok) throw Exception('BLE write failed');
      state = state.copyWith(
        sendingState: const AsyncData(null),
        statusMessage: 'WiFi configuration sent to TankPi!',
      );
    } catch (e) {
      state = state.copyWith(
        sendingState: AsyncError(e, StackTrace.current),
        statusMessage: 'Failed to send WiFi configuration',
      );
    }
  }

  @override
  void dispose() {
    _devicesSub?.cancel();
    _connSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}

final bluetoothSetupViewModelProvider =
    StateNotifierProvider<BluetoothSetupViewModel, BluetoothSetupState>((ref) {
      return BluetoothSetupViewModel(BluetoothService.instance);
    });
