// import 'package:just_audio/just_audio.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ja;

final systemUtils = SystemUtilities();

enum SoundAsset {
  placeStone(path: "audio/placeStone3.ogg"),
  // clickCut(path: "audio/interface/click_cut.ogg"),
  message(path: "audio/interface/message.ogg");

  final String path;

  const SoundAsset({required this.path});
}

class SystemUtilities {
  static const String appName = "Go";
  static final AudioPlayer audioPlayer = AudioPlayer();
  static final ja.AudioPlayer jaAudio = ja.AudioPlayer();

  DateTime get currentTime => DateTime.now();

  SystemUtilities() {
    // for (var asset in SoundAsset.values) {
    //   players.add(AudioPlayer()..setSourceAsset(asset.path));
    // }
  }
  List<AudioPlayer> players = [];

  Future<void> playSound(SoundAsset asset) async {
    await audioPlayer.stop();
    audioPlayer.play(AssetSource(asset.path));
    // audioPlayer.play(AssetSource(asset.path));
    // players[asset.index].resume();
  }
}
