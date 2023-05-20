import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:my_youtube/constant.dart';
import 'package:provider/provider.dart';

import '../Widgets/videoPlayer/video_player.dart' as video_player;

class PlaylistPlayerScreen extends StatefulWidget {
  const PlaylistPlayerScreen({super.key});
  static const routeName = 'PlaylistPlayerScreen';

  @override
  State<PlaylistPlayerScreen> createState() => _PlaylistPlayerScreenState();
}

class _PlaylistPlayerScreenState extends State<PlaylistPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoController>(
      builder: (context, videoController, child) {
        return GestureDetector(
          onTap: () {
            if (videoController.minimized) {
              videoController.minimize();
            }
          },
          child: Container(
            color: videoController.currentPLayListID == null
                ? Colors.transparent
                : kScaffoldColor,
            child: Column(
              children: [
                const video_player.VideoPlayer(),
                if (!videoController.isPanelClosed)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 56),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: videoController.videos.length,
                        itemBuilder: (context, index) {
                          File image = File(
                              '$kFolderUrlBase/${videoController.videos[index].title}.jpg');
                          File file = File(
                              '$kFolderUrlBase/${videoController.videos[index].title}.mp4');

                          return GestureDetector(
                            onTap: () async {
                              if (await file.exists()) {
                                videoController.changeVideo(
                                    videoController.videos[index].videoid);
                              }
                            },
                            child: Container(
                              height: 97,
                              decoration: BoxDecoration(
                                color:
                                    index == videoController.currentVideoIndex
                                        ? Colors.blueGrey.withOpacity(0.5)
                                        : null,
                                border: Border(
                                    bottom: index <
                                            videoController.videos.length - 1
                                        ? BorderSide(
                                            color: Colors.grey.withOpacity(0.6))
                                        : BorderSide.none),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        height: 80,
                                        width: 120,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: FutureBuilder(
                                                future: image.exists(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data!) {
                                                    return Image.file(image);
                                                  }
                                                  return Container();
                                                }))),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            videoController.videos[index].title,
                                          ),
                                          FutureBuilder(
                                            future: file.exists(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  !snapshot.data!) {
                                                return Flexible(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'this video does not exist on your storage',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            color: Colors.red,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Container();
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
