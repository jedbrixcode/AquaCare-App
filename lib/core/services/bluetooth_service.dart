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
  bool _wifiSupportsWrite = false;
  bool _wifiSupportsWriteWithoutResponse = false;
  bool _isScanning = false;
  bool _isConnected = false;
  StreamSubscription<blue.BluetoothAdapterState>? _adapterStateSub;

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
      _adapterStateSub?.cancel();
      _adapterStateSub = blue.FlutterBluePlus.adapterState.listen((state) {
        _adapterState = state;
        _statusController.add('Bluetooth adapter state: $state');
        // If bluetooth is turned off while connected, disconnect
        if (state != blue.BluetoothAdapterState.on && _isConnected) {
          _statusController.add('Bluetooth turned off, disconnecting...');
          disconnect();
        }
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
  StreamSubscription<List<blue.ScanResult>>? _scanSubscription;
  
  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);
      _isScanning = true;
      _statusController.add('Scanning for TankPi devices...');

      // Cancel previous subscription if exists
      await _scanSubscription?.cancel();
      
      // Start scan
      await blue.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [], // or [_serviceUuid] if you want specific
      );

      // Listen to scan results - filter devices with names only
      _scanSubscription = blue.FlutterBluePlus.scanResults.listen((results) {
        for (blue.ScanResult result in results) {
          // Only add devices that have a name (not empty)
          final deviceName = result.device.platformName;
          if (deviceName.isNotEmpty && 
              !_discoveredDevices.any(
                (device) => device.remoteId == result.device.remoteId,
              )) {
            _discoveredDevices.add(result.device);
            _devicesController.add(_discoveredDevices);
          }
        }
      });

      // Auto-stop after timeout
      Timer(const Duration(seconds: 10), () {
        stopScan();
      });
    } catch (e) {
      _statusController.add('Error starting scan: $e');
      _isScanning = false;
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await _scanSubscription?.cancel();
      await blue.FlutterBluePlus.stopScan();
      _isScanning = false;
      _statusController.add(
        'Scan stopped. Found ${_discoveredDevices.length} devices, please connect to TankPi Device',
      );
    } catch (e) {
      _statusController.add('Error stopping scan: $e');
      _isScanning = false;
    }
  }

  StreamSubscription<blue.BluetoothConnectionState>? _connectionStateSub;

  // Connection
  Future<bool> connectToDevice(blue.BluetoothDevice device) async {
  try {
    // Ensure Bluetooth is ON
    final adapterState = await blue.FlutterBluePlus.adapterState.first;
    if (adapterState != blue.BluetoothAdapterState.on) {
      _statusController.add('Bluetooth must be turned on to connect');
      return false;
    }

    // Create a fresh device reference (VERY IMPORTANT)
    final cleanDevice = device;

    _statusController.add('Preparing device...');

    // Always stop scan before connecting
    await blue.FlutterBluePlus.stopScan();

    // Disconnect old connection cleanly
    try {
      await cleanDevice.disconnect();
    } catch (_) {}

    // Small delay — BLE NEEDS THIS
    await Future.delayed(const Duration(milliseconds: 800));

    _statusController.add('Connecting to ${device.platformName}...');

    // More stable: 30s timeout + no autoConnect
    await cleanDevice.connect(
      timeout: const Duration(seconds: 30),
      autoConnect: false,
      license: License.free,
    );

    _connectedDevice = cleanDevice;
    _isConnected = true;
    _connectionController.add(blue.BluetoothConnectionState.connected);
    _statusController.add('Connected to ${device.platformName}');

    // discover services
    final services = await cleanDevice.discoverServices();

    for (blue.BluetoothService service in services) {
      _statusController.add('Service discovered: ${service.uuid}');

      for (blue.BluetoothCharacteristic c in service.characteristics) {
        _statusController.add(
          '  Char: ${c.uuid} props -> write:${c.properties.write} '
          'writeWithoutResponse:${c.properties.writeWithoutResponse} '
          'read:${c.properties.read} notify:${c.properties.notify}',
        );

        final isWifiCharacteristic = c.uuid == _characteristicUuid;
        final supportsWrite = c.properties.write;
        final supportsWriteWithoutResponse = c.properties.writeWithoutResponse;

        if (isWifiCharacteristic &&
            (supportsWrite || supportsWriteWithoutResponse)) {
          _wifiCharacteristic = c;
          _wifiSupportsWrite = supportsWrite;
          _wifiSupportsWriteWithoutResponse = supportsWriteWithoutResponse;
        }

        if (isWifiCharacteristic && c.properties.notify) {
          _notifyCharacteristic = c;
        }
      }
    }

    if (_wifiCharacteristic == null) {
      _statusController.add(
        'WiFi configuration characteristic NOT found. Check UUID.',
      );
      return false;
    }

    // Enable notifications if available
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

    // Listen for disconnects
    _connectionStateSub?.cancel();
    _connectionStateSub =
        cleanDevice.connectionState.listen((blue.BluetoothConnectionState s) {
      _connectionController.add(s);
      if (s == blue.BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _connectedDevice = null;
        _wifiCharacteristic = null;
        _notifyCharacteristic = null;
        _statusController.add('Disconnected from TankPi');
        _connectionStateSub?.cancel();
      }
    });

    return true;
  } catch (e) {
    _statusController.add('Error connecting to device: $e');
    _isConnected = false;
    _connectedDevice = null;
    return false;
  }
}

  // Send Raw Data, manual JSON payloads - sends whole JSON at once
  Future<bool> sendRawData(String jsonData) async {
    if (!_isConnected || _wifiCharacteristic == null) {
      _statusController.add('Not connected to any TankPi device');
      return false;
    }
    if (!_wifiSupportsWrite && !_wifiSupportsWriteWithoutResponse) {
      _statusController.add(
        'Selected characteristic does not support writing data. Please verify the UUID and permissions.',
      );
      return false;
    }
    try {
      final data = utf8.encode(jsonData);
      // Determine best write mode based on characteristic support
      final useWithoutResponse =
          !_wifiSupportsWrite && _wifiSupportsWriteWithoutResponse;

      // Send whole JSON at once, not in chunks
      await _wifiCharacteristic!.write(
        data,
        withoutResponse: useWithoutResponse,
      );
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
    if (!_wifiSupportsWrite && !_wifiSupportsWriteWithoutResponse) {
      _statusController.add(
        'Selected characteristic does not support writing data. Please verify the UUID and permissions.',
      );
      return false;
    }

    try {
      // Must match Pi expectation strictly: {"ssid":"...","password":"..."}
      final payload = jsonEncode({'ssid': ssid, 'password': password});
      final data = utf8.encode(payload);
      final useWithoutResponse =
          !_wifiSupportsWrite && _wifiSupportsWriteWithoutResponse;
      await _wifiCharacteristic!.write(
        data,
        withoutResponse: useWithoutResponse ? true : false,
      );

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


  // Disconnect / Dispose
  Future<void> disconnect() async {
    // Cancel connection state subscription
    await _connectionStateSub?.cancel();
    _connectionStateSub = null;
    
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore errors if bluetooth is off or already disconnected
        if (e.toString().contains('Bluetooth must be turned on')) {
          _statusController.add('Bluetooth is off, connection terminated');
        } else {
          _statusController.add('Error disconnecting: $e');
        }
      }
    }
    _isConnected = false;
    _connectedDevice = null;
    _wifiCharacteristic = null;
    _notifyCharacteristic = null;
    _wifiSupportsWrite = false;
    _wifiSupportsWriteWithoutResponse = false;
  }

  void dispose() {
    disconnect();
    _devicesController.close();
    _connectionController.close();
    _statusController.close();
  }
}
