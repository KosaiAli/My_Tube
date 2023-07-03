import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_youtube/Models/player_controller.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.imageURL});
  final String imageURL;
  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer<MusicPlayer>(builder: (context, musicPlayer, child) {
      return Row(
        children: [
          SizedBox(
            width: musicPlayer
                .getpadding(size)
                .clamp(5.0, (size.width - musicPlayer.getWidth(size)) * 0.5),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            clipBehavior: Clip.antiAlias,
            height: musicPlayer.getHeight(size),
            width: musicPlayer.getWidth(size),
            child: ValueListenableBuilder<String>(
                valueListenable: musicPlayer.currentSongTitleNotifier,
                builder: (_, value, __) {
                  if (value.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ],
                    );
                  }

                  return Image.file(
                    File('$kFolderUrlBase/${widget.imageURL}.jpg'),
                    fit: BoxFit.cover,
                  );
                }),
          ),
        ],
      );
    });
  }
}
