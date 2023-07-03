import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/playlist_item.dart';
import './widgets/download_button.dart';
import '../../../Models/data_center.dart';

class DownloadPlaylist extends StatelessWidget {
  const DownloadPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return dataCenter.playListData.isNotEmpty
        ? Stack(
            children: const [
              PlayListItems(),
              DownloadButton(),
            ],
          )
        : const Text('loading');
  }
}
