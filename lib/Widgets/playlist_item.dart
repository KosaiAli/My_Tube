import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/video_card.dart';
import '../Models/audio_model.dart';
import '../Models/player_controller.dart';
import '../animation_functions.dart';
import '../size_confg.dart';

class PlayListItem extends StatelessWidget {
  const PlayListItem({
    super.key,
    required this.item,
  });
  final Audio item;
  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);

    return ValueListenableBuilder<String>(
      valueListenable: musicPlayer.currentSongTitleNotifier,
      builder: (_, value, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 80,
          width: double.infinity,
          color: value == item.title
              ? changeColor(musicPlayer.dominatedColor, 0.05)
              : Colors.transparent,
          padding: EdgeInsets.all(getProportionateScreenHeight(10)),
          child: Row(
            children: [
              SongImage(audio: item),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, maxLines: 1),
                      Text(item.channelTitle!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
