import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Models/video_model.dart';
import '../constant.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.id, required this.icon});
  final String id;
  final Widget icon;
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
        .firstWhere((element) => element.videoid == widget.id);

    image = File('$kFolderUrlBase/${video.title}.jpg');

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return SizedBox(
        height: kVideoCardSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: kVideoCardSize,
              height: kVideoCardSize,
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
                                  '$kFolderUrlBase/${video.title}.jpg',
                                  onReceiveProgress: (count, total) {},
                                )
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: const Icon(Icons.download_outlined));
                        },
                      )
                    : Image.network(
                        video.thumb,
                      ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Text(video.channelTitle!,
                      style: Theme.of(context).textTheme.bodySmall),
                  if (video.videoStatus == Downloadstatus.downloading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: LinearProgressIndicator(
                        value: video.downloaded,
                      ),
                    ),
                  if (video.videoStatus == Downloadstatus.error)
                    const Text(
                      'something got wrong',
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
            ),
            widget.icon
          ],
        ),
      );
    });
  }
}
