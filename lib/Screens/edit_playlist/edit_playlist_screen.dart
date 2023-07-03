import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_youtube/constant.dart';
import 'package:provider/provider.dart';

import '../../Models/data_center.dart';
import '../../Models/database.dart';
import '../../Models/player_controller.dart';
import '../../Models/playlist_model.dart';
import '../../Widgets/video_card.dart';
import '../../Models/audio_model.dart';

class PlayListEditScreen extends StatefulWidget {
  static const String routeName = 'PlayListEditScreen';
  const PlayListEditScreen({super.key});

  @override
  State<PlayListEditScreen> createState() => _PlayListEditScreenState();
}

class _PlayListEditScreenState extends State<PlayListEditScreen> {
  late PlayList playlistData;
  late File image;
  late String id;

  @override
  void initState() {
    final dataCenter = Provider.of<DataCenter>(context, listen: false);
    final musicPlayer = Provider.of<MusicPlayer>(context, listen: false);
    print(musicPlayer.currentPlaylist);
    id = musicPlayer.currentPlaylist.playlistid;
    playlistData = dataCenter.playlists
        .firstWhere((playlist) => playlist.playlistid == id);
    image = File(playlistData.image);
    super.initState();
  }

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

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
                  await DB.instance
                      .removeAudioFromPlaylist(playlistData.id, e.id)
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
    final dataCenter = Provider.of<DataCenter>(context);
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: playlistName(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kScaffoldColor,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Audio>>(
          future: dataCenter.fetchPlaylistAudios(id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final audios = dataCenter.audios.where((video) => !snapshot.data!
                .any((element) => element.audioid == video.audioid));

            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    brightness: Brightness.dark,
                    secondary: const Color(0xFF4effbb)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageEdit(),
                    ...getPlaylistAudios(snapshot),
                    allAudios(context),
                    ...getAllAudios(audios),
                    doneButton(context)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  getPlaylistAudios(snapshot) {
    return snapshot.data!.map((element) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: AudioCard(
          key: ValueKey(element.id),
          id: element.audioid!,
          icon: IconButton(
            onPressed: () => delete(snapshot, element),
            icon: const Icon(Icons.delete_rounded),
          ),
        ),
      );
    }).toList();
  }

  getAllAudios(audios) {
    return audios
        .map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AudioCard(
              key: ValueKey(e.id),
              id: e.audioid!,
              icon: IconButton(
                onPressed: () async {
                  await DB.instance.addToPLaylist(playlistData.id, e.id);
                  setState(() {});
                },
                icon: const Icon(
                  Icons.add_rounded,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  TextButton doneButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await DB.instance.updatePlaylist({
          'playlistid': id,
          'image': image.path,
        }).then((value) {
          Provider.of<DataCenter>(context, listen: false).initDownloadAudios();
          Navigator.pop(context);
        });
      },
      child: const Text('done'),
    );
  }

  Padding allAudios(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Text(
        'Add songs :',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  imageEdit() {
    return Center(
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
    );
  }

  playlistName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        playlistData.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
