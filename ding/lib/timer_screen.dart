import 'dart:async';
import 'package:flutter/material.dart';
import 'segmented_progress_bar.dart';
import 'done_screen.dart';

// ...existing code...

class TimerScreen extends StatefulWidget {
  final Duration roundLength;
  final Duration restTime;
  final int rounds;
  final Duration prepTime;

  const TimerScreen({
    super.key,
    required this.roundLength,
    required this.restTime,
    required this.rounds,
    required this.prepTime,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

enum TimerPhase { prep, round, rest, done }

class _TimerScreenState extends State<TimerScreen> {
  void _goToNextRound() {
    setState(() {
      if (phase == TimerPhase.prep) {
        phase = TimerPhase.round;
        currentRound = 1;
        timeLeft = widget.roundLength;
      } else if (phase == TimerPhase.round) {
        if (currentRound < widget.rounds) {
          phase = TimerPhase.rest;
          timeLeft = widget.restTime;
        } else {
          phase = TimerPhase.done;
          timeLeft = Duration.zero;
        }
      } else if (phase == TimerPhase.rest) {
        currentRound++;
        phase = TimerPhase.round;
        timeLeft = widget.roundLength;
      }
    });
  }

  void _goToPreviousRound() {
    setState(() {
      if (phase == TimerPhase.round) {
        if (currentRound == 1) {
          phase = TimerPhase.prep;
          timeLeft = widget.prepTime;
        } else {
          phase = TimerPhase.rest;
          currentRound--;
          timeLeft = widget.restTime;
        }
      } else if (phase == TimerPhase.rest) {
        phase = TimerPhase.round;
        timeLeft = widget.roundLength;
      } else if (phase == TimerPhase.done) {
        phase = TimerPhase.round;
        currentRound = widget.rounds;
        timeLeft = widget.roundLength;
      }
    });
  }

  void _jumpToSegment(int segmentIndex) {
    final segments = _buildSegments();
    setState(() {
      if (segmentIndex == 0) {
        phase = TimerPhase.prep;
        currentRound = 1;
        timeLeft = widget.prepTime;
      } else {
        int seg = 1;
        int round = 1;
        while (seg < segmentIndex) {
          if (segments[seg].color == Colors.redAccent) {
            round++;
          }
          seg++;
        }
        if (segments[segmentIndex].color == Colors.redAccent) {
          phase = TimerPhase.round;
          currentRound = round;
          timeLeft = widget.roundLength;
        } else if (segments[segmentIndex].color == Colors.green) {
          phase = TimerPhase.rest;
          currentRound = round;
          timeLeft = widget.restTime;
        } else if (segments[segmentIndex].color == Colors.blueAccent) {
          phase = TimerPhase.prep;
          currentRound = 1;
          timeLeft = widget.prepTime;
        }
      }
    });
  }

  List<Segment> _buildSegments() {
    List<Segment> segments = [];
    // Preparation
    segments.add(Segment(duration: widget.prepTime, color: Colors.blueAccent));
    for (int i = 0; i < widget.rounds; i++) {
      segments
          .add(Segment(duration: widget.roundLength, color: Colors.redAccent));
      // Always add a rest after a round, except after the last round
      if (i < widget.rounds - 1) {
        segments.add(Segment(duration: widget.restTime, color: Colors.green));
      }
    }
    return segments;
  }

  double _elapsedSeconds() {
    // Calculate total duration by summing all segment durations
    final segments = _buildSegments();
    final totalMs =
        segments.fold<int>(0, (sum, seg) => sum + seg.duration.inMilliseconds);
    return (totalMs - _remainingTotalMilliseconds()) / 1000.0;
  }

  int _remainingTotalMilliseconds() {
    int ms = timeLeft.inMilliseconds;
    if (phase == TimerPhase.prep) {
      ms += ((widget.roundLength + widget.restTime) * widget.rounds -
              widget.restTime)
          .inMilliseconds;
    } else if (phase == TimerPhase.round) {
      ms += widget.restTime.inMilliseconds * (widget.rounds - currentRound) +
          widget.roundLength.inMilliseconds * (widget.rounds - currentRound);
    } else if (phase == TimerPhase.rest) {
      ms += widget.roundLength.inMilliseconds * (widget.rounds - currentRound) +
          widget.restTime.inMilliseconds * (widget.rounds - currentRound - 1);
    }
    return ms;
  }

  late TimerPhase phase;
  late int currentRound;
  late Duration timeLeft;
  late Duration totalTime;
  bool isRunning = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    phase = TimerPhase.prep;
    currentRound = 1;
    timeLeft = widget.prepTime;
    totalTime = widget.prepTime +
        (widget.roundLength + widget.restTime) * widget.rounds -
        widget.restTime;
    _startTicking();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) => _onTick());
  }

  void _onTick() {
    if (!isRunning) return;
    setState(() {
      if (timeLeft > Duration.zero) {
        timeLeft -= const Duration(milliseconds: 10);
        if (timeLeft < Duration.zero) timeLeft = Duration.zero;
      } else {
        switch (phase) {
          case TimerPhase.prep:
            phase = TimerPhase.round;
            timeLeft = widget.roundLength;
            break;
          case TimerPhase.round:
            if (currentRound < widget.rounds) {
              phase = TimerPhase.rest;
              timeLeft = widget.restTime;
            } else {
              phase = TimerPhase.done;
              timeLeft = Duration.zero;
            }
            break;
          case TimerPhase.rest:
            currentRound++;
            phase = TimerPhase.round;
            timeLeft = widget.roundLength;
            break;
          case TimerPhase.done:
            isRunning = false;
            _timer?.cancel();
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    // Always produce a fixed-width string: 00:00.00
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = (d.inSeconds.remainder(60)).toString().padLeft(2, '0');
    final ms =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$ms';
  }

  String _phaseLabel() {
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

  Color _phaseColor() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _phaseColor(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _phaseColor(),
        child: Center(
          child: phase == TimerPhase.done
              ? DoneScreen(onBack: () => Navigator.of(context).pop())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _phaseLabel(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Simplified segmented progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SegmentedProgressBar(
                        segments: _buildSegments(),
                        elapsedSeconds: _elapsedSeconds(),
                        onSegmentTap: (int segmentIndex) {
                          _jumpToSegment(segmentIndex);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _format(timeLeft).substring(0, 5), // mm:ss
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RobotoMono',
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(
                            width: 60, // Fixed width for ms
                            child: Text(
                              '.${_format(timeLeft).substring(6, 8)}', // .ms
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoMono',
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_left,
                              size: 36,
                              color: Colors.white,
                            ),
                            tooltip: 'Previous',
                            onPressed: () {
                              _goToPreviousRound();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isRunning ? Icons.pause : Icons.play_arrow,
                              size: 36,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isRunning = !isRunning;
                                if (isRunning)
                                  _startTicking();
                                else
                                  _timer?.cancel();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_right,
                              size: 36,
                              color: Colors.white,
                            ),
                            tooltip: 'Next',
                            onPressed: () {
                              _goToNextRound();
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.stop,
                              size: 36,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
