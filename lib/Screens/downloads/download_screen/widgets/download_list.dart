import 'package:flutter/material.dart';
import 'package:my_youtube/constant.dart';
import 'package:provider/provider.dart';

import '../../../../Models/audio_model.dart';
import '../../../../Models/data_center.dart';
import '../../../../Widgets/video_card.dart';

class DownloadList extends StatelessWidget {
  const DownloadList({super.key});

  void download(DataCenter dataCenter, int index) async {
    if (dataCenter.audios[index].audioStatus == Downloadstatus.downloading) {
      dataCenter.skipItem(dataCenter.audios[index].audioid);
      return;
    }
    await dataCenter.downloadAudio(dataCenter.audios[index], 'mp4', 1);
  }

  IconData getIcon(dataCenter, index) {
    if (dataCenter.audios[index].existedOnStorage) {
      return Icons.download_done;
    }
    switch (dataCenter.audios[index].audioStatus) {
      case Downloadstatus.downloading:
        return Icons.pause;
      case Downloadstatus.inQueue:
        return Icons.watch_later_outlined;
      default:
        return Icons.download;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: kBottombarHeight),
        child: ListView.builder(
          controller: dataCenter.downloadScreenController,
          physics: const BouncingScrollPhysics(),
          itemCount: dataCenter.audios.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AudioCard(
                key: ValueKey(dataCenter.audios[index].audioid!),
                id: dataCenter.audios[index].audioid!,
                icon: IconButton(
                  onPressed: () => download(dataCenter, index),
                  icon: Icon(
                    getIcon(dataCenter, index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
