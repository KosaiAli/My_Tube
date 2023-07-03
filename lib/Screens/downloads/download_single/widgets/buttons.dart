import 'package:flutter/material.dart';
import 'package:my_youtube/Screens/downloads/download_single/provider.dart';
import 'package:provider/provider.dart';

import '../../../../Models/data_center.dart';
import '../../../../Models/database.dart';

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    final dwonloadProvider = Provider.of<DownloadSingleProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.red,
                ),
          ),
          onPressed: () async {
            await DB.instance.deleteAudio(dataCenter.singleAudioToDownload!.id);

            dataCenter.initDownloadAudios();
            dataCenter.panelController.close();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextButton(
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.green,
                  ),
            ),
            onPressed: () async {
              await DB.instance
                  .addToPLaylist(dwonloadProvider.selectedplaylist,
                      dataCenter.singleAudioToDownload?.id)
                  .then((value) {
                dataCenter.panelController.close();
                dataCenter.initDownloadAudios();
                dataCenter.panelController.close();
              });
            },
          ),
        ),
      ],
    );
  }
}
