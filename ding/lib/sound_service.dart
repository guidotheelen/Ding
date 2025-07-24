import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _dingPlayer = AudioPlayer();
  final AudioPlayer _beepPlayer = AudioPlayer();
  final AudioPlayer _endbellPlayer = AudioPlayer();
  bool _initialized = false;

  // Singleton pattern
  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> initialize() async {
    if (!_initialized) {
      await _dingPlayer.setSourceAsset('sounds/ding.mp3');
      await _beepPlayer.setSourceAsset('sounds/beep_beep.mp3');
      await _endbellPlayer.setSourceAsset('sounds/end_bell.mp3');
      _initialized = true;
    }
  }

  Future<void> playDing() async {
    await initialize();
    await _dingPlayer.stop();
    await _dingPlayer.seek(Duration.zero);
    await _dingPlayer.play(AssetSource('sounds/ding.mp3'));
  }

  Future<void> playBeep() async {
    await initialize();
    await _beepPlayer.stop();
    await _beepPlayer.seek(Duration.zero);
    await _beepPlayer.play(AssetSource('sounds/beep_beep.mp3'));
  }

  Future<void> playEndbell() async {
    await initialize();
    await _endbellPlayer.stop();
    await _endbellPlayer.seek(Duration.zero);
    await _endbellPlayer.play(AssetSource('sounds/end_bell.mp3'));
  }

  void dispose() {
    _dingPlayer.dispose();
    _beepPlayer.dispose();
    _endbellPlayer.dispose();
  }
}
