import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Screens/playlist_player_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import '../Models/video_controller.dart';
import '../Widgets/playlist_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'HomeScreen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController videoPlayerController;
  bool filePicked = false;
  List videos = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mdeiaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Consumer<DataCenter>(
        builder: (context, dataCenter, child) {
          return Consumer<VideoController>(
            builder: (context, videoController, child) {
              return Scaffold(
                backgroundColor: const Color(0xFF212121),
                body: SizedBox(
                  height: mdeiaQuery.size.height - mdeiaQuery.viewPadding.top,
                  child: SlidingUpPanel(
                    isDraggable: false,
                    controller: videoController.panelController,
                    panel: videoController.currentPLayListID == null
                        ? Container()
                        : const PlaylistPlayerScreen(),
                    minHeight: videoController.currentPLayListID == null
                        ? 0
                        : 70 + kBottomNavigationBarHeight,
                    maxHeight: MediaQuery.of(context).size.height,
                    body: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: dataCenter.playlists.length,
                      itemBuilder: (context, index) {
                        return PlayListCard(
                          id: dataCenter.playlists[index].id,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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
