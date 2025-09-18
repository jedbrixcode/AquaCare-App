import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:aquacare_v5/features/aquarium/view/aquarium_detail_page.dart';
import 'package:aquacare_v5/features/bluetooth/view/bluetooth_setup_page.dart';
import 'package:aquacare_v5/features/bluetooth/viewmodel/bluetooth_setup_viewmodel.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/core/connectivity/connectivity_provider.dart';
import 'package:aquacare_v5/features/settings/viewmodel/theme_viewmodel.dart';

class AquariumDashboardPage extends ConsumerWidget {
  const AquariumDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(aquariumsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaCare Dashboard'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.color_lens, color: Colors.white),
            onSelected: (value) {
              final controller = ProviderScope.containerOf(
                context,
              ).read(themeModeProvider.notifier);
              if (value == 'light') controller.setThemeMode(ThemeMode.light);
              if (value == 'dark') controller.setThemeMode(ThemeMode.dark);
              if (value == 'system') controller.setThemeMode(ThemeMode.system);
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'light', child: Text('Light')),
                  PopupMenuItem(value: 'dark', child: Text('Dark')),
                  PopupMenuItem(value: 'system', child: Text('System')),
                ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 107, 159, 255),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                'AquaCare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Chat with AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Monitoring Graphs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/graphs');
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'TankPi Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BluetoothSetupPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Offline Banner
          Consumer(
            builder: (context, ref, child) {
              final isOffline = ref.watch(isOfflineProvider);
              if (isOffline) {
                return Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are currently offline. Some features may be limited.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Main Content
          Expanded(
            child: summaryAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No Aquariums Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Waiting for aquarium data...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Aquariums (${summaries.length})',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(aquariumsSummaryProvider);
                            try {
                              await ref.read(aquariumsSummaryProvider.future);
                            } catch (_) {}
                          },
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: summaries.length,
                            itemBuilder: (context, index) {
                              final s = summaries[index];
                              return _buildAquariumCard(context, s);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading aquariums',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(aquariumsSummaryProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFabActions(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateAquariumDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Aquarium'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Aquarium Name',
              hintText: 'Enter aquarium name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final controller = ProviderScope.containerOf(
                  context,
                ).read(aquariumDashboardControllerProvider.notifier);
                final ok = await controller.createAquarium(
                  nameController.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ProviderScope.containerOf(
                  context,
                ).invalidate(aquariumsSummaryProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Aquarium "${nameController.text}" created successfully!'
                          : 'Failed to create aquarium',
                    ),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showFabActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Create Aquarium'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCreateAquariumDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text('TankPi Setup (Bluetooth)'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BluetoothSetupPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAquariumOptionsDialog(BuildContext context, AquariumSummary s) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}'} Options',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.wifi),
                title: const Text('Change WiFi (Provision)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showChangeWifiDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Name'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditAquariumDialog(context, s);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showNotificationSettingsDialog(context, s);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Aquarium',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, s);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAquariumDialog(BuildContext context, AquariumSummary s) {
    final TextEditingController nameController = TextEditingController(
      text: s.name,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Aquarium Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Aquarium Name',
              hintText: 'Enter new name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final vm = ProviderScope.containerOf(
                    context,
                  ).read(aquariumDashboardViewModelProvider);

                  try {
                    // Check if name already exists (excluding current aquarium)
                    final nameExists = await vm.isAquariumNameExists(
                      nameController.text.trim(),
                      excludeId: s.aquariumId,
                    );
                    if (nameExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'An aquarium with this name already exists!',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Update aquarium name
                    await vm.updateAquariumName(
                      s.aquariumId,
                      nameController.text.trim(),
                    );
                    Navigator.of(context).pop();

                    // Refresh the provider to show updated name
                    ProviderScope.containerOf(
                      context,
                    ).refresh(aquariumsSummaryProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Aquarium renamed to "${nameController.text}" successfully!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating aquarium: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettingsDialog(
    BuildContext context,
    AquariumSummary s,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final notifAsync = ref.watch(
              aquariumNotificationProvider(s.aquariumId),
            );
            return notifAsync.when(
              data: (notif) {
                bool tempNotif = notif.temperature;
                bool phNotif = notif.ph;
                bool turbidityNotif = notif.turbidity;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Notification Settings'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: const Text('Temperature Alerts'),
                            value: tempNotif,
                            onChanged: (v) => setState(() => tempNotif = v),
                          ),
                          SwitchListTile(
                            title: const Text('pH Level Alerts'),
                            value: phNotif,
                            onChanged: (v) => setState(() => phNotif = v),
                          ),
                          SwitchListTile(
                            title: const Text('Turbidity Alerts'),
                            value: turbidityNotif,
                            onChanged:
                                (v) => setState(() => turbidityNotif = v),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final ctrl = ProviderScope.containerOf(
                              context,
                            ).read(
                              aquariumDashboardControllerProvider.notifier,
                            );
                            final ok = await ctrl.updateNotificationSettings(
                              s.aquariumId,
                              tempNotif,
                              turbidityNotif,
                              phNotif,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Notification settings updated successfully!'
                                      : 'Failed to update notification settings',
                                ),
                                backgroundColor: ok ? Colors.green : Colors.red,
                              ),
                            );
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
              loading:
                  () => const AlertDialog(
                    content: SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error:
                  (e, _) => AlertDialog(
                    title: const Text('Notification Settings'),
                    content: Text('Error loading settings: $e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
            );
          },
        );
      },
    );
  }

  void _showChangeWifiDialog(BuildContext context) {
    final TextEditingController ssid = TextEditingController();
    final TextEditingController pass = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final sending =
                ref.watch(bluetoothSetupViewModelProvider).sendingState;
            final isLoading = sending is AsyncLoading;
            return AlertDialog(
              title: const Text('Change WiFi on TankPi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ssid,
                    decoration: const InputDecoration(
                      labelText: 'WiFi Network Name (SSID)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pass,
                    decoration: const InputDecoration(
                      labelText: 'WiFi Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (ssid.text.isEmpty || pass.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in SSID and Password',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            await ProviderScope.containerOf(context)
                                .read(bluetoothSetupViewModelProvider.notifier)
                                .sendWifiCredentials(
                                  ssid: ssid.text,
                                  password: pass.text,
                                  aquariumId: null,
                                );
                            if (!context.mounted) return;
                            final s =
                                ProviderScope.containerOf(context)
                                    .read(bluetoothSetupViewModelProvider)
                                    .sendingState;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  s is AsyncData
                                      ? 'WiFi configuration sent to TankPi'
                                      : 'Failed to send WiFi configuration',
                                ),
                                backgroundColor:
                                    s is AsyncData ? Colors.green : Colors.red,
                              ),
                            );
                          },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AquariumSummary s) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Aquarium'),
          content: Text(
            'Are you sure you want to delete "${s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}'}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final vm = ProviderScope.containerOf(
                  context,
                ).read(aquariumDashboardViewModelProvider);

                try {
                  await vm.deleteAquarium(s.aquariumId);
                  Navigator.of(context).pop();

                  // Refresh the provider to remove deleted aquarium
                  ProviderScope.containerOf(
                    context,
                  ).refresh(aquariumsSummaryProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Aquarium "${s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}'}" deleted successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting aquarium: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAquariumCard(BuildContext context, AquariumSummary s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => AquariumDetailPage(
                      aquariumId: s.aquariumId,
                      aquariumName:
                          s.name.isNotEmpty
                              ? s.name
                              : 'Aquarium ${s.aquariumId}',
                    ),
              ),
            );
          },
          onLongPress: () {
            _showAquariumOptionsDialog(context, s);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSensorRow(
                  'Temperature',
                  '${s.sensor.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  'pH',
                  s.sensor.ph.toStringAsFixed(2),
                  Icons.water_drop,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  'Turbidity',
                  '${s.sensor.turbidity.toStringAsFixed(1)} NTU',
                  Icons.visibility,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.dashboard, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
