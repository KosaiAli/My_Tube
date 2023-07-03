import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/song_details.dart';
import './widgets/all_playlist.dart';
import './widgets/buttons.dart';
import '../../../Models/data_center.dart';

class DownloadSingle extends StatefulWidget {
  const DownloadSingle({super.key});

  @override
  State<DownloadSingle> createState() => _DownloadSingleState();
}

class _DownloadSingleState extends State<DownloadSingle> {
  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    if (dataCenter.singleAudioToDownload != null) {
      return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SongDetail(),
                AllPlaylis(),
                Buttons(),
              ],
            ),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
