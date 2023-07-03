import 'package:flutter/material.dart';
import 'package:my_youtube/Widgets/player_widgets/top_buttons.dart';
import 'package:my_youtube/animation_functions.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../Models/data_center.dart';
import '../size_confg.dart';
import '../Screens/playlist_view.dart';
import '../Models/player_controller.dart';
import '../Widgets/player_widgets/song_detail.dart';
import '../Widgets/player_widgets/control_button.dart';
import '../Widgets/player_widgets/song_and_album.dart';
import '../Widgets/player_widgets/image_and_curtin.dart';
import '../Widgets/player_widgets/song_progress_bar.dart';

class PLayerScreen extends StatefulWidget {
  const PLayerScreen({super.key});

  @override
  State<PLayerScreen> createState() => _PLayerScreenState();
}

class _PLayerScreenState extends State<PLayerScreen> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final musicPlayer = Provider.of<MusicPlayer>(context);
    final dataCenter = Provider.of<DataCenter>(context);
    final maxHeight = size.height - 70 - media.padding.top;

    return SlidingUpPanel(
      minHeight: getProportionateScreenHeight(38),
      maxHeight: getProportionateScreenHeight(maxHeight),
      controller: musicPlayer.playlistItemController,
      onPanelSlide: musicPlayer.setplaylistItemControllerPosition,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      panel: const PlayListView(),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: musicPlayer.panelPosition > 0.001
            ? changeColor(musicPlayer.dominatedColor, 0.05)
            : Colors.grey[900],
        child: Stack(
          children: [
            songsPage(musicPlayer, dataCenter, size, media),
            curtin(musicPlayer),
            SongDetail(media: media),
            SafeArea(
              child: Column(
                children: [
                  TopButtons(),
                  SizedBox(height: size.height * 0.55),
                  const SongAndAlbum(),
                  SizedBox(height: getProportionateScreenHeight(10)),
                  const SongProgressBar(),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  const ContolButtons(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
