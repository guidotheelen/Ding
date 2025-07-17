import 'dart:async';
import 'package:flutter/material.dart';
// import 'app_theme.dart';

// Helper class for a segment
class _Segment {
  final Duration duration;
  final Color color;
  _Segment({required this.duration, required this.color});
}

class _SegmentedProgressBar extends StatelessWidget {
  final List<_Segment> segments;
  final double elapsedSeconds;
  final void Function(int segmentIndex)? onSegmentTap;
  const _SegmentedProgressBar({
    required this.segments,
    required this.elapsedSeconds,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    double acc = 0;
    return SizedBox(
      height: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            for (int i = 0; i < segments.length; i++)
              Expanded(
                flex: segments[i].duration.inMilliseconds,
                child: GestureDetector(
                  onTap: onSegmentTap != null ? () => onSegmentTap!(i) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        color: segments[i].color.withOpacity(0.5),
                      ),
                      Builder(builder: (context) {
                        double start = acc;
                        acc += segments[i].duration.inMilliseconds;
                        double fill = (elapsedSeconds * 1000 - start)
                            .clamp(0, segments[i].duration.inMilliseconds)
                            .toDouble();
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: segments[i].duration.inMilliseconds == 0
                              ? 0
                              : fill / segments[i].duration.inMilliseconds,
                          child: Container(
                            height: 16,
                            color: segments[i].color,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// End of _SegmentedProgressBar

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

  List<_Segment> _buildSegments() {
    List<_Segment> segments = [];
    // Preparation
    segments.add(_Segment(duration: widget.prepTime, color: Colors.blueAccent));
    for (int i = 0; i < widget.rounds; i++) {
      segments
          .add(_Segment(duration: widget.roundLength, color: Colors.redAccent));
      if (i < widget.rounds - 1) {
        segments.add(_Segment(duration: widget.restTime, color: Colors.green));
      }
    }
    return segments;
  }

  double _elapsedSeconds() {
    final totalMs = (widget.prepTime +
            (widget.roundLength + widget.restTime) * widget.rounds -
            widget.restTime)
        .inMilliseconds;
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
          widget.restTime.inMilliseconds * (widget.rounds - currentRound + 1);
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Ding Timer', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _phaseColor(),
        child: Center(
          child: phase == TimerPhase.done
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Workout Complete!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ],
                )
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
                    // Segmented progress bar for all rounds
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        child: _SegmentedProgressBar(
                          segments: _buildSegments(),
                          elapsedSeconds: _elapsedSeconds(),
                          onSegmentTap: (int segmentIndex) {
                            _jumpToSegment(segmentIndex);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      alignment: Alignment.center,
                      width: 420,
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
                                fontSize: 40,
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
                    const SizedBox(height: 24),
                    if (phase == TimerPhase.round)
                      Text(
                        'Round $currentRound of ${widget.rounds}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow,
                              size: 36),
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
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(
                            Icons.stop,
                            size: 36,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
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
