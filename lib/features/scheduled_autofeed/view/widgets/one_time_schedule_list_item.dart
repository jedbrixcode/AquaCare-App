import 'package:flutter/material.dart';
import '../../models/one_time_schedule_model.dart';

class OneTimeScheduleListItem extends StatelessWidget {
  final OneTimeSchedule schedule;
  final VoidCallback? onTap;

  const OneTimeScheduleListItem({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final at = schedule.scheduleTime;
    return Card(
      child: ListTile(
        title: Text('Time: $at'),
        subtitle: Text('Food: ${schedule.food}  •  Cycle: ${schedule.cycle}'),
        trailing: _statusChip(schedule.status, context),
        onTap: onTap,
      ),
    );
  }

  Widget _statusChip(String status, BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'running':
        color = Colors.blue;
        break;
      case 'done':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      default:
        color = Theme.of(context).colorScheme.secondary;
    }
    return Chip(label: Text(status), backgroundColor: color.withOpacity(0.15));
  }
}
