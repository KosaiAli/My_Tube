import 'package:flutter/material.dart';
import 'package:my_youtube/data_center.dart';
import 'package:provider/provider.dart';

import '../result.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video});
  final VideoModel video;
  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      widget.video.existedOnStorage
                          ? const Text(
                              'downloaded',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green),
                            )
                          : const Text(
                              'not downloaded',
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
