import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static BluetoothService? _instance;
  static BluetoothService get instance => _instance ??= BluetoothService._();

  BluetoothService._();

  blue.BluetoothAdapterState _adapterState = blue.BluetoothAdapterState.unknown;
  final List<blue.BluetoothDevice> _discoveredDevices = [];
  blue.BluetoothDevice? _connectedDevice;
  blue.BluetoothCharacteristic? _wifiCharacteristic;
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

  /// Initialize Bluetooth service
  Future<bool> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Listen to adapter state changes
      blue.FlutterBluePlus.adapterState.listen((state) {
        _adapterState = state;
        _statusController.add('Bluetooth adapter state: $state');
      });

      // Prompt to enable BT if off (shows system dialog on Android)
      try {
        await blue.FlutterBluePlus.turnOn();
      } catch (_) {}

      // Wait for a definite adapter state (avoid unknown)
      _adapterState = await blue.FlutterBluePlus.adapterState.firstWhere(
        (s) => s != blue.BluetoothAdapterState.unknown,
        orElse: () => blue.BluetoothAdapterState.off,
      );

      // Check if Bluetooth is available
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

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();
  }

  /// Start scanning for TankPi devices
  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);
      _isScanning = true;
      _statusController.add('Scanning for TankPi devices...');

      // Start scan with timeout
      await blue.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [], // Scan for all devices
      );

      // Listen to scan results
      blue.FlutterBluePlus.scanResults.listen((results) {
        for (blue.ScanResult result in results) {
          // Filter for TankPi devices (you can customize this filter)
          if (result.device.platformName.isNotEmpty &&
              result.device.platformName.toLowerCase().contains('tankpi')) {
            if (!_discoveredDevices.any(
              (device) => device.remoteId == result.device.remoteId,
            )) {
              _discoveredDevices.add(result.device);
              _devicesController.add(_discoveredDevices);
            }
          }
        }
      });

      // Stop scan after timeout
      Timer(const Duration(seconds: 10), () {
        stopScan();
      });
    } catch (e) {
      _statusController.add('Error starting scan: $e');
      _isScanning = false;
    }
  }

  /// Stop scanning
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

  /// Connect to a TankPi device
  Future<bool> connectToDevice(blue.BluetoothDevice device) async {
    try {
      _statusController.add('Connecting to ${device.platformName}...');

      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;
      _isConnected = true;
      _connectionController.add(blue.BluetoothConnectionState.connected);
      _statusController.add('Connected to ${device.platformName}');

      // Discover services
      List<blue.BluetoothService> services = await device.discoverServices();

      // Look for WiFi configuration service
      for (blue.BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains('wifi') ||
            service.uuid.toString().toLowerCase().contains('config')) {
          for (blue.BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.properties.write) {
              _wifiCharacteristic = characteristic;
              _statusController.add('Found WiFi configuration service');
              break;
            }
          }
        }
      }

      // Listen to connection state changes
      device.connectionState.listen((state) {
        _connectionController.add(state);
        if (state == blue.BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _wifiCharacteristic = null;
          _statusController.add('Disconnected from TankPi device');
        }
      });

      return true;
    } catch (e) {
      _statusController.add('Error connecting to device: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Send WiFi credentials to TankPi
  Future<bool> sendWifiCredentials({
    required String ssid,
    required String password,
    required String aquariumId,
  }) async {
    if (!_isConnected || _wifiCharacteristic == null) {
      _statusController.add('Not connected to TankPi device');
      return false;
    }

    try {
      final wifiConfig = {
        'ssid': ssid,
        'password': password,
        'aquarium_id': aquariumId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final data = utf8.encode(jsonEncode(wifiConfig));
      await _wifiCharacteristic!.write(data);

      _statusController.add('WiFi credentials sent to TankPi');
      return true;
    } catch (e) {
      _statusController.add('Error sending WiFi credentials: $e');
      return false;
    }
  }

  /// Disconnect from current device
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

  /// Dispose resources
  void dispose() {
    disconnect();
    _devicesController.close();
    _connectionController.close();
    _statusController.close();
  }
}
