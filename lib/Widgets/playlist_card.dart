import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_youtube/size_confg.dart';
import 'package:provider/provider.dart';

import '../Models/player_controller.dart';
import '../Models/data_center.dart';
import '../Models/playlist_model.dart';
import '../constant.dart';

class PlayListCard extends StatefulWidget {
  const PlayListCard({super.key, required this.id});
  final String id;
  @override
  State<PlayListCard> createState() => _PlayListCardState();
}

class _PlayListCardState extends State<PlayListCard> {
  late PlayList playList;
  late File image;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      playList = dataCenter.playlists
          .firstWhere((element) => element.playlistid == widget.id);

      image = File(playList.image);
      return GestureDetector(
        onTap: () async {
          final musicPlayer = Provider.of<MusicPlayer>(context, listen: false);
          await musicPlayer.loadPlaylist(playList.playlistid).then((value) {
            musicPlayer.currentPlaylist = playList;
          });
          // await Future.delayed(const Duration(seconds: 2));
          musicPlayer.play();
        },
        child: SizedBox(
          height: getProportionateScreenHeight(160),
          width: getProportionateScreenWidth(125),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<bool>(
                future: image.exists(),
                builder: (context, snaphot) {
                  if (snaphot.data == null) {
                    return SizedBox(
                      height: getProportionateScreenHeight(110),
                      width: getProportionateScreenWidth(110),
                    );
                  }

                  if (snaphot.data != null && snaphot.data == true) {
                    return Container(
                        height: getProportionateScreenHeight(110),
                        width: getProportionateScreenWidth(110),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ));
                  }

                  return GestureDetector(
                    onTap: () async {
                      Dio dio = Dio();

                      await dio
                          .download(
                        playList.networkImage,
                        '$kFolderUrlBase/${playList.name.substring(0, playList.name.length - 4)}.jpg',
                        onReceiveProgress: (count, total) {},
                      )
                          .then((value) {
                        setState(() {});
                      });
                    },
                    child: const Center(
                      child: Icon(Icons.download_outlined),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        playList.name,
                        style: Theme.of(context).textTheme.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
