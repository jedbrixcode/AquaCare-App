import 'package:flutter/material.dart';
import 'package:aquacare_v5/utils/theme.dart';
import '../../viewmodel/scheduled_autofeed_viewmodel.dart';
import 'time_format_utils.dart';

Future<void> showOneTimeScheduleDialog(
  BuildContext context,
  ScheduledAutofeedViewModel viewModel,
) async {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  final cyclesController = TextEditingController(text: '1');
  String selectedFood = 'pellets';
  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor:
            isDark
                ? darkTheme.colorScheme.background
                : lightTheme.colorScheme.background,
        title: Text(
          'Add One-Time Feeding',
          style: TextStyle(
            color:
                isDark
                    ? darkTheme.textTheme.displayLarge?.color
                    : lightTheme.textTheme.displayLarge?.color,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color:
                        isDark
                            ? darkTheme.textTheme.bodyLarge?.color
                            : lightTheme.textTheme.bodyLarge?.color,
                  ),
                  title: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color:
                          isDark
                              ? darkTheme.textTheme.bodyLarge?.color
                              : lightTheme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color:
                        isDark
                            ? darkTheme.textTheme.bodyLarge?.color
                            : lightTheme.textTheme.bodyLarge?.color,
                  ),
                  title: Text(
                    formatDisplay(selectedTime),
                    style: TextStyle(
                      color:
                          isDark
                              ? darkTheme.textTheme.bodyLarge?.color
                              : lightTheme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: false),
                          child: child ?? const SizedBox.shrink(),
                        );
                      },
                    );
                    if (picked != null) {
                      selectedTime = picked;
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: cyclesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Cycles',
                    hintText: '1',
                    prefixIcon: Icon(Icons.repeat),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final parsed = int.tryParse((v ?? '').trim());
                    if (parsed == null || parsed < 1 || parsed > 10) {
                      return 'Enter a number between 1 and 10';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFood,
                  items: const [
                    DropdownMenuItem(value: 'pellets', child: Text('Pellets')),
                    DropdownMenuItem(value: 'flakes', child: Text('Flakes')),
                  ],
                  onChanged: (val) => selectedFood = val ?? 'pellets',
                  decoration: const InputDecoration(
                    labelText: 'Food Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator:
                      (v) =>
                          (v == null || (v != 'pellets' && v != 'flakes'))
                              ? 'Select food'
                              : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final dateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              final parsed = int.tryParse(cyclesController.text.trim()) ?? 1;
              await viewModel.addOneTimeTask(
                scheduleDateTime: dateTime,
                cycles: parsed,
                food: selectedFood,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'One-time schedule set for ${formatDisplay(selectedTime)} on ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                  ),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
