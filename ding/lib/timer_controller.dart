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
        );

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

    // Play the ding sound only when starting a round (not during preparation)
    if (model.phase == TimerPhase.round) {
      _soundService.play(SoundType.ding);
    }
  }

  // Track if we've played the warning sound for this round
  bool _playedWarningSound = false;
  static const int _warnBeforeEndSeconds = 10;

  // Timer tick handler
  void _onTick() {
    if (!model.isRunning) return;

    // Store current phase before updating
    final currentPhase = model.phase;
    final int oldRound = model.currentRound;
    final Duration oldTimeLeft = model.timeLeft;

    stateUpdater(() {
      model.tick(const Duration(milliseconds: 10));

      // Play sound if phase changed
      if (currentPhase != model.phase) {
        // Reset warning sound flag when phase changes
        _playedWarningSound = false;

        // Play the ding sound specifically at the start of a round
        if (model.phase == TimerPhase.round) {
          _soundService.play(SoundType.ding); // Play sound at start of round
        } else if (model.phase == TimerPhase.rest) {
          _soundService
              .play(SoundType.endbell); // Play endbell at start of rest
        } else if (model.phase == TimerPhase.done) {
          // Play endbell three times after the last round
          Future(() async {
            for (int i = 0; i < 3; i++) {
              await _soundService.play(SoundType.endbell);
              if (i < 2)
                await Future.delayed(const Duration(milliseconds: 400));
            }
          });
        }
      } else {
        // Handle round-to-round transition when rest time is zero (phase stays 'round')
        if (model.phase == TimerPhase.round && model.currentRound != oldRound) {
          _playedWarningSound = false; // reset warning for new round
          _soundService.play(SoundType.ding);
        }
      }

      // Play warning sound 10 seconds before end of round (if enabled)
      if (enableWhooshSound &&
          model.phase == TimerPhase.round &&
          !_playedWarningSound &&
          model.timeLeft.inSeconds <= _warnBeforeEndSeconds &&
          oldTimeLeft.inSeconds > _warnBeforeEndSeconds) {
        _soundService.play(SoundType.beep);
        _playedWarningSound = true;
      }
    });
  }

  // Navigation methods
  void goToNextRound() {
    final prevPhase = model.phase;
    final prevRound = model.currentRound;
    stateUpdater(() => model.goToNextPhase());

    // Play ding sound if we've entered a round phase or advanced to the next round without a phase change
    if (model.phase == TimerPhase.round &&
        (prevPhase != model.phase || model.currentRound != prevRound)) {
      _soundService.play(SoundType.ding);
    }
  }

  void goToPreviousRound() {
    final prevPhase = model.phase;
    final prevRound = model.currentRound;
    stateUpdater(() => model.goToPreviousPhase());

    // Play ding sound if we've entered a round phase or changed rounds without a phase change
    if (model.phase == TimerPhase.round &&
        (prevPhase != model.phase || model.currentRound != prevRound)) {
      _soundService.play(SoundType.ding);
    }
  }

  void jumpToSegment(int segmentIndex) {
    final prevPhase = model.phase;
    final prevRound = model.currentRound;
    stateUpdater(() => model.jumpToSegment(segmentIndex));

    // Play ding sound if we've entered a round phase or changed rounds
    if (model.phase == TimerPhase.round &&
        (prevPhase != model.phase || model.currentRound != prevRound)) {
      _soundService.play(SoundType.ding);
    }
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
