import 'package:audioplayers/audioplayers.dart';

enum SoundType { ding, beep, endbell }

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

  Future<void> play(SoundType type) async {
    await initialize();
    switch (type) {
      case SoundType.ding:
        await _dingPlayer.stop();
        await _dingPlayer.seek(Duration.zero);
        await _dingPlayer.play(AssetSource('sounds/ding.mp3'));
        break;
      case SoundType.beep:
        await _beepPlayer.stop();
        await _beepPlayer.seek(Duration.zero);
        await _beepPlayer.play(AssetSource('sounds/beep_beep.mp3'));
        break;
      case SoundType.endbell:
        await _endbellPlayer.stop();
        await _endbellPlayer.seek(Duration.zero);
        await _endbellPlayer.play(AssetSource('sounds/end_bell.mp3'));
        break;
    }
  }

  void dispose() {
    _dingPlayer.dispose();
    _beepPlayer.dispose();
    _endbellPlayer.dispose();
  }
}
