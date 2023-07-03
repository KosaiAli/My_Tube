import 'package:flutter/material.dart';

import '../../Models/data_center.dart';
import '../../Models/player_controller.dart';
import '../../animation_functions.dart';
import 'image.dart';

IgnorePointer curtin(MusicPlayer musicPlayer) {
  return IgnorePointer(
    ignoring: musicPlayer.panelController.isPanelOpen &&
        musicPlayer.playlistItemController.isPanelClosed,
    child: GestureDetector(
      onTap: () {
        switch (musicPlayer.playlistItemController.isPanelOpen) {
          case false:
            musicPlayer.panelController.animatePanelToPosition(1,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 400));
            break;
          case true:
            musicPlayer.playlistItemController.animatePanelToPosition(0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 400));
            break;
        }
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
  );
}

songsPage(MusicPlayer musicPlayer, DataCenter dataCenter, Size size,
    MediaQueryData media) {
  return ValueListenableBuilder(
      valueListenable: musicPlayer.playlistNotifier,
      builder: (_, value, __) {
        return PageView.builder(
          itemCount: value.length,
          controller: musicPlayer.songsController,
          onPageChanged: (index) {
            musicPlayer.currentSongIndex = index;

            musicPlayer.playFromMediaId(index);
          },
          itemBuilder: (context, index) {
            final item = dataCenter.audios.firstWhere(
                (element) => element.audioid == value.elementAt(index));

            return songImage(size, musicPlayer, media, item.title);
          },
        );
      });
}

Column songImage(
    Size size, MusicPlayer musicPlayer, MediaQueryData media, String imageURl) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: getTopMargin(size, musicPlayer).clamp(
          lowMarginLimit(musicPlayer, media),
          double.infinity,
        ),
      ),
      ImageWidget(imageURL: imageURl),
    ],
  );
}
