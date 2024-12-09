import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
// file: feed_controller.dart
import 'dart:io';

class Feed {
  final String message;
  final File? media;
  final String mediaType;

  Feed({required this.message, this.media, required this.mediaType});
}



class FeedController extends GetxController {
  late FlutterSoundRecorder _audioRecorder;
  late FlutterSoundPlayer _audioPlayer;
  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;
  RxList<File> recordings = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      print("Gagal menginisialisasi perekam: $e");
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.openPlayer();
    } catch (e) {
      print("Gagal menginisialisasi pemutar: $e");
    }
  }

  Future<void> startRecording() async {
    if (!_audioRecorder.isRecording) {
      try {
        isRecording.value = true;
        final tempFile = File("${DateTime.now().millisecondsSinceEpoch}.aac");
        await _audioRecorder.startRecorder(toFile: tempFile.path);
      } catch (e) {
        print("Gagal memulai rekaman: $e");
        isRecording.value = false;
      }
    }
  }

  Future<void> stopRecording() async {
    if (_audioRecorder.isRecording) {
      try {
        String? path = await _audioRecorder.stopRecorder();
        if (path != null) {
          recordings.add(File(path));
        }
        isRecording.value = false;
      } catch (e) {
        print("Gagal menghentikan rekaman: $e");
      }
    }
  }

  Future<void> playRecording(File file) async {
    if (!isPlaying.value) {
      try {
        isPlaying.value = true;
        await _audioPlayer.startPlayer(fromURI: file.path, codec: Codec.aacADTS);
        // Pemutaran selesai
        isPlaying.value = false; // Set nilai false setelah selesai
      } catch (e) {
        print("Gagal memutar audio: $e");
        isPlaying.value = false;
      }
    } else {
      await stopPlaying();
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _audioPlayer.stopPlayer();
      isPlaying.value = false;
    } catch (e) {
      print("Gagal menghentikan audio: $e");
    }
  }

  @override
  void onClose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.onClose();
  }
}
