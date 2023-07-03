import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/player_controller.dart';
import '../../animation_functions.dart';
import '../../notifiers/progress_notifier.dart';

class SongProgressBar extends StatelessWidget {
  const SongProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Opacity(
      opacity: getOpacity(musicPlayer).clamp(0, 1),
      child: ValueListenableBuilder<ProgressBarState>(
          valueListenable: musicPlayer.progressNotifier,
          builder: (_, value, __) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getHorizontalPadding(context) / 2,
              ),
              child: ProgressBar(
                progress: value.current,
                // buffered: value.total,
                total: value.total,
                onSeek: musicPlayer.seek,
                thumbColor: Colors.white,
                progressBarColor: Colors.white,
                baseBarColor: musicPlayer.panelPosition > 0.001
                    ? changeColor(musicPlayer.dominatedColor, 0.2)
                    : Colors.grey[800],
              ),
            );
          }),
    );
  }
}
