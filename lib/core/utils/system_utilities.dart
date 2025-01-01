import 'package:audioplayers/audioplayers.dart';

const systemUtils = SystemUtilities();

enum SoundAsset {
  placeStone(path: "audio/placeStone.mp3");

  final String path;

  const SoundAsset({required this.path});
}

class SystemUtilities {
  static const String appName = "Go";
  static final AudioPlayer audioPlayer = AudioPlayer();

  DateTime get currentTime => DateTime.now();

  const SystemUtilities();

  Future<void> playSound(SoundAsset asset) async {
    audioPlayer.play(AssetSource(asset.path));
  }
}
