import 'package:flutter/material.dart';
import 'setting_row.dart';
import 'app_theme.dart';
import 'timer_screen.dart';

void main() {
  runApp(const DingApp());
}

class DingApp extends StatelessWidget {
  const DingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ding - Boxing Round Timer',
      theme: AppTheme.theme,
      home: const DingHomePage(),
    );
  }
}

class DingHomePage extends StatefulWidget {
  const DingHomePage({super.key});

  @override
  State<DingHomePage> createState() => _DingHomePageState();
}

class _DingHomePageState extends State<DingHomePage> {
  Duration roundLength = const Duration(minutes: 1);
  Duration restTime = const Duration(minutes: 1);
  int rounds = 6;
  Duration prepTime = const Duration(seconds: 15);
  int switchDuringRound = 0; // 0 = None
  final List<String> switchOptions = ['None', '1', '2', '3', '4'];

  void _changeDuration(
      Duration current, int seconds, void Function(Duration) setter) {
    final newSeconds = current.inSeconds + seconds;
    if (newSeconds > 0 && newSeconds <= 60 * 60) {
      setter(Duration(seconds: newSeconds));
    }
  }

  void _changeRounds(int delta) {
    setState(() {
      rounds = (rounds + delta).clamp(1, 99);
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = (d.inSeconds.remainder(60)).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBg,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        title: Text(
          'DING! 🥊',
          style: TextStyle(
            fontSize: 30,
            fontWeight: AppTheme.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: AppTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingRow(
              label: 'Round Length',
              value: _formatDuration(roundLength),
              onMinus: () => setState(() =>
                  _changeDuration(roundLength, -10, (d) => roundLength = d)),
              onPlus: () => setState(() =>
                  _changeDuration(roundLength, 10, (d) => roundLength = d)),
            ),

            const SizedBox(height: 12),

            SettingRow(
              label: 'Rest Time',
              value: _formatDuration(restTime),
              onMinus: () => setState(
                  () => _changeDuration(restTime, -10, (d) => restTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(restTime, 10, (d) => restTime = d)),
            ),

            const SizedBox(height: 12),

            SettingRow(
              label: 'Rounds',
              value: rounds.toString(),
              onMinus: () => _changeRounds(-1),
              onPlus: () => _changeRounds(1),
            ),

            const SizedBox(height: 12),

            SettingRow(
              label: 'Preparation Time',
              value: _formatDuration(prepTime),
              onMinus: () => setState(
                  () => _changeDuration(prepTime, -5, (d) => prepTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(prepTime, 5, (d) => prepTime = d)),
            ),

            const Spacer(),

            // Workout summary
            Card(
              elevation: AppTheme.cardElevation,
              color: AppTheme.darkCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'TOTAL WORKOUT TIME',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: AppTheme.semiBold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(prepTime +
                          roundLength * rounds +
                          restTime * (rounds - 1)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Start button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonBg,
                foregroundColor: AppTheme.buttonText,
                elevation: AppTheme.buttonElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TimerScreen(
                      roundLength: roundLength,
                      restTime: restTime,
                      rounds: rounds,
                      prepTime: prepTime,
                    ),
                  ),
                );
              },
              child: Text(
                '💥🥊',
                style: TextStyle(
                  fontSize: AppTheme.startButtonFontSize,
                  fontWeight: AppTheme.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
