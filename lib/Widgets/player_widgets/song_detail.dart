import 'package:flutter/material.dart';
import 'package:my_youtube/Models/player_controller.dart';
import 'package:provider/provider.dart';

import '../../animation_functions.dart';
import '../../notifiers/play_button_notifier.dart';
import '../../size_confg.dart';

class SongDetail extends StatelessWidget {
  const SongDetail({
    super.key,
    required this.media,
  });

  final MediaQueryData media;

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Opacity(
        opacity: getReversedOpacity(musicPlayer).clamp(0, 1),
        child: Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(80),
            right: getProportionateScreenWidth(10),
            top: safeAreaPadding(musicPlayer, media),
          ),
          child: SizedBox(
            height: getProportionateScreenHeight(70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: ValueListenableBuilder<String>(
                            valueListenable:
                                musicPlayer.currentSongTitleNotifier,
                            builder: (_, value, __) {
                              return Text(
                                value,
                                style: Theme.of(context).textTheme.labelMedium,
                                maxLines: 1,
                              );
                            }),
                      ),
                      SizedBox(height: getProportionateScreenHeight(5)),
                      IgnorePointer(
                        ignoring: true,
                        child: ValueListenableBuilder<String>(
                            valueListenable:
                                musicPlayer.currentSongChannelNotifier,
                            builder: (_, value, __) {
                              return Text(
                                value,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: Colors.grey),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ValueListenableBuilder<ButtonState>(
                      valueListenable: musicPlayer.playButtonNotifier,
                      builder: (_, value, child) {
                        switch (value) {
                          case ButtonState.paused:
                            return GestureDetector(
                              onTap: musicPlayer.play,
                              child: const Icon(Icons.play_arrow),
                            );
                          case ButtonState.playing:
                            return GestureDetector(
                              onTap: musicPlayer.pause,
                              child: const Icon(Icons.pause),
                            );
                        }
                      },
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    IconButton(
                        onPressed: () async => musicPlayer.next(),
                        icon: const Icon(Icons.skip_next)),
                    GestureDetector(
                        onTap: () async {
                          musicPlayer.pause();
                          musicPlayer.panelController.hide();
                        },
                        child: const Icon(Icons.close_rounded)),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
