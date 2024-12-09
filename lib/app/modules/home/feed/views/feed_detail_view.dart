// file: feed_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart'; // Pastikan file yang benar diimpor

class FeedDetailView extends StatefulWidget {
  final Feed feed; // Menggunakan kelas Feed yang diimpor

  const FeedDetailView({Key? key, required this.feed}) : super(key: key);

  @override
  _FeedDetailViewState createState() => _FeedDetailViewState();
}

class _FeedDetailViewState extends State<FeedDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Feed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan media
            if (widget.feed.media != null)
              widget.feed.mediaType == "image"
                  ? Image.file(widget.feed.media!)
                  : widget.feed.mediaType == "audio"
                  ? Text("File audio: ${widget.feed.media!.path}")
                  : Text("Media tidak didukung"),
            const SizedBox(height: 16),
            // Menampilkan pesan feed
            Text(
              widget.feed.message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
