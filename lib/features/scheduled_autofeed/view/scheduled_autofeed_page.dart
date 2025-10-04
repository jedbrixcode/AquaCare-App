import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../viewmodel/scheduled_autofeed_viewmodel.dart';
import '../models/feeding_schedule_model.dart';

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
    final state = ref.watch(scheduledAutofeedViewModelProvider(aquariumId));
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
            // Auto Feeder Status Card
            _buildAutoFeederStatusCard(context, state, viewModel),
            const SizedBox(height: 24),

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
                  onPressed: () => _showAddScheduleDialog(context, viewModel),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Schedule',
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
            const SizedBox(height: 16),

            // Error Message
            if (state.errorMessage != null)
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
                        state.errorMessage!,
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
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Schedules List
            if (!state.isLoading && state.schedules.isEmpty)
              _buildEmptyState(context, viewModel)
            else if (!state.isLoading)
              ...state.schedules
                  .map(
                    (schedule) =>
                        _buildScheduleCard(context, schedule, viewModel),
                  )
                  .toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoFeederStatusCard(
    BuildContext context,
    ScheduledAutofeedState state,
    ScheduledAutofeedViewModel viewModel,
  ) {
    final isEnabled = state.autoFeederStatus?.isEnabled ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 32, color: Colors.blue[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled Autofeeding',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: isEnabled ? Colors.green[600] : Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => viewModel.toggleAutoFeeder(value),
            activeColor: Colors.blue[600],
            trackColor: MaterialStateProperty.resolveWith<Color?>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[200]; // when ON
              }
              return Colors.grey[300]; // when OFF
            }),
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

  Widget _buildScheduleCard(
    BuildContext context,
    FeedingSchedule schedule,
    ScheduledAutofeedViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.isEnabled ? Colors.green[200]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: schedule.isEnabled ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Schedule details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      schedule.time,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            schedule.isEnabled
                                ? Colors.green[100]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.isEnabled ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              schedule.isEnabled
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${schedule.cycles} cycle${schedule.cycles > 1 ? 's' : ''} • ${schedule.foodType}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                onPressed:
                    () => _showEditScheduleDialog(context, schedule, viewModel),
                icon: Icon(Icons.edit, color: Colors.blue[600]),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed:
                    () => _showDeleteConfirmation(context, schedule, viewModel),
                icon: Icon(Icons.delete, color: Colors.red[600]),
                tooltip: 'Delete',
              ),
            ],
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
    final timeController = TextEditingController(
      text: schedule?.time ?? '08:00',
    );
    final cyclesController = TextEditingController(
      text: (schedule?.cycles ?? 1).toString(),
    );
    final foodTypeController = TextEditingController(
      text: schedule?.foodType ?? 'Default',
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Time picker
                        TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: 'Time (HH:mm)',
                            hintText: '08:00',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 16),

                        // Cycles
                        TextField(
                          controller: cyclesController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Cycles',
                            hintText: '1',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Food type
                        TextField(
                          controller: foodTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Food Type',
                            hintText: 'Default',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Enabled toggle
                        Row(
                          children: [
                            const Text('Enabled'),
                            const Spacer(),
                            Switch(
                              value: isEnabled,
                              onChanged:
                                  (value) => setState(() => isEnabled = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final time = timeController.text.trim();
                        final cycles =
                            int.tryParse(cyclesController.text.trim()) ?? 1;
                        final foodType =
                            foodTypeController.text.trim().isEmpty
                                ? 'Default'
                                : foodTypeController.text.trim();

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
}
