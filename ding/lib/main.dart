import 'package:flutter/material.dart';
import 'setting_row.dart';
import 'app_theme.dart';
import 'timer_screen.dart';
import 'sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sound service
  final soundService = SoundService();
  await soundService.initialize();

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
  bool enableWhooshSound = true; // Switch for whoosh sound

  void _changeDuration(
      Duration current, int seconds, void Function(Duration) setter) {
    final newSeconds = current.inSeconds + seconds;
    if (newSeconds >= 0 && newSeconds <= 60 * 60) {
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
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
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

            const SizedBox(height: 8),

            SettingRow(
              label: 'Rest Time',
              value: _formatDuration(restTime),
              onMinus: () => setState(
                  () => _changeDuration(restTime, -10, (d) => restTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(restTime, 10, (d) => restTime = d)),
            ),

            const SizedBox(height: 8),

            SettingRow(
              label: 'Rounds',
              value: rounds.toString(),
              onMinus: () => _changeRounds(-1),
              onPlus: () => _changeRounds(1),
            ),

            const SizedBox(height: 8),

            SettingRow(
              label: 'Preparation Time',
              value: _formatDuration(prepTime),
              onMinus: () => setState(
                  () => _changeDuration(prepTime, -5, (d) => prepTime = d)),
              onPlus: () => setState(
                  () => _changeDuration(prepTime, 5, (d) => prepTime = d)),
            ),

            const SizedBox(height: 8),

            // Whoosh Sound Setting
            Card(
              elevation: AppTheme.cardElevation,
              color: AppTheme.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enableWhooshSound ? "ON" : "OFF",
                          style: TextStyle(
                            fontSize: AppTheme.settingValueFontSize,
                            fontWeight: AppTheme.bold,
                            color: AppTheme.settingValue,
                          ),
                        ),
                        Text(
                          "10 Second Whoosh",
                          style: TextStyle(
                            fontSize: AppTheme.settingLabelFontSize,
                            color: AppTheme.settingLabel,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: enableWhooshSound,
                      activeColor: AppTheme.buttonBg,
                      onChanged: (value) {
                        setState(() {
                          enableWhooshSound = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Workout summary
            Card(
              elevation: AppTheme.cardElevation,
              color: AppTheme.darkCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      'TOTAL WORKOUT TIME',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: AppTheme.semiBold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDuration((prepTime.inMilliseconds > 0
                              ? prepTime
                              : Duration.zero) +
                          roundLength * rounds +
                          (restTime.inMilliseconds > 0
                              ? restTime * (rounds - 1)
                              : Duration.zero)),
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

            const SizedBox(height: 8),

            // Start button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonBg,
                foregroundColor: AppTheme.buttonText,
                elevation: AppTheme.buttonElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TimerScreen(
                      roundLength: roundLength,
                      restTime: restTime,
                      rounds: rounds,
                      prepTime: prepTime,
                      enableWhooshSound: enableWhooshSound,
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

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
