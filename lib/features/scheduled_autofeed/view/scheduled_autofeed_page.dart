import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../viewmodel/scheduled_autofeed_viewmodel.dart';
import '../models/feeding_schedule_model.dart';
import 'widgets/schedule_list_item.dart';

class ScheduledAutofeedPage extends ConsumerWidget {
  final String aquariumId;
  final String aquariumName;

  const ScheduledAutofeedPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // themeMode from provider not used directly; rely on current Theme.of(context)
    // Selective watches minimize rebuilds
    final isLoading = ref.watch(
      scheduledAutofeedViewModelProvider(aquariumId).select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      scheduledAutofeedViewModelProvider(
        aquariumId,
      ).select((s) => s.errorMessage),
    );
    // Status derives from Firebase switches; master switch removed
    final schedules = ref.watch(
      scheduledAutofeedViewModelProvider(aquariumId).select((s) => s.schedules),
    );
    final viewModel = ref.read(
      scheduledAutofeedViewModelProvider(aquariumId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduled Autofeeding - $aquariumName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedules Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feeding Schedules',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddChoiceDialog(context, viewModel),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Schedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getFontSize(context, 15),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error Message
            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      onPressed: () => viewModel.clearError(),
                      icon: Icon(Icons.close, color: Colors.red[600]),
                    ),
                  ],
                ),
              ),

            // Loading Indicator
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Schedules List
            if (!isLoading && schedules.isEmpty)
              _buildEmptyState(context, viewModel)
            else if (!isLoading)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return ScheduleListItem(
                    schedule: schedule,
                    onToggle:
                        (enabled) =>
                            viewModel.toggleSchedule(schedule.id, enabled),
                    onEdit:
                        () => _showEditScheduleDialog(
                          context,
                          schedule,
                          viewModel,
                        ),
                    onDelete:
                        () => _showDeleteConfirmation(
                          context,
                          schedule,
                          viewModel,
                        ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: schedules.length,
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ScheduledAutofeedViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Feeding Schedules',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a schedule to enable automatic feeding',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddScheduleDialog(context, viewModel),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add First Schedule',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(
    BuildContext context,
    ScheduledAutofeedViewModel viewModel,
  ) {
    _showScheduleDialog(
      context: context,
      viewModel: viewModel,
      title: 'Add Feeding Schedule',
      schedule: null,
    );
  }

  void _showAddChoiceDialog(
    BuildContext context,
    ScheduledAutofeedViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Schedule',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showScheduleDialog(
                    context: context,
                    viewModel: viewModel,
                    title: 'Add Daily Feeding',
                    schedule: null,
                  );
                },
                child: Text('Daily', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showOneTimeDialog(context, viewModel);
                },
                child: const Text('One-time', style: TextStyle(fontSize: 15)),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditScheduleDialog(
    BuildContext context,
    FeedingSchedule schedule,
    ScheduledAutofeedViewModel viewModel,
  ) {
    _showScheduleDialog(
      context: context,
      viewModel: viewModel,
      title: 'Edit Feeding Schedule',
      schedule: schedule,
    );
  }

  void _showScheduleDialog({
    required BuildContext context,
    required ScheduledAutofeedViewModel viewModel,
    required String title,
    FeedingSchedule? schedule,
  }) {
    final formKey = GlobalKey<FormState>();
    final timeController = TextEditingController(
      text: _formatDisplayFrom24(schedule?.time ?? '08:00'),
    );
    final cyclesController = TextEditingController(
      text: (schedule?.cycles ?? 1).toString(),
    );
    bool isEnabled = schedule?.isEnabled ?? true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final initial =
                                  _parseTimeOfDayDisplay(timeController.text) ??
                                  const TimeOfDay(hour: 8, minute: 0);
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
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
                                timeController.text = _formatDisplay(picked);
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
                                        _parseTimeOfDayDisplay(v ?? '') == null
                                            ? 'Enter a valid time'
                                            : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: cyclesController,
                            decoration: const InputDecoration(
                              labelText: 'Number of Cycles',
                              hintText: '1',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
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
                            value:
                                (schedule?.foodType.toLowerCase() == 'flakes')
                                    ? 'flakes'
                                    : 'pellet',
                            items: const [
                              DropdownMenuItem(
                                value: 'pellet',
                                child: Text('pellet'),
                              ),
                              DropdownMenuItem(
                                value: 'flakes',
                                child: Text('flakes'),
                              ),
                            ],
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              labelText: 'Food Type',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.restaurant),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            validator:
                                (v) =>
                                    (v == null ||
                                            (v != 'pellet' && v != 'flakes'))
                                        ? 'Select food'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile.adaptive(
                            value: isEnabled,
                            onChanged:
                                (value) => setState(() => isEnabled = value),
                            title: const Text('Enabled'),
                            contentPadding: EdgeInsets.zero,
                          ),
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
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final time = _format24FromDisplay(
                          timeController.text.trim(),
                        );
                        final cycles = int.parse(cyclesController.text.trim());
                        final foodType =
                            (schedule?.foodType.toLowerCase() == 'flakes')
                                ? 'flakes'
                                : 'pellet';

                        if (schedule != null) {
                          viewModel.updateSchedule(
                            scheduleId: schedule.id,
                            time: time,
                            cycles: cycles,
                            foodType: foodType,
                            isEnabled: isEnabled,
                          );
                        } else {
                          viewModel.addSchedule(
                            time: time,
                            cycles: cycles,
                            foodType: foodType,
                            isEnabled: isEnabled,
                          );
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text(schedule != null ? 'Update' : 'Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FeedingSchedule schedule,
    ScheduledAutofeedViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: Text(
              'Are you sure you want to delete the feeding schedule at ${schedule.time}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.deleteSchedule(schedule.id);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showOneTimeDialog(
    BuildContext context,
    ScheduledAutofeedViewModel viewModel,
  ) {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    final cyclesController = TextEditingController(text: '1');
    String selectedFood = 'pellet';

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: const Text('Add One-time Feeding'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date picker
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          // Time picker AM/PM
                          ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(_formatDisplay(selectedTime)),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                builder:
                                    (context, child) => MediaQuery(
                                      data: MediaQuery.of(
                                        context,
                                      ).copyWith(alwaysUse24HourFormat: false),
                                      child: child ?? const SizedBox.shrink(),
                                    ),
                              );
                              if (picked != null) {
                                setState(() => selectedTime = picked);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: cyclesController,
                            decoration: const InputDecoration(
                              labelText: 'Cycles',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
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
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedFood,
                            items: const [
                              DropdownMenuItem(
                                value: 'pellet',
                                child: Text('pellet'),
                              ),
                              DropdownMenuItem(
                                value: 'flakes',
                                child: Text('flakes'),
                              ),
                            ],
                            onChanged:
                                (v) => setState(
                                  () => selectedFood = v ?? 'pellet',
                                ),
                            decoration: const InputDecoration(
                              labelText: 'Food Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.restaurant),
                            ),
                            validator:
                                (v) =>
                                    (v == null ||
                                            (v != 'pellet' && v != 'flakes'))
                                        ? 'Select food'
                                        : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final cycles = int.parse(cyclesController.text.trim());
                        final dt = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                          0,
                        );
                        await viewModel.addOneTimeTask(
                          scheduleDateTime: dt,
                          cycles: cycles,
                        );
                        if (context.mounted) Navigator.of(ctx).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}

TimeOfDay? _parseTimeOfDay(String input) {
  final parts = input.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return TimeOfDay(hour: h, minute: m);
}

String _formatTimeOfDay(TimeOfDay t) {
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

// AM/PM helpers for display and parsing
String _formatDisplay(TimeOfDay t) {
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final minute = t.minute.toString().padLeft(2, '0');
  final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

TimeOfDay? _parseTimeOfDayDisplay(String input) {
  final trimmed = input.trim().toUpperCase();
  final am = trimmed.endsWith('AM');
  final pm = trimmed.endsWith('PM');
  if (!am && !pm) return null;
  final timePart = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
  final parts = timePart.split(':');
  if (parts.length != 2) return null;
  final hour12 = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour12 == null || minute == null) return null;
  if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59) return null;
  int hour24 = hour12 % 12;
  if (pm) hour24 += 12;
  return TimeOfDay(hour: hour24, minute: minute);
}

String _format24FromDisplay(String display) {
  final t = _parseTimeOfDayDisplay(display);
  if (t == null) return '08:00';
  return _formatTimeOfDay(t);
}

String _formatDisplayFrom24(String hhmm) {
  final t = _parseTimeOfDay(hhmm) ?? const TimeOfDay(hour: 8, minute: 0);
  return _formatDisplay(t);
}
