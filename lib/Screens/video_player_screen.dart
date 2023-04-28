import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../Models/database.dart';

class VideoPLayerScreen extends StatefulWidget {
  const VideoPLayerScreen({super.key});

  @override
  State<VideoPLayerScreen> createState() => _VideoPLayerScreenState();
}

class _VideoPLayerScreenState extends State<VideoPLayerScreen> {
  late VideoPlayerController videoPlayerController;
  bool filePicked = false;
  List videos = [];
  @override
  void initState() {
    printAllvideos('/storage/emulated/0/');
    super.initState();
  }

  Future<void> printAllvideos(String path) async {
    // var dirs = Directory(path).listSync();

    // for (var element in dirs) {
    //   if (FileManager.isFile(element)) {
    //     if (FileManager.getFileExtension(element) == 'mp4') {
    //       videos.add(element.path);
    //       print(element.path);
    //     }
    //     continue;
    //   }
    //   printAllvideos(element.path);
    // }
    videos = await VideoDataBase.instance.fetchPlaylists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 200,
            child: Text(videos[index]['Name']),
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
