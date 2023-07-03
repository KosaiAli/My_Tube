import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/data_center.dart';

class PlayListItems extends StatelessWidget {
  const PlayListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return Column(
      children: [
        const SizedBox(height: 50),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: ListView.builder(
              itemCount: dataCenter.playListData.length,
              itemBuilder: (context, index) {
                var video = dataCenter.playListData[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            video.thumb.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 5),
                            Text(video.channelTitle!,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                video.existedOnStorage
                                    ? const Text(
                                        'downloaded',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.green),
                                      )
                                    : const Text(
                                        'not downloaded',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.red),
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                          value: dataCenter.audioToDownload
                              .contains(video.audioid),
                          onChanged: (_) {
                            dataCenter.shuffleDownloadList(video.audioid);
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
