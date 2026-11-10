import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const _presets = <_TimerPreset>[
    _TimerPreset('1 min', Duration(minutes: 1)),
    _TimerPreset('5 min', Duration(minutes: 5)),
    _TimerPreset('10 min', Duration(minutes: 10)),
    _TimerPreset('15 min', Duration(minutes: 15)),
    _TimerPreset('30 min', Duration(minutes: 30)),
    _TimerPreset('1 hour', Duration(hours: 1)),
  ];

  final _hoursController = TextEditingController(text: '00');
  final _minutesController = TextEditingController(text: '00');
  final _secondsController = TextEditingController(text: '00');

  Duration _remaining = Duration.zero;
  Duration? _selectedPreset;
  DateTime? _deadline;
  Timer? _ticker;
  bool _isRunning = false;
  bool _hasStarted = false;
  bool _isComplete = false;

  bool get _canEdit => !_hasStarted && !_isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Duration _durationFromFields() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void _onDurationChanged() {
    if (!_canEdit) return;
    setState(() {
      _remaining = _durationFromFields();
      _selectedPreset = null;
      _isComplete = false;
    });
  }

  void _setPreset(_TimerPreset preset) {
    if (!_canEdit) return;
    setState(() {
      _selectedPreset = preset.duration;
      _remaining = preset.duration;
      _hoursController.text = preset.duration.inHours.toString().padLeft(
        2,
        '0',
      );
      _minutesController.text = (preset.duration.inMinutes % 60)
          .toString()
          .padLeft(2, '0');
      _secondsController.text = '00';
    });
  }

  void _startOrResume() {
    if (_isRunning) return;
    if (!_hasStarted) {
      final selectedDuration = _durationFromFields();
      if (selectedDuration <= Duration.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a duration greater than zero.')),
        );
        return;
      }
      _remaining = selectedDuration;
    }

    _deadline = DateTime.now().add(_remaining);
    setState(() {
      _isRunning = true;
      _hasStarted = true;
      _isComplete = false;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final deadline = _deadline;
      if (!mounted || deadline == null) return;
      final left = deadline.difference(DateTime.now());
      if (left <= Duration.zero) {
        _ticker?.cancel();
        _ticker = null;
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
          _hasStarted = false;
          _isComplete = true;
        });
        _finishTimer();
      } else {
        setState(() => _remaining = left);
      }
    });
  }

  void _pause() {
    final deadline = _deadline;
    if (!_isRunning || deadline == null) return;
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _remaining = deadline.difference(DateTime.now());
      if (_remaining < Duration.zero) _remaining = Duration.zero;
      _isRunning = false;
    });
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _remaining = Duration.zero;
      _selectedPreset = null;
      _isComplete = false;
      _deadline = null;
      _isRunning = false;
      _hasStarted = false;
      _isComplete = false;
      _hoursController.text = '00';
      _minutesController.text = '00';
      _secondsController.text = '00';
    });
  }

  Future<void> _finishTimer() async {
    await HapticFeedback.vibrate();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.alarm_on_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        title: const Text('Timer complete'),
        content: const Text('Your countdown has finished.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _format(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds ~/ 60) % 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Timer', style: textTheme.titleLarge),
        backgroundColor: colors.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 36,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _format(_remaining),
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      color: _isRunning ? colors.primary : colors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRunning
                        ? 'COUNTING DOWN'
                        : _hasStarted
                        ? 'PAUSED'
                        : _isComplete
                        ? 'COMPLETE'
                        : 'SET YOUR DURATION',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_canEdit) ...[
                    Text('Duration', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DurationField(
                            controller: _hoursController,
                            label: 'Hours',
                            enabled: _canEdit,
                            onChanged: _onDurationChanged,
                          ),
                        ),
                        const _TimeSeparator(),
                        Expanded(
                          child: _DurationField(
                            controller: _minutesController,
                            label: 'Minutes',
                            maxValue: 59,
                            enabled: _canEdit,
                            onChanged: _onDurationChanged,
                          ),
                        ),
                        const _TimeSeparator(),
                        Expanded(
                          child: _DurationField(
                            controller: _secondsController,
                            label: 'Seconds',
                            maxValue: 59,
                            enabled: _canEdit,
                            onChanged: _onDurationChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Quick start', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((preset) {
                        return ChoiceChip(
                          label: Text(preset.label),
                          selected: _selectedPreset == preset.duration,
                          onSelected: (_) => _setPreset(preset),
                        );
                      }).toList(),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHighest
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.play_circle_outline_rounded
                                : Icons.pause_circle_outline_rounded,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isRunning ? 'Running' : 'Paused',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _hasStarted || _isComplete ? _reset : null,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isRunning ? _pause : _startOrResume,
                          icon: Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            _isRunning
                                ? 'Pause'
                                : _hasStarted
                                ? 'Resume'
                                : _isComplete
                                ? 'Start again'
                                : 'Start',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.maxValue,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final int? maxValue;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
        if (maxValue != null) _MaxValueTextInputFormatter(maxValue!),
      ],
      onChanged: (_) => onChanged(),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        labelText: label,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TimerPreset {
  const _TimerPreset(this.label, this.duration);

  final String label;
  final Duration duration;
}

class _MaxValueTextInputFormatter extends TextInputFormatter {
  const _MaxValueTextInputFormatter(this.maxValue);

  final int maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null || value > maxValue) return oldValue;
    return newValue;
  }
}
