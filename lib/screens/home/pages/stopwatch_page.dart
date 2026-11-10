import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = <Duration>[];
  Timer? _ticker;

  bool get _isRunning => _stopwatch.isRunning;
  Duration get _elapsed => _stopwatch.elapsed;
  Duration get _lapElapsed =>
      _laps.isEmpty ? _elapsed : _elapsed - _laps.first;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startOrResume() {
    setState(_stopwatch.start);
    _ticker ??= Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted && _isRunning) setState(() {});
    });
  }

  void _pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    setState(() {});
  }

  void _recordLap() {
    if (!_isRunning) return;
    setState(() => _laps.insert(0, _elapsed));
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _stopwatch
        ..stop()
        ..reset();
      _laps.clear();
    });
  }

  String _format(Duration duration, {bool includeHours = true}) {
    final centiseconds = duration.inMilliseconds ~/ 10;
    final hundredths = centiseconds % 100;
    final seconds = (centiseconds ~/ 100) % 60;
    final minutes = (centiseconds ~/ 6000) % 60;
    final hours = centiseconds ~/ 360000;
    final clock = includeHours || hours > 0
        ? '${hours.toString().padLeft(2, '0')}:'
        : '';
    return '$clock${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch', style: textTheme.titleLarge),
        backgroundColor: colors.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.timer_rounded,
                        size: 38,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _format(_elapsed),
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? 'STOPWATCH RUNNING' : 'ELAPSED TIME',
                      style: textTheme.labelSmall?.copyWith(
                        color: _isRunning
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeSummary(
                            label: 'TOTAL',
                            value: _format(_elapsed),
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeSummary(
                            label: 'LAP',
                            value: _format(_lapElapsed),
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _elapsed == Duration.zero ? null : _reset,
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
                            label: Text(_isRunning ? 'Pause' : 'Start'),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: _isRunning ? _recordLap : null,
                        icon: const Icon(Icons.flag_rounded),
                        label: const Text('Record lap'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text('Laps', style: textTheme.titleMedium),
                        const Spacer(),
                        Text(
                          _laps.length.toString() +
                              (_laps.length == 1 ? ' lap' : ' laps'),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_laps.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.surfaceContainerHighest
                              : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your lap times will appear here',
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...List<Widget>.generate(_laps.length, (index) {
                        final lapNumber = _laps.length - index;
                        final lapDuration = index == _laps.length - 1
                            ? _laps[index]
                            : _laps[index] - _laps[index + 1];
                        return _LapRow(
                          number: lapNumber,
                          duration: _format(lapDuration),
                          total: _format(_laps[index]),
                          isLatest: index == 0,
                          colors: colors,
                          textTheme: textTheme,
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimeSummary extends StatelessWidget {
  const _TimeSummary({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LapRow extends StatelessWidget {
  const _LapRow({
    required this.number,
    required this.duration,
    required this.total,
    required this.isLatest,
    required this.colors,
    required this.textTheme,
  });

  final int number;
  final String duration;
  final String total;
  final bool isLatest;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isLatest ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            'Lap ${number.toString().padLeft(2, '0')}',
            style: textTheme.bodyMedium?.copyWith(
              color: isLatest ? colors.onPrimaryContainer : colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: textTheme.bodyLarge?.copyWith(
                  color: isLatest ? colors.onPrimaryContainer : colors.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total $total',
                style: textTheme.bodySmall?.copyWith(
                  color: isLatest
                      ? colors.onPrimaryContainer.withValues(alpha: 0.75)
                      : colors.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
