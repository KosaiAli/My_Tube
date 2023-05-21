import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Models/playlist_model.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Screens/edit_playlist_screen.dart';
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
        onTap: () {
          Provider.of<VideoController>(context, listen: false)
              .initializePlaylist(playList.playlistid,
                  Provider.of<DataCenter>(context, listen: false));
        },
        child: Container(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 310,
                    child: FutureBuilder<bool>(
                      future: image.exists(),
                      builder: (context, snaphot) {
                        if (snaphot.data != null && snaphot.data == true) {
                          // print(value);
                          return Image.file(image);
                        }

                        return GestureDetector(
                          onTap: () async {
                            Dio dio = Dio();
                            await Permission.storage.request();
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
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white.withAlpha(60).withOpacity(0.5),
                      child: const Icon(
                        Icons.playlist_play_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        playList.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.01,
                          wordSpacing: 0.01,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            PlayListEditScreen.routeName,
                            arguments: playList.playlistid);
                      },
                      child: const Icon(Icons.edit_rounded),
                    )
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
