import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scheduled_autofeed/viewmodel/one_time_schedule_viewmodel.dart';
import 'widgets/one_time_schedule_list_item.dart';

class OneTimeAutofeedPage extends ConsumerWidget {
  final int aquariumId;
  final String aquariumName;

  const OneTimeAutofeedPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(oneTimeScheduleViewModelProvider(aquariumId));

    return Scaffold(
      appBar: AppBar(title: Text('One-time Feeding • $aquariumName')),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.schedules.isEmpty) {
            return Center(child: Text(state.errorMessage!));
          }
          final items = state.schedules;
          if (items.isEmpty) {
            return const Center(child: Text('No one-time tasks'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final s = items[index];
              return OneTimeScheduleListItem(
                schedule: s,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => _ScheduleDetails(schedule: s),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ScheduleDetails extends StatelessWidget {
  final dynamic schedule;
  const _ScheduleDetails({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled at: ${schedule.scheduleTime}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Food: ${schedule.food}'),
          Text('Cycle: ${schedule.cycle}'),
          Text('Status: ${schedule.status}'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
