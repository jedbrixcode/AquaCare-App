import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/viewmodel/theme_viewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          const ListTile(title: Text('Theme')),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Global Notifications'),
            value: true,
            onChanged: (enabled) async {
              try {
                if (enabled) {
                  await FirebaseMessaging.instance.subscribeToTopic('aquacare_alerts');
                } else {
                  await FirebaseMessaging.instance.unsubscribeFromTopic('aquacare_alerts');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification preference updated')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating notifications: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
