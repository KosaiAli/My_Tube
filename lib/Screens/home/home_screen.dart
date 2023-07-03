import 'package:flutter/material.dart';
import 'package:my_youtube/Screens/home/widgets/all_playlist.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../Models/player_controller.dart';
import '../../constant.dart';
import '../player_screen.dart';
import './widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'HomeScreen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _getMinHeight(videoController, mdeiaQuery) =>
      videoController.currentPLayListID == null
          ? 0
          : 70 + kBottomNavigationBarHeight;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: WillPopScope(
        onWillPop: () async {
          if (musicPlayer.playlistItemController.isPanelOpen) {
            await musicPlayer.playlistItemController.close();
            return false;
          } else if (musicPlayer.panelController.isPanelOpen) {
            await musicPlayer.panelController.close();
            return false;
          }
          return true;
        },
        child: SlidingUpPanel(
          onPanelSlide: (position) => musicPlayer.panelPosition = position,
          onPanelClosed: musicPlayer.playlistItemController.close,
          controller: musicPlayer.panelController,
          minHeight: _getMinHeight(musicPlayer, mediaQuery),
          maxHeight: mediaQuery.size.height,
          panel: const PLayerScreen(),
          body: Padding(
            padding: EdgeInsets.only(
              bottom: kBottombarHeight,
              top: mediaQuery.padding.top,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBar(),
                  const SizedBox(height: 30),
                  Text(
                    'All Playlist :',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  const AllPlaylists(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
