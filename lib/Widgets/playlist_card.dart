import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Models/playlist_model.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';

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
    playList = Provider.of<DataCenter>(context, listen: false)
        .playlists
        .firstWhere((element) => element.id == widget.id);
    var name = playList.name;
    image = File('$kFolderUrlBase/${name.substring(0, name.length - 4)}.jpg');
  }

  @override
  void dispose() {
    super.dispose();
    // print(widget.playList.name);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context)
        //     .pushNamed(PlaylistPlayerScreen.routeName, arguments: widget.id);
        Provider.of<VideoController>(context, listen: false).playListInitialize(
            playList.id, Provider.of<DataCenter>(context, listen: false));
      },
      child: Container(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 3),
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
                            await dio
                                .download(
                              'video.thumb',
                              '$kFolderUrlBase/video.title.jpg',
                              onReceiveProgress: (count, total) {},
                            )
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: const Icon(Icons.download_outlined));
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                playList.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.01,
                    wordSpacing: 0.01,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
