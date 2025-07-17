import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _dingPlayer = AudioPlayer();
  final AudioPlayer _whooshPlayer = AudioPlayer();
  bool _initialized = false;

  // Singleton pattern
  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> initialize() async {
    if (!_initialized) {
      await _dingPlayer.setSourceAsset('sounds/ding.mp3');
      await _whooshPlayer.setSourceAsset('sounds/whoosh.mp3');
      _initialized = true;
    }
  }

  Future<void> playDing() async {
    await initialize();
    await _dingPlayer.stop();
    await _dingPlayer.seek(Duration.zero);
    await _dingPlayer.play(AssetSource('sounds/ding.mp3'));
  }

  Future<void> playWhoosh() async {
    await initialize();
    await _whooshPlayer.stop();
    await _whooshPlayer.seek(Duration.zero);
    await _whooshPlayer.play(AssetSource('sounds/whoosh.mp3'));
  }

  void dispose() {
    _dingPlayer.dispose();
    _whooshPlayer.dispose();
  }
}
