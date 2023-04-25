import 'dart:async';
import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:video_player/video_player.dart';

class VideoPLayerScreen extends StatefulWidget {
  const VideoPLayerScreen({super.key});

  @override
  State<VideoPLayerScreen> createState() => _VideoPLayerScreenState();
}

class _VideoPLayerScreenState extends State<VideoPLayerScreen> {
  late VideoPlayerController videoPlayerController;
  bool filePicked = false;
  final List<String> videos = [];
  @override
  void initState() {
    printAllvideos('/storage/emulated/0/');
    super.initState();
  }

  Future<void> printAllvideos(String path) async {
    var dirs = Directory(path).listSync();

    for (var element in dirs) {
      if (FileManager.isFile(element)) {
        if (FileManager.getFileExtension(element) == 'mp4') {
          videos.add(element.path);
          print(element.path);
        }
        continue;
      }
      printAllvideos(element.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          File file = File(videos[index]);

          var laste = file.path.lastIndexOf(Platform.pathSeparator);

          var name = file.path.substring(laste + 1);
          return Container(
            height: 200,
            child: Text(name),
          );
        },
      ),
    );
    // return Scaffold(
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       filePicked && videoPlayerController.value.isInitialized
    //           ? AspectRatio(
    //               aspectRatio: videoPlayerController.value.aspectRatio,
    //               child: VideoPlayer(videoPlayerController),
    //             )
    //           : Container(),
    //       Center(
    //         child: ElevatedButton(
    //             onPressed: () async {
    //               File file = File(
    //                 '/storage/emulated/0/Main/Queen – Bohemian Rhapsody (Official Video Remastered).mp4',
    //               );
    //               Directory dir = Directory('/storage/emulated/0/Download');

    //               print(file.path);
    //               videoPlayerController = VideoPlayerController.file(file)
    //                 ..initialize().then((value) {
    //                   setState(() {
    //                     filePicked = true;
    //                   });
    //                 });

    //               print(videoPlayerController.value.duration);
    //             },
    //             child: Text('pick')),
    //       ),
    //       SizedBox(
    //         height: 20,
    //       ),
    //       ElevatedButton(
    //           onPressed: () async {
    //             await videoPlayerController.pause().then((value) {});
    //           },
    //           child: Icon(Icons.play_arrow))
    //     ],
    //   ),
    // );
    // ;
  }
}
