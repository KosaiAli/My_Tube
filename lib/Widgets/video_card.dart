import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Models/audio_model.dart';
import '../constant.dart';

class AudioCard extends StatefulWidget {
  const AudioCard({super.key, required this.id, required this.icon});
  final String id;
  final Widget icon;
  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  late Audio audio;

  @override
  void initState() {
    audio = Provider.of<DataCenter>(context, listen: false)
        .audios
        .firstWhere((element) => element.audioid == widget.id);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return SizedBox(
        height: kAudiooCardSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SongImage(audio: audio),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(audio.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Text(audio.channelTitle!,
                      style: Theme.of(context).textTheme.bodySmall),
                  if (audio.audioStatus == Downloadstatus.downloading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: LinearProgressIndicator(
                        value: audio.downloaded,
                      ),
                    ),
                  if (audio.audioStatus == Downloadstatus.error)
                    const Text(
                      'something went wrong',
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
            ),
            widget.icon
          ],
        ),
      );
    });
  }
}

class SongImage extends StatefulWidget {
  const SongImage({super.key, required this.audio});
  final Audio audio;
  @override
  State<SongImage> createState() => _SongImageState();
}

class _SongImageState extends State<SongImage> {
  late File image;
  late bool exists;
  @override
  void initState() {
    super.initState();
  }

  Future<void> checkExists() async {
    exists = await image.exists();
  }

  @override
  Widget build(BuildContext context) {
    image = File('$kFolderUrlBase/${widget.audio.title}.jpg');

    return SizedBox(
      width: kAudiooCardSize,
      height: kAudiooCardSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: widget.audio.existedOnStorage
            ? Image.file(image, fit: BoxFit.cover)
            : Image.network(
                widget.audio.thumb,
              ),
      ),
    );
  }
}
