import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Models/database.dart';
import 'package:my_youtube/Widgets/video_card.dart';
import 'package:provider/provider.dart';

import '../Models/video_model.dart';

class PlayListEditScreen extends StatefulWidget {
  static const String routeName = 'PlayListEditScreen';
  const PlayListEditScreen({super.key});

  @override
  State<PlayListEditScreen> createState() => _PlayListEditScreenState();
}

class _PlayListEditScreenState extends State<PlayListEditScreen> {
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final dataCenter = Provider.of<DataCenter>(context, listen: false);
    final playlistData = dataCenter.playlists
        .firstWhere((playlist) => playlist.playlistid == id);
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: FutureBuilder<List<VideoModel>>(
                future: dataCenter.fetchPlaylistVideos(id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var videos = dataCenter.videos.where((video) {
                    return !snapshot.data!
                        .any((element) => element.videoid == video.videoid);
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          playlistData.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ...snapshot.data!.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: VideoCard(
                            key: ValueKey(e.id),
                            id: e.videoid!,
                            icon: IconButton(
                              onPressed: () {
                                if (snapshot.data!.length > 1) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Are you sure you want to delete ${e.title}',
                                        ),
                                        actions: [
                                          RawMaterialButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          RawMaterialButton(
                                            onPressed: () async {
                                              await VideoDataBase.instance
                                                  .removeVideoFromPlaylist(
                                                      playlistData.id, e.id)
                                                  .then((value) {
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: const Text(
                                              'Delete',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete_rounded),
                            ),
                          ),
                        );
                      }).toList(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: Text(
                          'Add videos :',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ...videos
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: VideoCard(
                                key: ValueKey(e.id),
                                id: e.videoid!,
                                icon: IconButton(
                                  onPressed: () async {
                                    await VideoDataBase.instance
                                        .addToPLaylist(playlistData.id, e.id);
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.add_rounded,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
