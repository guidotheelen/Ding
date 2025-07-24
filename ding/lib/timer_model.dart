import 'package:flutter/material.dart';
import 'segmented_progress_bar.dart';
import 'sound_service.dart';

enum TimerPhase { prep, round, rest, done }

class TimerModel {
  // Configuration
  final Duration roundLength;
  final Duration restTime;
  final int rounds;
  final Duration prepTime;

  // State
  TimerPhase phase;
  int currentRound;
  Duration timeLeft;
  Duration totalTime;
  bool isRunning;

  TimerModel({
    required this.roundLength,
    required this.restTime,
    required this.rounds,
    required this.prepTime,
    TimerPhase? initialPhase,
    this.currentRound = 1,
    this.isRunning = true,
  })  : timeLeft = prepTime.inMilliseconds > 0 ? prepTime : roundLength,
        totalTime = (prepTime.inMilliseconds > 0 ? prepTime : Duration.zero) +
            roundLength * rounds +
            (restTime.inMilliseconds > 0
                ? restTime * (rounds - 1)
                : Duration.zero),
        phase =
            prepTime.inMilliseconds > 0 ? TimerPhase.prep : TimerPhase.round;

  // Add callback for phase changes and sound triggers
  void Function(TimerPhase newPhase, SoundType? soundToPlay)? onPhaseChange;

  // Move to next phase
  void goToNextPhase() {
    TimerPhase oldPhase = phase;
    SoundType? soundToPlay;
    if (phase == TimerPhase.prep) {
      phase = TimerPhase.round;
      currentRound = 1;
      timeLeft = roundLength;
      soundToPlay = SoundType.ding;
    } else if (phase == TimerPhase.round) {
      if (currentRound < rounds) {
        if (restTime.inMilliseconds == 0) {
          currentRound++;
          timeLeft = roundLength;
          soundToPlay = SoundType.ding;
        } else {
          phase = TimerPhase.rest;
          timeLeft = restTime;
          soundToPlay = SoundType.endbell;
        }
      } else {
        phase = TimerPhase.done;
        timeLeft = Duration.zero;
        soundToPlay = SoundType.ding;
      }
    } else if (phase == TimerPhase.rest) {
      currentRound++;
      phase = TimerPhase.round;
      timeLeft = roundLength;
      soundToPlay = SoundType.ding;
    }
    if (onPhaseChange != null && (oldPhase != phase || soundToPlay != null)) {
      onPhaseChange!(phase, soundToPlay);
    }
  }

  // Move to previous phase
  void goToPreviousPhase() {
    TimerPhase oldPhase = phase;
    SoundType? soundToPlay;
    if (phase == TimerPhase.round) {
      if (currentRound == 1) {
        if (prepTime.inMilliseconds > 0) {
          phase = TimerPhase.prep;
          timeLeft = prepTime;
          soundToPlay = SoundType.ding;
        }
      } else {
        if (restTime.inMilliseconds == 0) {
          currentRound--;
          phase = TimerPhase.round;
          timeLeft = roundLength;
          soundToPlay = SoundType.ding;
        } else {
          phase = TimerPhase.rest;
          currentRound--;
          timeLeft = restTime;
          soundToPlay = SoundType.endbell;
        }
      }
    } else if (phase == TimerPhase.rest) {
      phase = TimerPhase.round;
      timeLeft = roundLength;
      soundToPlay = SoundType.ding;
    } else if (phase == TimerPhase.done) {
      phase = TimerPhase.round;
      currentRound = rounds;
      timeLeft = roundLength;
      soundToPlay = SoundType.ding;
    }
    if (onPhaseChange != null && (oldPhase != phase || soundToPlay != null)) {
      onPhaseChange!(phase, soundToPlay);
    }
  }

  // Tick the timer
  void tick(Duration tickAmount) {
    if (timeLeft > tickAmount) {
      timeLeft -= tickAmount;
    } else {
      timeLeft = Duration.zero;
      goToNextPhase();
    }
  }

  // Build segments for progress bar
  List<Segment> buildSegments() {
    List<Segment> segments = [];
    // Only add preparation if the duration is greater than zero
    if (prepTime.inMilliseconds > 0) {
      segments.add(Segment(duration: prepTime, color: Colors.blueAccent));
    }
    for (int i = 0; i < rounds; i++) {
      segments.add(Segment(duration: roundLength, color: Colors.redAccent));
      // Only add rest after a round if the duration is greater than zero and it's not the last round
      if (i < rounds - 1 && restTime.inMilliseconds > 0) {
        segments.add(Segment(duration: restTime, color: Colors.green));
      }
    }
    return segments;
  }

  // Get color for current phase
  Color getPhaseColor() {
    switch (phase) {
      case TimerPhase.prep:
        return Colors.blueAccent;
      case TimerPhase.round:
        return Colors.redAccent;
      case TimerPhase.rest:
        return Colors.green;
      case TimerPhase.done:
        return Colors.black;
    }
  }

  // Get label for current phase
  String getPhaseLabel() {
    switch (phase) {
      case TimerPhase.prep:
        return 'PREPARE';
      case TimerPhase.round:
        return 'ROUND $currentRound';
      case TimerPhase.rest:
        return 'REST';
      case TimerPhase.done:
        return 'DONE';
    }
  }

  // Calculate remaining milliseconds for progress calculation
  int getRemainingTotalMilliseconds() {
    int ms = timeLeft.inMilliseconds;
    if (phase == TimerPhase.prep) {
      ms += ((roundLength +
                      (restTime.inMilliseconds > 0
                          ? restTime
                          : Duration.zero)) *
                  rounds -
              (restTime.inMilliseconds > 0 ? restTime : Duration.zero))
          .inMilliseconds;
    } else if (phase == TimerPhase.round) {
      if (restTime.inMilliseconds > 0) {
        ms += restTime.inMilliseconds * (rounds - currentRound) +
            roundLength.inMilliseconds * (rounds - currentRound);
      } else {
        ms += roundLength.inMilliseconds * (rounds - currentRound);
      }
    } else if (phase == TimerPhase.rest) {
      // For rest phase, we need to account for remaining rounds correctly
      if (restTime.inMilliseconds > 0) {
        ms += roundLength.inMilliseconds * (rounds - currentRound) +
            restTime.inMilliseconds * (rounds - currentRound - 1);
      }
    }
    return ms;
  }

  // Jump to specific segment
  void jumpToSegment(int segmentIndex) {
    final segments = buildSegments();
    if (segmentIndex >= segments.length) {
      // Safety check if segmentIndex is out of bounds
      return;
    }

    TimerPhase oldPhase = phase;
    SoundType? soundToPlay;
    if (segmentIndex == 0 && prepTime.inMilliseconds > 0) {
      phase = TimerPhase.prep;
      currentRound = 1;
      timeLeft = prepTime;
      soundToPlay = SoundType.ding;
    } else {
      int round = 0;

      // Count how many round segments we've passed
      for (int i = 0; i <= segmentIndex; i++) {
        if (i < segments.length && segments[i].color == Colors.redAccent) {
          round++;
        }
      }

      // Adjust round based on segment type
      if (segments[segmentIndex].color == Colors.redAccent) {
        phase = TimerPhase.round;
        currentRound = round;
        timeLeft = roundLength;
        soundToPlay = SoundType.ding;
      } else if (segments[segmentIndex].color == Colors.green) {
        phase = TimerPhase.rest;
        // For rest segments, the current round is the round we just completed
        currentRound = round;
        timeLeft = restTime;
        soundToPlay = SoundType.endbell;
      } else if (segments[segmentIndex].color == Colors.blueAccent) {
        phase = TimerPhase.prep;
        currentRound = 1;
        timeLeft = prepTime;
        soundToPlay = SoundType.ding;
      }
    }
    if (onPhaseChange != null && (oldPhase != phase || soundToPlay != null)) {
      onPhaseChange!(phase, soundToPlay);
    }
  }
}
