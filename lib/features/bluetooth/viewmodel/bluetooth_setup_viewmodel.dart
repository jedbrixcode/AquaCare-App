import 'dart:async';
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
      statusMessage: 'Scanning for TankPi devices...',
    );
    await _service.startScan();
    state = state.copyWith(isScanning: false);
    if (state.devices.isEmpty) {
      state = state.copyWith(
        statusMessage:
            'No devices found. Ensure TankPi is powered and advertising.',
      );
    }
  }

  Future<bool> connect(blue.BluetoothDevice device) async {
    final ok = await _service.connectToDevice(device);
    if (!ok) {
      state = state.copyWith(statusMessage: 'Failed to connect to device');
    }
    return ok;
  }

  Future<void> sendWifiCredentials({
    required String ssid,
    required String password,
    String? aquariumId,
  }) async {
    state = state.copyWith(sendingState: const AsyncLoading());
    try {
      final ok = await _service.sendWifiCredentials(
        ssid: ssid,
        password: password,
        aquariumId: aquariumId,
      );
      if (!ok) throw Exception('BLE write failed');
      state = state.copyWith(
        sendingState: const AsyncData(null),
        statusMessage: 'WiFi credentials sent to TankPi',
      );
    } catch (e) {
      state = state.copyWith(
        sendingState: AsyncError(e, StackTrace.current),
        statusMessage: 'Failed to send WiFi credentials',
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
