import 'package:flutter/material.dart';
import 'package:my_youtube/Models/player_controller.dart';
import 'package:provider/provider.dart';

import '../../Screens/edit_playlist/edit_playlist_screen.dart';
import '../../animation_functions.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return IgnorePointer(
      ignoring: musicPlayer.panelController.isPanelClosed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: getOpacity(musicPlayer).clamp(0, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  musicPlayer.panelController.close();
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 34,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(PlayListEditScreen.routeName),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
