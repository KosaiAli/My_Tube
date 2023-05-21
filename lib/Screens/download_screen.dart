import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Models/video_model.dart';
import '../Widgets/video_card.dart';

class DownloadScreen extends StatefulWidget {
  static const routeName = 'DownloadScreen';
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextEditingController textEditingController = TextEditingController();

  void download(dataCenter, index) async {
    if (dataCenter.videos[index].videoStatus == Downloadstatus.downloading) {
      dataCenter.skipItem(dataCenter.videos[index].videoid);
      return;
    }
    await dataCenter.downloadVideo(dataCenter.videos[index], 'mp4', 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return SafeArea(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  dataCenter.initDownloadQueue();
                  dataCenter.downloadAll();
                },
                child: const Text('start all'),
              ),
              Expanded(
                child: ListView.builder(
                  controller: dataCenter.downloadScreenController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: dataCenter.videos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: VideoCard(
                        key: ValueKey(dataCenter.videos[index].videoid!),
                        id: dataCenter.videos[index].videoid!,
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
              const SizedBox(height: 50)
            ],
          ),
        );
      },
    );
  }

  IconData getIcon(dataCenter, index) {
    if (dataCenter.videos[index].existedOnStorage) {
      return Icons.download_done;
    }
    switch (dataCenter.videos[index].videoStatus) {
      case Downloadstatus.downloading:
        return Icons.pause;
      case Downloadstatus.inQueue:
        return Icons.watch_later_outlined;
      default:
        return Icons.download;
    }
  }
}
