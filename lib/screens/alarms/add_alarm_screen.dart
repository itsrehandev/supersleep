import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/alarm_model.dart';
import '../../services/alarm_store.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key});

  static Future<void> showAsModal(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddAlarmScreen(),
    );
  }

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final TextEditingController _labelController =
      TextEditingController(text: 'Alarm');

  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  late final Set<int> _selectedDays = {(DateTime.now().weekday - 1) % 7};

  String _selectedRingtone = 'Gentle Sunrise (Default)';
  String? _customRingtonePath;

  final List<String> _builtinRingtones = const [
    'Gentle Sunrise (Default)',
    'Radar',
    'Beacon',
    'Morning Breeze',
    'Classic Bell',
    'Digital Alarm',
  ];

  bool _mathMissionEnabled = false;
  String _mathDifficulty = 'Medium';

  bool _qrMissionEnabled = false;

  bool _typingMissionEnabled = false;
  String _typingDifficulty = 'Easy';

  bool _vibrationEnabled = true;
  double _volumePercentage = 70.0;
  bool _gradualVolumeEnabled = true;
  int _gradualDurationSeconds = 15;

  bool _snoozeEnabled = true;
  int _snoozeIntervalMinutes = 5;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showRingtonePicker() {
    final AudioPlayer player = AudioPlayer();
    String? playingRingtone;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void playSound(String ringtoneName, {String? customPath}) async {
              try {
                await player.stop();
                if (playingRingtone == ringtoneName) {
                  setModalState(() {
                    playingRingtone = null;
                  });
                  return;
                }

                setModalState(() {
                  playingRingtone = ringtoneName;
                });

                if (customPath != null && customPath.isNotEmpty) {
                  await player.play(DeviceFileSource(customPath));
                }
              } catch (_) {
                // Ignore errors if audio source unavailable
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Bar with Header and Cross Close Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Ringtone',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              player.stop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 16),
                    ..._builtinRingtones.map((ringtone) {
                      final isSelected = ringtone == _selectedRingtone;
                      final isPlaying = ringtone == playingRingtone;

                      return ListTile(
                        title: Text(ringtone),
                        leading: Icon(
                          isSelected ? Icons.music_note : Icons.music_note_outlined,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => playSound(ringtone),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedRingtone = ringtone;
                            _customRingtonePath = null;
                          });
                          playSound(ringtone);
                        },
                      );
                    }),
                    const Divider(height: 24),
                    ListTile(
                      leading: Icon(
                        Icons.audio_file_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        'Add from device',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _customRingtonePath != null
                            ? _selectedRingtone
                            : 'Pick custom MP3 file from phone storage',
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.audio,
                          allowMultiple: false,
                        );

                        if (result != null && result.files.single.path != null) {
                          final file = result.files.single;
                          final filePath = file.path!;
                          final fileName = file.name;

                          setState(() {
                            _selectedRingtone = fileName;
                            _customRingtonePath = filePath;
                          });

                          playSound(fileName, customPath: filePath);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      player.stop();
      player.dispose();
    });
  }

  void _saveAlarm() {
    final labelText = _labelController.text.trim();
    final newAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: _selectedTime,
      label: labelText.isEmpty ? 'Alarm' : labelText,
      repeatDays: Set<int>.from(_selectedDays),
      ringtoneName: _selectedRingtone,
      ringtonePath: _customRingtonePath,
      mathMissionEnabled: _mathMissionEnabled,
      mathDifficulty: _mathDifficulty,
      typingMissionEnabled: _typingMissionEnabled,
      typingDifficulty: _typingDifficulty,
      qrMissionEnabled: _qrMissionEnabled,
      vibrationEnabled: _vibrationEnabled,
      volumePercentage: _volumePercentage,
      gradualVolumeEnabled: _gradualVolumeEnabled,
      gradualDurationSeconds: _gradualDurationSeconds,
      snoozeEnabled: _snoozeEnabled,
      snoozeIntervalMinutes: _snoozeIntervalMinutes,
    );

    AlarmStore.instance.addAlarm(newAlarm);

    final formattedTime = _selectedTime.format(context);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for $formattedTime'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final formattedTime = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Alarm'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Display Header
            Center(
              child: InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        formattedTime,
                        style: textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to change time',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Repeat Weekdays
            Text('Repeat', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                final unselectedBg = colorScheme.surfaceContainerHighest;
                final unselectedTextColor = colorScheme.onSurfaceVariant;

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(index);
                      } else {
                        _selectedDays.add(index);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? colorScheme.primary : unselectedBg,
                    ),
                    child: Text(
                      _days[index],
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : unselectedTextColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Alarm Label
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Alarm Label',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 12),

            // Missions Section
            Text('Wake-Up Missions', style: textTheme.titleMedium),
            const SizedBox(height: 8),

            // Maths Mission
            SwitchListTile(
              secondary: const Icon(Icons.calculate_outlined),
              title: const Text('Maths Problem'),
              subtitle: const Text('Solve a maths question to dismiss'),
              value: _mathMissionEnabled,
              onChanged: (val) {
                setState(() {
                  _mathMissionEnabled = val;
                });
              },
            ),
            if (_mathMissionEnabled) ...[
              Padding(
                padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                child: Wrap(
                  spacing: 8,
                  children: ['Easy', 'Medium', 'Hard'].map((level) {
                    final isSelected = _mathDifficulty == level;
                    return ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _mathDifficulty = level;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            // Typing Mission
            SwitchListTile(
              secondary: const Icon(Icons.keyboard_outlined),
              title: const Text('Correct Typing'),
              subtitle: const Text('Type the displayed phrase accurately'),
              value: _typingMissionEnabled,
              onChanged: (val) {
                setState(() {
                  _typingMissionEnabled = val;
                });
              },
            ),
            if (_typingMissionEnabled) ...[
              Padding(
                padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                child: Wrap(
                  spacing: 8,
                  children: ['Easy', 'Medium', 'Hard'].map((level) {
                    final isSelected = _typingDifficulty == level;
                    return ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _typingDifficulty = level;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            // QR Code Mission
            SwitchListTile(
              secondary: const Icon(Icons.qr_code_scanner_outlined),
              title: const Text('QR Code Scan'),
              subtitle: const Text('Scan your registered QR code to dismiss'),
              value: _qrMissionEnabled,
              onChanged: (val) {
                setState(() {
                  _qrMissionEnabled = val;
                });
              },
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Sound & Vibration Section
            Text('Sound & Vibration', style: textTheme.titleMedium),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('Alarm Sound'),
              subtitle: Text(_selectedRingtone),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showRingtonePicker,
            ),

            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: const Text('Vibration'),
              value: _vibrationEnabled,
              onChanged: (val) {
                setState(() {
                  _vibrationEnabled = val;
                });
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Alarm Volume'),
                      Text('${_volumePercentage.toInt()}%'),
                    ],
                  ),
                  Slider(
                    value: _volumePercentage,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${_volumePercentage.toInt()}%',
                    onChanged: (val) {
                      setState(() {
                        _volumePercentage = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('Gradual Volume Increase'),
              subtitle: Text(
                'Start quieter and ramp up over $_gradualDurationSeconds seconds',
              ),
              value: _gradualVolumeEnabled,
              onChanged: (val) {
                setState(() {
                  _gradualVolumeEnabled = val;
                });
              },
            ),
            if (_gradualVolumeEnabled) ...[
              ListTile(
                leading: const SizedBox(width: 24),
                title: const Text('Ramp-up Duration'),
                trailing: DropdownButton<int>(
                  value: _gradualDurationSeconds,
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 seconds')),
                    DropdownMenuItem(value: 30, child: Text('30 seconds')),
                    DropdownMenuItem(value: 45, child: Text('45 seconds')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _gradualDurationSeconds = val;
                      });
                    }
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Snooze Section
            Text('Snooze Settings', style: textTheme.titleMedium),
            const SizedBox(height: 8),

            SwitchListTile(
              secondary: const Icon(Icons.snooze),
              title: const Text('Enable Snooze'),
              subtitle: const Text('Max limit: 3 times'),
              value: _snoozeEnabled,
              onChanged: (val) {
                setState(() {
                  _snoozeEnabled = val;
                });
              },
            ),

            if (_snoozeEnabled) ...[
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Snooze Duration'),
                trailing: DropdownButton<int>(
                  value: _snoozeIntervalMinutes,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _snoozeIntervalMinutes = val;
                      });
                    }
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
