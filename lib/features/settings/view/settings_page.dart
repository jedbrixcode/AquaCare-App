import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/theme.dart';
import 'package:aquacare_v5/features/settings/viewmodel/settings_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileThemeData(
            textColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
            iconColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Theme',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                'System Settings',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged:
                  (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
              activeColor: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                'Light',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged:
                  (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
              activeColor: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                'Dark',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged:
                  (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
              activeColor: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const Divider(color: Colors.grey, thickness: 1),
            _GlobalNotificationsTile(),
            const Divider(color: Colors.grey, thickness: 1),
          ],
        ),
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
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preference updated')),
        );
      },
      activeColor: Theme.of(context).colorScheme.primary,
      activeTrackColor: Theme.of(context).colorScheme.onSecondary,
      inactiveThumbColor: Theme.of(context).colorScheme.primary,
      inactiveTrackColor: Theme.of(context).colorScheme.onSecondary,
    );
  }
}
