import 'dart:async';
import 'package:flutter/material.dart';
import 'segmented_progress_bar.dart';
import 'timer_model.dart';
import 'sound_service.dart';

class TimerController {
  // Model
  final TimerModel model;

  // Callback to update UI when state changes
  final Function(void Function()) stateUpdater;

  // Timer for ticking
  Timer? _timer;

  // Sound service
  final SoundService _soundService = SoundService();

  // Sound settings
  final bool enableWhooshSound;

  TimerController({
    required Duration roundLength,
    required Duration restTime,
    required int rounds,
    required Duration prepTime,
    required this.stateUpdater,
    this.enableWhooshSound = true,
  }) : model = TimerModel(
          roundLength: roundLength,
          restTime: restTime,
          rounds: rounds,
          prepTime: prepTime,
        ) {
    model.onPhaseChange = (TimerPhase newPhase, SoundType? soundToPlay) {
      if (soundToPlay != null) {
        _soundService.play(soundToPlay);
      }
    };
  }

  // Getters to expose model properties
  TimerPhase get phase => model.phase;
  int get currentRound => model.currentRound;
  Duration get timeLeft => model.timeLeft;
  Duration get totalTime => model.totalTime;
  bool get isRunning => model.isRunning;

  // Start the timer
  void startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) => _onTick());
  }

  // Track if we've played the warning sound for this round
  bool _playedWarningSound = false;
  static const int _warnBeforeEndSeconds = 10;

  // Timer tick handler
  void _onTick() {
    if (!model.isRunning) return;
    final Duration oldTimeLeft = model.timeLeft;
    stateUpdater(() {
      model.tick(const Duration(milliseconds: 10));
      // Play warning sound 10 seconds before end of round (if enabled)
      if (enableWhooshSound &&
          model.phase == TimerPhase.round &&
          !_playedWarningSound &&
          model.timeLeft.inSeconds <= _warnBeforeEndSeconds &&
          oldTimeLeft.inSeconds > _warnBeforeEndSeconds) {
        _soundService.play(SoundType.beep);
        _playedWarningSound = true;
      }
      // Reset warning sound flag when phase changes
      if (model.phase != TimerPhase.round) {
        _playedWarningSound = false;
      }
    });
  }

  // Navigation methods
  void goToNextRound() {
    stateUpdater(() => model.goToNextPhase());
  }

  void goToPreviousRound() {
    stateUpdater(() => model.goToPreviousPhase());
  }

  void jumpToSegment(int segmentIndex) {
    stateUpdater(() => model.jumpToSegment(segmentIndex));
  }

  // Utility methods
  List<Segment> buildSegments() => model.buildSegments();

  double elapsedSeconds() {
    final segments = model.buildSegments();
    final totalMs =
        segments.fold<int>(0, (sum, seg) => sum + seg.duration.inMilliseconds);
    return (totalMs - model.getRemainingTotalMilliseconds()) / 1000.0;
  }

  String formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = (d.inSeconds.remainder(60)).toString().padLeft(2, '0');
    final ms =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$ms';
  }

  String phaseLabel() => model.getPhaseLabel();

  Color phaseColor() => model.getPhaseColor();

  // Play/Pause control
  void toggleRunning() {
    stateUpdater(() {
      model.isRunning = !model.isRunning;
      if (model.isRunning)
        startTicking();
      else
        _timer?.cancel();
    });
  }

  // Cleanup
  void dispose() {
    _timer?.cancel();
    // No need to dispose of the sound service since it's a singleton
  }
}
