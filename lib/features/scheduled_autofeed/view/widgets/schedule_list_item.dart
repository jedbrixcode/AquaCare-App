import 'package:flutter/material.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../../models/feeding_schedule_model.dart';

class ScheduleListItem extends StatelessWidget {
  final FeedingSchedule schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String formatToAmPm(String hhmm) {
      final parts = hhmm.split(':');
      if (parts.length != 2) return hhmm;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = (h % 12 == 0) ? 12 : (h % 12);
      final mm = m.toString().padLeft(2, '0');
      return '$hour12:$mm $period';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              schedule.isEnabled
                  ? Colors.green[200]!
                  : colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: onEdit,
        onLongPressEnd: (_) => onDelete(),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: schedule.isEnabled ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatToAmPm(schedule.time),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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
                              schedule.daily
                                  ? Colors.blue[50]
                                  : Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          schedule.daily ? 'Daily' : 'One-time',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                schedule.daily
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (schedule.daily) ...[
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
                                    : colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            schedule.isEnabled ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  schedule.isEnabled
                                      ? Colors.green[700]
                                      : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${schedule.cycles} cycle${schedule.cycles > 1 ? 's' : ''} • ${schedule.foodType}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (schedule.daily)
              Switch.adaptive(value: schedule.isEnabled, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}
