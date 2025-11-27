import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/bluetooth_setup_viewmodel.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:aquacare_v5/utils/theme.dart';
import 'package:aquacare_v5/core/navigation/route_observer.dart';

class BluetoothSetupPage extends ConsumerStatefulWidget {
  const BluetoothSetupPage({super.key});

  @override
  ConsumerState<BluetoothSetupPage> createState() => _BluetoothSetupPageState();
}

class _BluetoothSetupPageState extends ConsumerState<BluetoothSetupPage> with RouteAware {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _ssidFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  StreamSubscription<List<blue.BluetoothDevice>>?
  _devicesSub; // deprecated usage, kept to avoid sudden removal
  StreamSubscription<blue.BluetoothConnectionState>?
  _connSub; // deprecated usage
  StreamSubscription<String>? _statusSub; // deprecated usage

  StreamSubscription<blue.BluetoothAdapterState>? _adapterStateSub;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _monitorBluetoothState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    _ssidFocusNode.addListener(() {
      if (_ssidFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPop() {
    // Disconnect when leaving the page
    ref.read(bluetoothSetupViewModelProvider.notifier).disconnect();
  }

  void _initializeBluetooth() async {
    await ref.read(bluetoothSetupViewModelProvider.notifier).initialize();
  }

  void _monitorBluetoothState() {
    // Monitor bluetooth adapter state changes
    _adapterStateSub = blue.FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      
      final vm = ref.read(bluetoothSetupViewModelProvider);
      // If bluetooth is turned off while connected, show message to user
      if (state != blue.BluetoothAdapterState.on && vm.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth was turned off. Please turn it back on to maintain connection.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        // Disconnect since bluetooth is off
        ref.read(bluetoothSetupViewModelProvider.notifier).disconnect();
      }
    });
  }

  @override
    void dispose() {
      appRouteObserver.unsubscribe(this);
      _adapterStateSub?.cancel();
      _ssidController.dispose();
      _passwordController.dispose();
      _scrollController.dispose();
      _ssidFocusNode.dispose();
      _passwordFocusNode.dispose();
      _devicesSub?.cancel();
      _connSub?.cancel();
      _statusSub?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(bluetoothSetupViewModelProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? darkTheme.colorScheme.background : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDark ? darkTheme.appBarTheme.backgroundColor : Colors.blue[600],
        title: Text(
          'TankPi Setup',
          style: TextStyle(
            color:
                isDark
                    ? darkTheme.appBarTheme.titleTextStyle?.color
                    : lightTheme.appBarTheme.titleTextStyle?.color,
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context),
          vertical: ResponsiveHelper.verticalPadding(context),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Status Card
              Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? darkTheme.colorScheme.surface : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? darkTheme.appBarTheme.foregroundColor!
                          : Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bluetooth, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark
                                  ? darkTheme.textTheme.bodyLarge?.color
                                  : Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark
                              ? darkTheme.textTheme.bodyLarge?.color
                              : Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scan Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: vm.isScanning ? null : _startScan,
                icon:
                    vm.isScanning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.search),
                label: Text(
                  vm.isScanning ? 'Scanning...' : 'Scan for TankPi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark
                          ? darkTheme.appBarTheme.backgroundColor
                          : Colors.blue[600],
                  foregroundColor:
                      isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Discovered Devices
            if (vm.devices.isNotEmpty) ...[
              Text(
                'Found Devices:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? darkTheme.colorScheme.onSurface
                          : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: RepaintBoundary(
                  child: ListView.builder(
                    cacheExtent: 600.0,
                    itemCount: vm.devices.length,
                    itemBuilder: (context, index) {
                      final device = vm.devices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isDark ? darkTheme.colorScheme.surface : Colors.blue[50],
                        child: ListTile(
                          leading: Icon(
                            Icons.bluetooth_connected,
                            size: 50,
                            color:Colors.blue[600],
                          ),
                          title: Text(
                            device.platformName.isNotEmpty
                                ? device.platformName
                                : 'Unknown Device',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ID: ${device.remoteId}'),
                          trailing: ElevatedButton(
                            onPressed:
                                vm.isConnected
                                    ? null
                                    : () => _connectToDevice(device),
                            child: Text(
                              style: TextStyle(
                                color: isDark
                                    ? darkTheme.textTheme.bodyLarge?.color
                                    : Colors.white,
                              ),
                                vm.isConnected ? 'Connected' : 'Connect',
                              ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // WiFi Configuration (shown when connected)
            if (vm.isConnected) ...[
              const SizedBox(height: 20),
              Text(
                'WiFi Configuration:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 12),

              // Aquarium ID removed (Pi stores it)

              // WiFi SSID
              TextField(
                controller: _ssidController,
                focusNode: _ssidFocusNode,
                decoration: const InputDecoration(
                  labelText: 'WiFi Network Name (SSID)',
                  hintText: 'Enter your WiFi network name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // WiFi Password
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                decoration: const InputDecoration(
                  labelText: 'WiFi Password',
                  hintText: 'Enter your WiFi password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Send Configuration Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      vm.sendingState is AsyncLoading
                          ? null
                          : _sendWifiConfiguration,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Send Configuration to TankPi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ],
            ),
          ),
        ),
      ),
    );
  }

  void _startScan() {
    ref.read(bluetoothSetupViewModelProvider.notifier).startScan();
  }

  void _connectToDevice(blue.BluetoothDevice device) async {
    final success = await ref
        .read(bluetoothSetupViewModelProvider.notifier)
        .connect(device);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.platformName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to the Aquacare device'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendWifiConfiguration() async {
    if (_ssidController.text.isEmpty || _passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in SSID and Password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await ref
        .read(bluetoothSetupViewModelProvider.notifier)
        .sendWifiCredentials(
          ssid: _ssidController.text,
          password: _passwordController.text,
        );

    final sending = ref.read(bluetoothSetupViewModelProvider).sendingState;
    if (sending is AsyncData) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'WiFi configuration sent successfully! TankPi will connect to your network.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      // Clear form
      _ssidController.clear();
      _passwordController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send WiFi configuration'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

