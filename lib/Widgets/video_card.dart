import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Models/result.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video});
  final VideoModel video;
  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  IconData getIcon() {
    if (widget.video.existedOnStorage) {
      return Icons.download_done;
    } else if (widget.video.downloading) {
      return Icons.pause;
    }
    return Icons.download;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.video.thumb,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.video.channelTitle!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (widget.video.downloading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: LinearProgressIndicator(
                          value: widget.video.downloaded,
                        ),
                      )
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () async {
                  dataCenter.downloadVideo(widget.video, 'mp4');
                },
                icon: Icon(getIcon()))
          ],
        ),
      );
    });
  }
}
