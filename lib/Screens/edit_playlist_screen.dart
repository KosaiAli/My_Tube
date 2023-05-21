import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:my_youtube/Models/database.dart';
import 'package:my_youtube/Models/playlist_model.dart';
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
  late PlayList playlistData;
  late String id;
  late File image;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    id = ModalRoute.of(context)!.settings.arguments as String;
    final dataCenter = Provider.of<DataCenter>(context, listen: false);
    playlistData = dataCenter.playlists
        .firstWhere((playlist) => playlist.playlistid == id);

    image = File(playlistData.image);
  }

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    var pickedXFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedXFile != null) {
      setState(() {
        image = File(pickedXFile.path);
      });
    }
  }

  void delete(snapshot, e) {
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              RawMaterialButton(
                onPressed: () async {
                  await VideoDataBase.instance
                      .removeVideoFromPlaylist(playlistData.id, e.id)
                      .then((value) {
                    setState(() {});
                    Navigator.pop(context);
                  });
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return Scaffold(
          body: SafeArea(
            child: FutureBuilder<List<VideoModel>>(
              future: dataCenter.fetchPlaylistVideos(id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var videos = dataCenter.videos.where((video) {
                  return !snapshot.data!
                      .any((element) => element.videoid == video.videoid);
                });
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                Image.file(image),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
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
                              onPressed: () => delete(snapshot, e),
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
                                  icon: const Icon(
                                    Icons.add_rounded,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      TextButton(
                        onPressed: () async {
                          await VideoDataBase.instance.updatePlaylist({
                            'playlistid': id,
                            'image': image.path,
                          }).then((value) {
                            Provider.of<DataCenter>(context, listen: false)
                                .initDownloadVideos();
                            Navigator.pop(context);
                          });
                        },
                        child: const Text('done'),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
