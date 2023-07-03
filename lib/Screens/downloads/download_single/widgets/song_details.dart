import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/data_center.dart';

class SongDetail extends StatelessWidget {
  const SongDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              dataCenter.singleAudioToDownload!.thumb.toString(),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dataCenter.singleAudioToDownload!.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(dataCenter.singleAudioToDownload!.channelTitle!,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  dataCenter.singleAudioToDownload!.existedOnStorage
                      ? const Text(
                          'downloaded',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        )
                      : const Text(
                          'not downloaded',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
