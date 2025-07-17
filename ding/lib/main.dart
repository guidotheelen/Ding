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

  void _changeSwitch(int delta) {
    setState(() {
      switchDuringRound =
          (switchDuringRound + delta).clamp(0, switchOptions.length - 1);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: AppTheme.appBarBg,
          child: SafeArea(
            child: Padding(
              padding: AppTheme.appBarPadding,
              child: Text(
                'DING! 🥊',
                style: TextStyle(
                  color: AppTheme.appBarText,
                  fontWeight: AppTheme.bold,
                  fontSize: AppTheme.appBarFontSize,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: AppTheme.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: 16),
            SettingRow(
              label: 'Round Length',
              value: _formatDuration(roundLength),
              onMinus: () => setState(() =>
                  _changeDuration(roundLength, -10, (d) => roundLength = d)),
              onPlus: () => setState(() =>
                  _changeDuration(roundLength, 10, (d) => roundLength = d)),
            ),
            Divider(color: AppTheme.divider),
            SettingRow(
              label: 'Rest Time',
              value: _formatDuration(restTime),
              onMinus: () => setState(
                  () => _changeDuration(restTime, -10, (d) => restTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(restTime, 10, (d) => restTime = d)),
            ),
            Divider(color: AppTheme.divider),
            SettingRow(
              label: 'Rounds',
              value: rounds.toString(),
              onMinus: () => _changeRounds(-1),
              onPlus: () => _changeRounds(1),
            ),
            Divider(color: AppTheme.divider),
            SettingRow(
              label: 'Preparation time',
              value: _formatDuration(prepTime),
              onMinus: () => setState(
                  () => _changeDuration(prepTime, -5, (d) => prepTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(prepTime, 5, (d) => prepTime = d)),
            ),
            Divider(color: AppTheme.divider),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: AppTheme.buttonBorder, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius)),
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
                child: Text('START',
                    style: TextStyle(
                        fontSize: AppTheme.startButtonFontSize,
                        fontWeight: AppTheme.bold,
                        color: AppTheme.buttonText)),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
