import 'package:flutter/material.dart';
import '../../models/feeding_schedule_model.dart';
import '../../viewmodel/scheduled_autofeed_viewmodel.dart';

Future<void> showDeleteScheduleConfirmation(
  BuildContext context,
  FeedingSchedule schedule,
  ScheduledAutofeedViewModel viewModel,
) async {
  await showDialog(
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
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}
