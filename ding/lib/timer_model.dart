import 'package:flutter/material.dart';
import 'segmented_progress_bar.dart';

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

  // Move to next phase
  void goToNextPhase() {
    if (phase == TimerPhase.prep) {
      phase = TimerPhase.round;
      currentRound = 1;
      timeLeft = roundLength;
    } else if (phase == TimerPhase.round) {
      if (currentRound < rounds) {
        // If rest time is zero, skip directly to the next round
        if (restTime.inMilliseconds == 0) {
          currentRound++;
          timeLeft = roundLength;
        } else {
          phase = TimerPhase.rest;
          timeLeft = restTime;
        }
      } else {
        phase = TimerPhase.done;
        timeLeft = Duration.zero;
      }
    } else if (phase == TimerPhase.rest) {
      currentRound++;
      phase = TimerPhase.round;
      timeLeft = roundLength;
    }
  }

  // Move to previous phase
  void goToPreviousPhase() {
    if (phase == TimerPhase.round) {
      if (currentRound == 1) {
        // Only go to prep phase if prep time is not zero
        if (prepTime.inMilliseconds > 0) {
          phase = TimerPhase.prep;
          timeLeft = prepTime;
        }
      } else {
        // If rest time is zero, go to the previous round
        if (restTime.inMilliseconds == 0) {
          currentRound--;
          phase = TimerPhase.round;
          timeLeft = roundLength;
        } else {
          phase = TimerPhase.rest;
          currentRound--;
          timeLeft = restTime;
        }
      }
    } else if (phase == TimerPhase.rest) {
      phase = TimerPhase.round;
      timeLeft = roundLength;
    } else if (phase == TimerPhase.done) {
      phase = TimerPhase.round;
      currentRound = rounds;
      timeLeft = roundLength;
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

    if (segmentIndex == 0 && prepTime.inMilliseconds > 0) {
      phase = TimerPhase.prep;
      currentRound = 1;
      timeLeft = prepTime;
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
      } else if (segments[segmentIndex].color == Colors.green) {
        phase = TimerPhase.rest;
        // For rest segments, the current round is the round we just completed
        currentRound = round;
        timeLeft = restTime;
      } else if (segments[segmentIndex].color == Colors.blueAccent) {
        phase = TimerPhase.prep;
        currentRound = 1;
        timeLeft = prepTime;
      }
    }
  }
}
