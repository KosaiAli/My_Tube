import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../constant.dart';

class VideoFrame extends StatefulWidget {
  const VideoFrame({super.key});

  @override
  State<VideoFrame> createState() => _VideoFrameState();
}

class _VideoFrameState extends State<VideoFrame> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoController>(
      builder: (context, videoController, child) {
        return videoController.controller != null &&
                videoController.controller!.value.isInitialized
            ? VideoPlayer(videoController.controller!)
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Image.file(
                  File(
                      '$kFolderUrlBase/${videoController.videos[videoController.currentVideoIndex].title}.jpg'),
                  fit: BoxFit.cover,
                ),
              );
      },
    );
  }
}
