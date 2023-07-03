import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Screens/downloads/download_single/provider.dart';
import 'package:provider/provider.dart';

import '../../../../Models/database.dart';

class AllPlaylis extends StatefulWidget {
  const AllPlaylis({super.key});

  @override
  State<AllPlaylis> createState() => _AllPlaylisState();
}

class _AllPlaylisState extends State<AllPlaylis> {
  bool inAnyPLaylist = false;
  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    final dwonloadProvider = Provider.of<DownloadSingleProvider>(context);
    return Column(
      children: dataCenter.playlists.map(
        (e) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 100,
                  child: Image.file(
                    File(e.image),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.name,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ),
                FutureBuilder(
                    future: DB.instance.hasaudio(
                        e.id, dataCenter.singleAudioToDownload!.audioid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == true) {
                          inAnyPLaylist = true;
                        }
                        return Checkbox(
                          value: snapshot.data == true
                              ? snapshot.data
                              : dwonloadProvider.selectedplaylist == e.id,
                          onChanged: (value) {
                            if (dwonloadProvider.selectedplaylist == e.id!) {
                              setState(() {
                                dwonloadProvider.selectedplaylist = -1;
                              });
                              return;
                            }
                            dwonloadProvider.selectedplaylist = e.id!;
                          },
                        );
                      }
                      return const CircularProgressIndicator();
                    })
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}
