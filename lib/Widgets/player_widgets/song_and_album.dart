import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/player_controller.dart';
import '../../animation_functions.dart';
import '../../size_confg.dart';

class SongAndAlbum extends StatelessWidget {
  const SongAndAlbum({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Opacity(
        opacity: getOpacity(musicPlayer).clamp(0, 1),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getHorizontalPadding(context)),
          child: Container(
            constraints: BoxConstraints(
                minHeight: getProportionateScreenHeight(40),
                maxHeight: getProportionateScreenHeight(55)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<String?>(
                          valueListenable: musicPlayer.currentSongTitleNotifier,
                          builder: (_, value, __) {
                            return Text(
                              value!,
                              style: Theme.of(context).textTheme.bodyMedium!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(5)),
                ValueListenableBuilder<String?>(
                    valueListenable: musicPlayer.currentSongChannelNotifier,
                    builder: (_, value, __) {
                      return Text(
                        value!,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.grey),
                      );
                    }),
              ],
            ),
          ),
        ));
  }
}
