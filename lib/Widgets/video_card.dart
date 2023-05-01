import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Models/video_model.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.id});
  final String id;
  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoModel video;
  late File image;
  @override
  void initState() {
    video = Provider.of<DataCenter>(context, listen: false)
        .videos
        .firstWhere((element) => element.id == widget.id);
    image = File('/storage/emulated/0/Videos/${video.title}.jpg');

    super.initState();
  }

  IconData getIcon() {
    if (video.existedOnStorage) {
      return Icons.download_done;
    } else if (video.videoStatus == Downloadstatus.downloading) {
      return Icons.pause;
    } else if (video.videoStatus == Downloadstatus.inQueue) {
      return Icons.watch_later_outlined;
    }
    return Icons.download;
  }

  @override
  void dispose() {
    super.dispose();
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
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: video.existedOnStorage
                    ? FutureBuilder<bool>(
                        future: image.exists(),
                        builder: (context, snaphot) {
                          if (snaphot.data != null && snaphot.data == true) {
                            // print(value);
                            return Image.file(image);
                          }

                          return GestureDetector(
                              onTap: () async {
                                Dio dio = Dio();
                                await dio
                                    .download(
                                  video.thumb,
                                  '/storage/emulated/0/Videos/${video.title}.jpg',
                                  onReceiveProgress: (count, total) {},
                                )
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: Icon(Icons.download_outlined));
                        },
                      )
                    : Image.network(
                        video.thumb,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 115,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      video.channelTitle!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    if (video.videoStatus == Downloadstatus.downloading)
                      const Spacer(),
                    if (video.videoStatus == Downloadstatus.downloading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: LinearProgressIndicator(
                          value: video.downloaded,
                        ),
                      ),
                    if (video.videoStatus == Downloadstatus.error)
                      const Expanded(
                          child: Text(
                        'something got wrong',
                        style: TextStyle(color: Colors.red),
                      ))
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () async {
                  if (video.videoStatus != Downloadstatus.downloading) {
                    dataCenter.downloadVideo(video, 'mp4');
                    return;
                  }
                  dataCenter.skipItem(video.id);
                },
                icon: Icon(getIcon()))
          ],
        ),
      );
    });
  }
}
