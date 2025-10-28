import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show License;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static BluetoothService? _instance;
  static BluetoothService get instance => _instance ??= BluetoothService._();

  BluetoothService._();

  // Fixed UUIDs for WiFi Configuration
  // Note: Service UUID kept here for potential filtering; not required at runtime.
  // final blue.Guid _serviceUuid = blue.Guid('12345678-1234-5678-1234-56789abcdef0');
  final blue.Guid _characteristicUuid = blue.Guid(
    '12345678-1234-5678-1234-56789abcdef1',
  );

  blue.BluetoothAdapterState _adapterState = blue.BluetoothAdapterState.unknown;
  final List<blue.BluetoothDevice> _discoveredDevices = [];
  blue.BluetoothDevice? _connectedDevice;
  blue.BluetoothCharacteristic? _wifiCharacteristic;
  blue.BluetoothCharacteristic? _notifyCharacteristic;
  bool _isScanning = false;
  bool _isConnected = false;

  // Stream controllers for UI updates
  final StreamController<List<blue.BluetoothDevice>> _devicesController =
      StreamController<List<blue.BluetoothDevice>>.broadcast();
  final StreamController<blue.BluetoothConnectionState> _connectionController =
      StreamController<blue.BluetoothConnectionState>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<blue.BluetoothDevice> get discoveredDevices => _discoveredDevices;
  blue.BluetoothDevice? get connectedDevice => _connectedDevice;

  // Streams
  Stream<List<blue.BluetoothDevice>> get devicesStream =>
      _devicesController.stream;
  Stream<blue.BluetoothConnectionState> get connectionStream =>
      _connectionController.stream;
  Stream<String> get statusStream => _statusController.stream;

  // Initialization
  Future<bool> initialize() async {
    try {
      await _requestPermissions();

      // Listen to Bluetooth adapter state
      blue.FlutterBluePlus.adapterState.listen((state) {
        _adapterState = state;
        _statusController.add('Bluetooth adapter state: $state');
      });

      try {
        await blue.FlutterBluePlus.turnOn();
      } catch (_) {}

      _adapterState = await blue.FlutterBluePlus.adapterState.firstWhere(
        (s) => s != blue.BluetoothAdapterState.unknown,
        orElse: () => blue.BluetoothAdapterState.off,
      );

      if (_adapterState != blue.BluetoothAdapterState.on) {
        _statusController.add('Bluetooth is off. Please enable it.');
        return false;
      }

      _statusController.add('Bluetooth service initialized');
      return true;
    } catch (e) {
      _statusController.add('Error initializing Bluetooth: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();
  }

  // Scanning
  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);
      _isScanning = true;
      _statusController.add('Scanning for TankPi devices...');

      await blue.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [], // or [_serviceUuid] if you want specific
      );

      blue.FlutterBluePlus.scanResults.listen((results) {
        for (blue.ScanResult result in results) {
          if (!_discoveredDevices.any(
            (device) => device.remoteId == result.device.remoteId,
          )) {
            _discoveredDevices.add(result.device);
            _devicesController.add(_discoveredDevices);
          }
        }
      });

      Timer(const Duration(seconds: 10), stopScan);
    } catch (e) {
      _statusController.add('Error starting scan: $e');
      _isScanning = false;
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await blue.FlutterBluePlus.stopScan();
      _isScanning = false;
      _statusController.add(
        'Scan stopped. Found ${_discoveredDevices.length} TankPi devices',
      );
    } catch (e) {
      _statusController.add('Error stopping scan: $e');
    }
  }

  // Connection
  Future<bool> connectToDevice(blue.BluetoothDevice device) async {
    try {
      _statusController.add('Connecting to ${device.platformName}...');

      await device.connect(
        timeout: const Duration(seconds: 15),
        license: License.free,
      );
      _connectedDevice = device;
      _isConnected = true;
      _connectionController.add(blue.BluetoothConnectionState.connected);
      _statusController.add('Connected to ${device.platformName}');

      List<blue.BluetoothService> services = await device.discoverServices();

      // Find target service and characteristic by UUID
      for (blue.BluetoothService service in services) {
        // debug: log service uuid
        _statusController.add('Service discovered: ${service.uuid}');
        for (blue.BluetoothCharacteristic c in service.characteristics) {
          // debug: log characteristic + properties
          _statusController.add(
            '  Char: ${c.uuid} props -> write:${c.properties.write} writeWithoutResponse:${c.properties.writeWithoutResponse} read:${c.properties.read}',
          );

          // Accept either write-with-response OR write-without-response
          if (c.uuid == _characteristicUuid &&
              (c.properties.write || c.properties.writeWithoutResponse)) {
            _wifiCharacteristic = c;
            _statusController.add('Found WiFi configuration characteristic');
            break;
          }
          // If Pi exposes the same UUID with notify later, subscribe to it
          if (c.uuid == _characteristicUuid && c.properties.notify) {
            _notifyCharacteristic = c;
          }
        }
        if (_wifiCharacteristic != null) break;
      }

      if (_wifiCharacteristic == null) {
        _statusController.add(
          'WiFi configuration characteristic not found. Check UUIDs.',
        );
      }

      // Try enable notifications for confirmation if available
      if (_notifyCharacteristic != null) {
        try {
          await _notifyCharacteristic!.setNotifyValue(true);
          _notifyCharacteristic!.onValueReceived.listen((data) {
            try {
              final text = utf8.decode(data);
              _statusController.add('TankPi notify: $text');
            } catch (_) {}
          });
        } catch (_) {}
      }

      // Listen for disconnects & auto-reconnect
      device.connectionState.listen((state) async {
        _connectionController.add(state);
        if (state == blue.BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _wifiCharacteristic = null;
          _statusController.add('Disconnected from TankPi device');

          // Optional auto-reconnect logic
          await Future.delayed(const Duration(seconds: 3));
          try {
            _statusController.add('Attempting to reconnect...');
            await device.connect(license: License.free);
            _isConnected = true;
            _statusController.add('Reconnected to ${device.platformName}');
          } catch (e) {
            _statusController.add('Reconnect failed: $e');
          }
        }
      });

      return _wifiCharacteristic != null;
    } catch (e) {
      _statusController.add('Error connecting to device: $e');
      _isConnected = false;
      return false;
    }
  }

  // Send Raw Data, manual JSON payloads
  Future<bool> sendRawData(String jsonData) async {
    if (!_isConnected || _wifiCharacteristic == null) {
      _statusController.add('Not connected to any TankPi device');
      return false;
    }
    try {
      final data = utf8.encode(jsonData);
      await _writeInChunks(data);
      _statusController.add('Raw JSON data sent successfully');
      return true;
    } catch (e) {
      _statusController.add('Error sending raw data: $e');
      return false;
    }
  }

  // WiFi Credentials Sending
  Future<bool> sendWifiCredentials({
    required String ssid,
    required String password,
    String? aquariumId,
  }) async {
    if (!_isConnected || _wifiCharacteristic == null) {
      _statusController.add('Not connected to TankPi device');
      return false;
    }

    try {
      // Must match Pi expectation strictly: {"ssid":"...","password":"..."}
      final payload = jsonEncode({'ssid': ssid, 'password': password});
      final data = utf8.encode(payload);
      await _writeInChunks(data);

      // Read confirmation response to show to user
      try {
        final response = await _wifiCharacteristic!.read();
        _statusController.add('TankPi response: ${utf8.decode(response)}');
      } catch (_) {}

      _statusController.add('WiFi credentials sent to TankPi');
      return true;
    } catch (e) {
      _statusController.add('Error sending WiFi credentials: $e');
      return false;
    }
  }

  // Chunk Writer (safe for long JSON)
  Future<void> _writeInChunks(List<int> data) async {
    const int chunkSize = 20;
    for (int i = 0; i < data.length; i += chunkSize) {
      int end = (i + chunkSize > data.length) ? data.length : i + chunkSize;
      List<int> chunk = data.sublist(i, end);
      await _wifiCharacteristic!.write(chunk, withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // Disconnect / Dispose
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        _statusController.add('Error disconnecting: $e');
      }
    }
    _isConnected = false;
    _connectedDevice = null;
    _wifiCharacteristic = null;
  }

  void dispose() {
    disconnect();
    _devicesController.close();
    _connectionController.close();
    _statusController.close();
  }
}
