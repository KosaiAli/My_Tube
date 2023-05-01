import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../Widgets/playlist_card.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return Scaffold(
        backgroundColor: Colors.grey[800],
        body: ListView.builder(
          itemCount: dataCenter.playlists.length,
          itemBuilder: (context, index) {
            return PlayListCard(
              id: dataCenter.playlists[index].id,
            );
          },
        ),
      );
    });
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
