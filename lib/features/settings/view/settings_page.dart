import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/viewmodel/theme_viewmodel.dart';
import 'package:aquacare_v5/features/settings/viewmodel/settings_viewmodel.dart';

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
            onChanged:
                (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged:
                (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged:
                (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
          ),
          const Divider(),
          _GlobalNotificationsTile(),
        ],
      ),
    );
  }
}

class _GlobalNotificationsTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GlobalNotificationsTile> createState() =>
      _GlobalNotificationsTileState();
}

class _GlobalNotificationsTileState
    extends ConsumerState<_GlobalNotificationsTile> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    final controller = ref.read(settingsViewModelProvider.notifier);
    return SwitchListTile(
      title: const Text('Global Notifications (master switch)'),
      subtitle: const Text('Also toggles each aquarium sensor notifications'),
      value: settings.globalNotificationsEnabled,
      onChanged: (enabled) async {
        await controller.toggleGlobalNotifications(enabled);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preference updated')),
        );
      },
    );
  }
}
