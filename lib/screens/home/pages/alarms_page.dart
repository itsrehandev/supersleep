import 'package:flutter/material.dart';

import '../../../models/alarm_model.dart';
import '../../../services/alarm_store.dart';
import '../../alarms/add_alarm_screen.dart';

class AlarmsDashboardPage extends StatelessWidget {
  const AlarmsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Sleep', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Alarm>>(
          valueListenable: AlarmStore.instance.alarmsNotifier,
          builder: (context, alarms, child) {
            if (alarms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Alarms Set',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first alarm',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final nextAlarm = alarms.firstWhere(
              (a) => a.isEnabled,
              orElse: () => alarms.first,
            );

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Next Alarm Card
                InkWell(
                  onTap: () => AddAlarmScreen.showAsModal(
                    context,
                    alarmToEdit: nextAlarm,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Next Alarm',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.alarm_on,
                                color: colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextAlarm.time.format(context),
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${nextAlarm.label} • ${nextAlarm.getRepeatText()}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // All Alarms Header
                Text(
                  'All Alarms',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Alarm List Tiles
                ...alarms.map((alarm) {
                  final formattedTime = alarm.time.format(context);
                  final repeatText = alarm.getRepeatText();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => AddAlarmScreen.showAsModal(
                        context,
                        alarmToEdit: alarm,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          formattedTime,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: alarm.isEnabled
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${alarm.label} • $repeatText',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (alarm.mathMissionEnabled ||
                                alarm.typingMissionEnabled ||
                                alarm.qrMissionEnabled) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: [
                                  if (alarm.mathMissionEnabled)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        'Math (${alarm.mathDifficulty})',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  if (alarm.typingMissionEnabled)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        'Typing (${alarm.typingDifficulty})',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  if (alarm.qrMissionEnabled)
                                    const Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        'QR Scan',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: alarm.isEnabled,
                              onChanged: (val) {
                                AlarmStore.instance.toggleAlarm(alarm.id, val);
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  AddAlarmScreen.showAsModal(
                                    context,
                                    alarmToEdit: alarm,
                                  );
                                } else if (value == 'duplicate') {
                                  AlarmStore.instance.duplicateAlarm(alarm.id);
                                } else if (value == 'delete') {
                                  AlarmStore.instance.deleteAlarm(alarm.id);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 20),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddAlarmScreen.showAsModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Alarm'),
      ),
    );
  }
}
