import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Widgets/playlist_item.dart';
import '../animation_functions.dart';
import '../size_confg.dart';
import '../Models/player_controller.dart';

class PlayListView extends StatelessWidget {
  const PlayListView({super.key});

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    final dataCenter = Provider.of<DataCenter>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: musicPlayer.panelPosition > 0.001
            ? changeColor(musicPlayer.dominatedColor, 0.2)
            : Colors.grey[800],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: getProportionateScreenHeight(17.5)),
              height: getProportionateScreenHeight(3),
              width: getProportionateScreenWidth(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: musicPlayer.playlistNotifier,
                builder: (context, value, __) {
                  if (value.isEmpty) {
                    return const CircularProgressIndicator();
                  }

                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.fromSwatch().copyWith(
                          brightness: Brightness.dark,
                          secondary:
                              changeColor(musicPlayer.dominatedColor, 0.05)),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final item = dataCenter.audios.firstWhere((element) =>
                            element.audioid == value.elementAt(index));
                        return GestureDetector(
                            onTap: () {
                              musicPlayer.playFromMediaId(index);
                            },
                            child: PlayListItem(
                                item: item, key: ValueKey(item.audioid)));
                      },
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
