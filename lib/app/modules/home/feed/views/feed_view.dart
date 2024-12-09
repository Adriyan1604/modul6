import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';

class FeedView extends StatelessWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FeedController controller = Get.put(FeedController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor-Driven Feeds"),
      ),
      body: Column(
        children: [
          // Tombol Tekan & Tahan untuk Rekam
          GestureDetector(
            onLongPress: () async {
              await controller.startRecording();
            },
            onLongPressUp: () async {
              await controller.stopRecording();
            },
            child: Obx(() => Container(
              padding: const EdgeInsets.all(20),
              color: controller.isRecording.value ? Colors.red : Colors.grey,
              child: const Text(
                "Tekan & Tahan untuk Rekam",
                style: TextStyle(color: Colors.white),
              ),
            )),
          ),
          const SizedBox(height: 20),
          // Daftar Rekaman
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.recordings.length,
              itemBuilder: (context, index) {
                final recording = controller.recordings[index];
                return ListTile(
                  title: Text("Rekaman ${index + 1}"),
                  subtitle: Text(recording.path),
                  trailing: Obx(() => IconButton(
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      await controller.playRecording(recording);
                    },
                  )),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
