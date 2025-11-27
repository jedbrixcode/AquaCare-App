import 'package:flutter/material.dart';
import 'package:aquacare_v5/utils/theme.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../../models/feeding_schedule_model.dart';
import '../../viewmodel/scheduled_autofeed_viewmodel.dart';
import 'time_format_utils.dart';

Future<void> showEditScheduleDialog(
  BuildContext context,
  FeedingSchedule schedule,
  ScheduledAutofeedViewModel viewModel,
) async {
  await showScheduleDialog(
    context: context,
    viewModel: viewModel,
    title: 'Edit Feeding Schedule',
    schedule: schedule,
  );
}

Future<void> showScheduleDialog({
  required BuildContext context,
  required ScheduledAutofeedViewModel viewModel,
  required String title,
  FeedingSchedule? schedule,
}) async {
  final formKey = GlobalKey<FormState>();
  final timeController = TextEditingController(
    text: formatDisplayFrom24(schedule?.time ?? '08:00'),
  );
  final cyclesController = TextEditingController(
    text: (schedule?.cycles ?? 1).toString(),
  );
  bool isEnabled = schedule?.isEnabled ?? true;
  String selectedFood =
      (schedule?.foodType.toLowerCase() == 'flakes') ? 'flakes' : 'pellets';
  TimeOfDay selectedTime =
      parseTimeOfDay(schedule?.time ?? '08:00') ??
          const TimeOfDay(hour: 8, minute: 0);

  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor:
                    isDark
                        ? darkTheme.colorScheme.background
                        : lightTheme.colorScheme.background,
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
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
                              setState(() {
                                selectedTime = picked;
                                timeController.text = formatDisplay(picked);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: timeController,
                              decoration: const InputDecoration(
                                labelText: 'Time (HH:mm)',
                                hintText: '08:00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              validator:
                                  (v) =>
                                      parseTimeOfDayDisplay(v ?? '') == null
                                          ? 'Enter a valid time'
                                          : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: cyclesController,
                          decoration: InputDecoration(
                            labelText: 'Number of Cycles',
                            hintText: '1',
                            prefixIcon: const Icon(Icons.repeat),
                            border: const OutlineInputBorder(),
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
                        SizedBox(
                          height: ResponsiveHelper.verticalPadding(context),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedFood,
                          items: const [
                            DropdownMenuItem(
                              value: 'pellets',
                              child: Text('Pellets'),
                            ),
                            DropdownMenuItem(
                              value: 'flakes',
                              child: Text('Flakes'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedFood = value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Food Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.restaurant),
                          ),
                          validator:
                              (v) =>
                                  (v == null ||
                                          (v != 'pellets' && v != 'flakes'))
                                      ? 'Select food'
                                      : null,
                        ),
                        const SizedBox(height: 8),
                        if (schedule != null && schedule.daily)
                          SwitchListTile(
                            title: const Text('Enabled'),
                            value: isEnabled,
                            onChanged: (v) => setState(() => isEnabled = v),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (schedule != null && schedule.daily)
                        TextButton(
                          onPressed: () {
                            viewModel.deleteSchedule(schedule.id);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final time = formatTimeOfDay(selectedTime);
                              final cycles = int.parse(
                                cyclesController.text.trim(),
                              );
                              if (schedule != null) {
                                viewModel.updateSchedule(
                                  scheduleId: schedule.id,
                                  time: time,
                                  cycles: cycles,
                                  foodType: selectedFood,
                                  isEnabled: isEnabled,
                                );
                              } else {
                                viewModel.addSchedule(
                                  time: time,
                                  cycles: cycles,
                                  foodType: selectedFood,
                                  isEnabled: true,
                                );
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text(schedule != null ? 'Update' : 'Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
        ),
  );
}
