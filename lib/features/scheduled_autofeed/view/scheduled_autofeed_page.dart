import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

import '../viewmodel/scheduled_autofeed_viewmodel.dart';
import '../models/feeding_schedule_model.dart';
import 'widgets/schedule_list_item.dart';
import '../../scheduled_autofeed/viewmodel/one_time_schedule_viewmodel.dart';
import '../../scheduled_autofeed/models/one_time_schedule_model.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // themeMode from provider not used directly; rely on current Theme.of(context)
    // Selective watches minimize rebuilds
    final schedProvider = scheduledAutofeedViewModelProvider(aquariumId);
    final isLoading = ref.watch(schedProvider.select((s) => s.isLoading));
    final errorMessage = ref.watch(schedProvider.select((s) => s.errorMessage));
    final schedules = ref.watch(schedProvider.select((s) => s.schedules));
    final viewModel = ref.read(schedProvider.notifier);

    // One-time schedules from Firestore (status-aware), alarm-app style
    final intAquariumId = int.tryParse(aquariumId) ?? 0;
    final oneTimeState = ref.watch(
      oneTimeScheduleViewModelProvider(intAquariumId),
    );

    final dailySchedules = schedules.where((s) => s.daily).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          'Scheduled Autofeeding - $aquariumName',
          style: TextStyle(
            color:
                isDark
                    ? Theme.of(context).textTheme.displayLarge?.color
                    : Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.loadData();
          ref.invalidate(oneTimeScheduleViewModelProvider(intAquariumId));
        },
        child: ListView(
          padding: ResponsiveHelper.getScreenPadding(context),
          children: [
            // Error Message
            if (errorMessage != null)
              _errorBanner(context, errorMessage, () => viewModel.clearError()),

            // Daily section
            _sectionHeader(context, 'Daily Schedules'),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dailySchedules.isEmpty)
              _buildEmptyState(context, viewModel)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final schedule = dailySchedules[index];
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
                itemCount: dailySchedules.length,
              ),

            const SizedBox(height: 24),

            // One-time section (no toggles, status shown from Firestore)
            _sectionHeader(context, 'One-time Schedules'),
            if (oneTimeState.isLoading && oneTimeState.schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (oneTimeState.errorMessage != null &&
                oneTimeState.schedules.isEmpty)
              _errorBanner(context, oneTimeState.errorMessage!, null)
            else if (oneTimeState.schedules.isEmpty)
              _emptyOneTime(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final s = oneTimeState.schedules[index];
                  return _oneTimeCard(context, s, ref);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: oneTimeState.schedules.length,
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _showAddChoiceDialog(context, viewModel),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, 20),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
      ),
    );
  }

  Widget _errorBanner(
    BuildContext context,
    String errorMessage,
    VoidCallback? onClose,
  ) {
    return Container(
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
            child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: Colors.red[600]),
            ),
        ],
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Feeding Schedules',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a schedule to enable automatic feeding',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddChoiceDialog(context, viewModel),
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: Text(
                'Add First Schedule',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyOneTime(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Text(
          'No one-time feedings',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _oneTimeCard(
    BuildContext context,
    OneTimeSchedule schedule,
    WidgetRef ref,
  ) {
    Color statusColor;
    switch (schedule.status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'running':
        statusColor = Colors.blue;
        break;
      case 'done':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      schedule.scheduleTime,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'One-time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${schedule.cycle} cycle${schedule.cycle > 1 ? 's' : ''} • ${schedule.food}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                child: Text(
                  'Daily',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 20),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showOneTimeDialog(context, viewModel);
                },
                child: Text(
                  'One-time',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 20),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
    final bool isDaily = schedule?.daily ?? true;
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
                                child: Text('Pellets'),
                              ),
                              DropdownMenuItem(
                                value: 'flakes',
                                child: Text('Flakes'),
                              ),
                            ],
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              labelText: 'Food Type',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.restaurant),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(color: Colors.white),
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
                          if (isDaily)
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
                    if (schedule != null && (schedule.daily))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            viewModel.deleteSchedule(schedule.id);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
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
                            isEnabled: true,
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
                                child: Text('Pellets'),
                              ),
                              DropdownMenuItem(
                                value: 'flakes',
                                child: Text('Flakes'),
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
                          food: selectedFood,
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
