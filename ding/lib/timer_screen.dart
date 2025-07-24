import 'package:flutter/material.dart';
import 'segmented_progress_bar.dart';
import 'done_screen.dart';
import 'timer_controller.dart';
import 'timer_model.dart';

class TimerScreen extends StatefulWidget {
  final Duration roundLength;
  final Duration restTime;
  final int rounds;
  final Duration prepTime;
  final bool enableWhooshSound;

  const TimerScreen({
    super.key,
    required this.roundLength,
    required this.restTime,
    required this.rounds,
    required this.prepTime,
    this.enableWhooshSound = true,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late TimerController controller;

  @override
  void initState() {
    super.initState();
    controller = TimerController(
      roundLength: widget.roundLength,
      restTime: widget.restTime,
      rounds: widget.rounds,
      prepTime: widget.prepTime,
      enableWhooshSound: widget.enableWhooshSound,
      stateUpdater: setState,
    );
    controller.startTicking();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: controller.phaseColor(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: controller.phaseColor(),
        child: Center(
          child: controller.phase == TimerPhase.done
              ? DoneScreen(onBack: () => Navigator.of(context).pop())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.phaseLabel(),
                      style: const TextStyle(
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
                        segments: controller.buildSegments(),
                        elapsedSeconds: controller.elapsedSeconds(),
                        onSegmentTap: (int segmentIndex) {
                          controller.jumpToSegment(segmentIndex);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          controller
                              .formatTime(controller.timeLeft)
                              .substring(0, 5), // mm:ss
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
                            '.${controller.formatTime(controller.timeLeft).substring(6, 8)}', // .ms
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
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
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
                              controller.goToPreviousRound();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              controller.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 36,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              controller.toggleRunning();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
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
                              controller.goToNextRound();
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: const BoxDecoration(
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
