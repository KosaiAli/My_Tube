import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Screens/playlist_player_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import '../Models/video_controller.dart';
import '../Widgets/playlist_card.dart';
import '../constant.dart';

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

  double _getMinHeight(videoController, mdeiaQuery) =>
      videoController.currentPLayListID == null
          ? 0
          : 70 + kBottomNavigationBarHeight;

  @override
  Widget build(BuildContext context) {
    var mdeiaQuery = MediaQuery.of(context);
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return Consumer<VideoController>(
          builder: (context, videoController, child) {
            return SafeArea(
              child: Scaffold(
                backgroundColor: const Color(0xFF212121),
                body: WillPopScope(
                  onWillPop: () async {
                    if (!videoController.minimized) {
                      await videoController.minimize();
                      return false;
                    }
                    return true;
                  },
                  child: SlidingUpPanel(
                    isDraggable: false,
                    controller: videoController.panelController,
                    panel: videoController.currentPLayListID == null
                        ? Container()
                        : const PlaylistPlayerScreen(),
                    minHeight: _getMinHeight(videoController, mdeiaQuery),
                    maxHeight: mdeiaQuery.size.height,
                    body: Padding(
                      padding: const EdgeInsets.only(
                        bottom: kBottombarHeight,
                      ),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: dataCenter.playlists.length,
                        itemBuilder: (context, index) {
                          return PlayListCard(
                            id: dataCenter.playlists[index].playlistid,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
