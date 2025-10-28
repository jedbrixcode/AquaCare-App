import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:aquacare_v5/features/aquarium/view/aquarium_detail_page.dart';
import 'package:aquacare_v5/features/bluetooth/view/bluetooth_setup_page.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/core/connectivity/connectivity_provider.dart';
import 'package:aquacare_v5/utils/theme.dart';

class AquariumDashboardPage extends ConsumerWidget {
  const AquariumDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(aquariumsSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaCare Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleTextStyle: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        elevation: 10,
        shadowColor: Theme.of(context).colorScheme.shadow,
        width: 270,
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
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
              title: Text(
                'Home',
                style: TextStyle(
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyMedium?.color
                          : lightTheme.textTheme.bodyMedium?.color,
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
              title: Text(
                'Chat with AI',
                style: TextStyle(
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyMedium?.color
                          : lightTheme.textTheme.bodyMedium?.color,
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
              title: Text(
                'Monitoring Graphs',
                style: TextStyle(
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyMedium?.color
                          : lightTheme.textTheme.bodyMedium?.color,
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
              title: Text(
                'Settings',
                style: TextStyle(
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyMedium?.color
                          : lightTheme.textTheme.bodyMedium?.color,
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
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are currently offline. Some features may be limited.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
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

          // Main body of page
          Expanded(
            child: summaryAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Aquariums Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Waiting for aquarium data...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                          color:
                              isDark
                                  ? darkTheme.textTheme.bodyMedium?.color
                                  : lightTheme.textTheme.bodyMedium?.color,
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
                        Text(
                          'Error loading aquariums',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(aquariumsSummaryProvider);
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
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
                leading: Icon(
                  Icons.bluetooth,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'TankPi Setup (Bluetooth)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.wifi,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Change WiFi Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmBleReconfigure(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Edit Name',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditAquariumDialog(context, s);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Notification Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
          title: Text(
            'Edit Aquarium Name',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Aquarium Name',
              hintText: 'Enter new name',
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
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
                      title: Text(
                        'Notification Settings',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: Text(
                              'Temperature Alerts',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: tempNotif,
                            onChanged: (v) => setState(() => tempNotif = v),
                          ),
                          SwitchListTile(
                            title: Text(
                              'pH Level Alerts',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: phNotif,
                            onChanged: (v) => setState(() => phNotif = v),
                          ),
                          SwitchListTile(
                            title: Text(
                              'Turbidity Alerts',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: turbidityNotif,
                            onChanged:
                                (v) => setState(() => turbidityNotif = v),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
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
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
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

  void _confirmBleReconfigure(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Reconfigure TankPi',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Wi‑Fi credentials changed. TankPi must be reconfigured via Bluetooth. Continue?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BluetoothSetupPage(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please complete Bluetooth setup to reconnect TankPi',
                      ),
                    ),
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AquariumSummary s) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Aquarium',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete "${s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}'}"? This action cannot be undone.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                  if (!context.mounted) return;
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
                      backgroundColor:
                          Theme.of(
                            context,
                          ).colorScheme.secondary, // Use theme green equivalent
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting aquarium: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color:
            isDark
                ? Color.fromARGB(255, 0, 30, 75)
                : Color.fromARGB(255, 53, 171, 240),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isDark
                    ? const Color.fromARGB(255, 53, 171, 240)
                    : const Color.fromARGB(255, 0, 17, 255),

            width: 1,
          ),
        ),
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
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.87),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSensorRow(
                  context,
                  'Temperature',
                  '${s.sensor.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  context,
                  'pH',
                  s.sensor.ph.toStringAsFixed(2),
                  Icons.water_drop,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  context,
                  'Turbidity',
                  '${s.sensor.turbidity.toStringAsFixed(1)} NTU',
                  Icons.water_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 20,
                      color: Colors.white.withOpacity(0.87),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.87),
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

  Widget _buildSensorRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white.withOpacity(0.87)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.87),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.87),
          ),
        ),
      ],
    );
  }
}
