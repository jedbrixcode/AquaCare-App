import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/utils/theme.dart';

import '../viewmodel/scheduled_autofeed_viewmodel.dart';
import '../models/feeding_schedule_model.dart';
import 'widgets/schedule_list_item.dart';
import '../../scheduled_autofeed/viewmodel/one_time_schedule_viewmodel.dart';
import '../../scheduled_autofeed/models/one_time_schedule_model.dart';
import 'widgets/time_format_utils.dart';
import 'widgets/ui_helpers.dart';
import 'widgets/schedule_dialog.dart';
import 'widgets/one_time_schedule_dialog.dart';
import 'widgets/delete_confirmation_dialog.dart';

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

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark
                ? darkTheme.appBarTheme.backgroundColor
                : lightTheme.appBarTheme.backgroundColor,
        title: Text('Scheduled Autofeeding - $aquariumName'),
        titleTextStyle: TextStyle(
          color:
              isDark
                  ? darkTheme.appBarTheme.titleTextStyle?.color
                  : lightTheme.appBarTheme.titleTextStyle?.color,
          fontSize: ResponsiveHelper.getFontSize(context, 24),
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.loadData();
          ref.invalidate(oneTimeScheduleViewModelProvider(intAquariumId));
        },
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.horizontalPadding(context),
            vertical: ResponsiveHelper.verticalPadding(context),
          ),
          children: [
            // Error Message
            if (errorMessage != null)
              ErrorBanner(
                errorMessage: errorMessage,
                onClose: () => viewModel.clearError(),
              ),

            // Daily section
            const SectionHeader(title: 'Daily Schedules'),
            if (isLoading)
              Padding(
                padding: ResponsiveHelper.getScreenPadding(
                  context,
                ).copyWith(top: 24, bottom: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color:
                        isDark
                            ? darkTheme.colorScheme.primary
                            : lightTheme.colorScheme.primary,
                  ),
                ),
              )
            else if (dailySchedules.isEmpty)
              EmptyStateCard(
                title: 'No Feeding Schedules',
                subtitle: 'Add a schedule to enable automatic feeding',
                buttonText: 'Add First Schedule',
                onPressed: () => _showAddChoiceDialog(context, viewModel),
              )
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
                        () => showDeleteScheduleConfirmation(
                          context,
                          schedule,
                          viewModel,
                        ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: dailySchedules.length,
              ),

            SizedBox(height: ResponsiveHelper.verticalPadding(context)),

            // One-time section (no toggles, status shown from Firestore)
            const SectionHeader(title: 'One-time Schedules'),
            if (oneTimeState.isLoading && oneTimeState.schedules.isEmpty)
              Padding(
                padding: ResponsiveHelper.getScreenPadding(
                  context,
                ).copyWith(top: 24, bottom: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color:
                        isDark
                            ? darkTheme.colorScheme.primary
                            : lightTheme.colorScheme.primary,
                  ),
                ),
              )
            else if (oneTimeState.errorMessage != null &&
                oneTimeState.schedules.isEmpty)
              ErrorBanner(errorMessage: oneTimeState.errorMessage!)
            else if (oneTimeState.schedules.isEmpty)
              EmptyStateCard(
                title: 'No One-time Feeding Schedules',
                subtitle: 'Add a one-time schedule to enable automatic feeding',
                buttonText: 'Add One-time Schedule',
                onPressed: () => _showAddChoiceDialog(context, viewModel),
              )
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

            SizedBox(height: ResponsiveHelper.verticalPadding(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        onPressed: () => _showAddChoiceDialog(context, viewModel),
        child: Icon(
          Icons.add,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
    );
  }

  // trimmed legacy helpers (migrated to widgets/ui_helpers.dart)

  // trimmed legacy helpers (migrated to widgets/ui_helpers.dart)

  // trimmed legacy helpers (migrated to widgets/ui_helpers.dart)

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onLongPress: () async {
        await _showEditOneTimeDialog(context, ref, schedule);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor, width: 1),
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
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formatScheduleDateOnly(schedule.scheduleTime),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          fontWeight: FontWeight.w500,
                          color:
                              isDark
                                  ? darkTheme.textTheme.bodyLarge?.color
                                  : lightTheme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.horizontalPadding(context),
                      ),
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
                            fontWeight: FontWeight.bold,
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
                          schedule.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${schedule.cycle} Cycle${schedule.cycle > 1 ? 's' : ''} — ${schedule.food[0].toUpperCase()}${schedule.food.substring(1).toLowerCase()}',
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
      ),
    );
  }

  Future<void> _showEditOneTimeDialog(
    BuildContext context,
    WidgetRef ref,
    OneTimeSchedule schedule,
  ) async {
    final formKey = GlobalKey<FormState>();
    DateTime base = schedule.scheduledAtLocal ?? DateTime.now();
    DateTime selectedDate = DateTime(base.year, base.month, base.day);
    TimeOfDay selectedTime = TimeOfDay(hour: base.hour, minute: base.minute);
    final cyclesController = TextEditingController(
      text: schedule.cycle.toString(),
    );
    String selectedFood =
        schedule.food.toLowerCase() == 'flakes' ? 'flakes' : 'pellet';

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: Text(
                    'Edit One-time Feeding',
                    style: TextStyle(
                      color:
                          isDark
                              ? darkTheme.textTheme.bodyLarge?.color
                              : lightTheme.textTheme.bodyLarge?.color,
                    ),
                  ),
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
                            title: Text(formatDisplay(selectedTime)),
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
                            decoration: InputDecoration(
                              labelText: 'Cycles',
                              prefixIcon: const Icon(Icons.repeat),

                              // Label color
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: Colors.blue,
                              ),

                              // Borders
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                  () => selectedFood = (v ?? 'pellet'),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🗑️ Left-aligned Delete
                        TextButton(
                          onPressed: () async {
                            final vm = ref.read(
                              scheduledAutofeedViewModelProvider(
                                aquariumId,
                              ).notifier,
                            );
                            await vm.deleteOneTimeTask(
                              scheduleDateTime:
                                  schedule.scheduledAtLocal ?? DateTime.now(),
                              documentId: schedule.id,
                            );
                            if (!context.mounted) return;
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('One-time schedule deleted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? darkTheme.textTheme.bodyLarge?.color
                                          : lightTheme
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final newCycles = int.parse(
                                  cyclesController.text.trim(),
                                );
                                final newDt = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                  0,
                                );

                                final vm = ref.read(
                                  scheduledAutofeedViewModelProvider(
                                    aquariumId,
                                  ).notifier,
                                );

                                // Delete old entry
                                await vm.deleteOneTimeTask(
                                  scheduleDateTime:
                                      schedule.scheduledAtLocal ?? newDt,
                                  documentId: schedule.id,
                                );

                                // Add updated entry
                                await vm.addOneTimeTask(
                                  scheduleDateTime: newDt,
                                  cycles: newCycles,
                                  food: selectedFood,
                                );

                                if (!context.mounted) return;
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('One-time schedule updated'),
                                  ),
                                );
                              },
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? darkTheme.textTheme.bodyLarge?.color
                                          : lightTheme
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                ),
                              ),
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
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Schedule',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color,
                ),
              ),

              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  showScheduleDialog(
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
                    color:
                        isDark
                            ? darkTheme.textTheme.bodyLarge?.color
                            : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isDark
                          ? darkTheme.colorScheme.primary
                          : lightTheme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  showOneTimeScheduleDialog(context, viewModel);
                },
                child: Text(
                  'One-time',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 20),
                    color:
                        isDark
                            ? darkTheme.textTheme.bodyLarge?.color
                            : Colors.white,
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
    showEditScheduleDialog(context, schedule, viewModel);
  }

  // trimmed legacy dialog (migrated to widgets/schedule_dialog.dart)

  // trimmed legacy dialog (migrated to widgets/delete_confirmation_dialog.dart)

  // trimmed legacy dialog (migrated to widgets/one_time_schedule_dialog.dart)
}
