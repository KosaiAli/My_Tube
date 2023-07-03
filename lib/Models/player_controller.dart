import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_youtube/Models/playlist_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:image/image.dart' as img;

import './audio_model.dart';
import '../constant.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import '../services/audio_handler.dart';
import '../services/playlist_repository.dart';
import '../size_confg.dart';

class MusicPlayer extends ChangeNotifier {
  late AudioHandler _audioHandler;

  MusicPlayer() {
    init();
  }

  List<Audio> songs = [];
  Set<String> notDownloadedVideos = {};

  PanelController panelController = PanelController();
  PanelController playlistItemController = PanelController();
  PageController songsController = PageController();
  int _currentSongIndex = 0;

  double _panelPosition = 0.0;
  double _playlistItemControllerPosition = 0.0;
  String? _currentPLayListID;
  String? get currentPLayListID => _currentPLayListID;
  Color? _dominatedColor;

  late PlayList _currentPlaylist;

  PlayList get currentPlaylist => _currentPlaylist;

  set currentPlaylist(PlayList audio) {
    _currentPlaylist = audio;
    notifyListeners();
  }

  Color? get dominatedColor => _dominatedColor;
  set dominatedColor(Color? color) {
    _dominatedColor = color;

    notifyListeners();
  }
  // late BuildContext _buildContext;

  double getWidth(Size size) {
    if (panelController.panelPosition == 0 ||
        playlistItemController.isPanelOpen) {
      return 60;
    }
    double position = size.width * 0.70 * panelController.panelPosition -
        size.width * 0.70 * playlistItemController.panelPosition;
    return getProportionateScreenWidth(60 + position);
  }

  void notifty() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

  set panelPosition(double position) {
    _panelPosition = position;
    notifyListeners();
  }

  set currentSongIndex(int value) {
    _currentSongIndex = value;
  }

  double get panelPosition => _panelPosition;

  setplaylistItemControllerPosition(double position) {
    _playlistItemControllerPosition = position;
    notifyListeners();
  }

  double get playlistItemControllerPosition => _playlistItemControllerPosition;

  double getHeight(Size size) {
    if (panelController.panelPosition == 0 ||
        playlistItemController.isPanelOpen) {
      return 60;
    }
    double position = size.height * 0.35 * panelController.panelPosition -
        size.height * 0.35 * playlistItemController.panelPosition;
    return getProportionateScreenHeight(60 + position);
  }

  double getpadding(Size size) {
    var padding =
        panelController.panelPosition * (size.width - getWidth(size)) * 0.5 -
            playlistItemController.panelPosition *
                (size.width - getWidth(size)) *
                0.5;

    return getProportionateScreenWidth(5 + padding);
  }

  // set buildContext(BuildContext ctx) {
  //   _buildContext = ctx;
  // }

  set currentPLayListID(id) {
    _currentPLayListID = id;
    notifyListeners();
  }

  setSongs(list) {
    songs = list;
    notifyListeners();
  }

  late ConcatenatingAudioSource playlist;
  AudioPlayer? player;

  // IconData getIcon() {

  //   return playButtonNotifier.value == ButtonState.playing
  //       ? Icons.pause
  //       : Icons.play_arrow;
  // }

  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongChannelNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<Set<String>>({});
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  // final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  Future<void> init() async {
    _audioHandler = await initAudioService();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void seek(Duration position) => _audioHandler.seek(position);
  void previous() {
    songsController.jumpToPage(_currentSongIndex - 1);

    songsController.previousPage(duration: Duration.zero, curve: Curves.linear);
    _audioHandler.skipToPrevious();
  }

  void next() {
    songsController.jumpToPage(_currentSongIndex + 1);
    _audioHandler.skipToNext();
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  Future<void> shuffle() async {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }

    final index = playlistNotifier.value
        .toList()
        .indexWhere((element) => element == _audioHandler.mediaItem.value?.id);
    songsController.jumpToPage(index);
  }

  // void dispose() {}

  Future<void> loadPlaylist(playListID) async {
    final songRepository = DemoPlaylist();

    final playlist =
        await songRepository.fetchInitialPlaylist(playListID: playListID);
    final mediaItems = <MediaItem>[];
    for (var song in playlist) {
      final file = File('$kFolderUrlBase/${song['name']}.mp3');
      final exists = await file.exists();
      if (exists) {
        final mediaItem = MediaItem(
          id: song['audioid'] as String,
          album: song['channelTitle'] as String? ?? '',
          title: song['name'] as String? ?? '',
          extras: {
            'localUrl': '$kFolderUrlBase/${song['name']}.mp3',
            'url': song['image']
          },
        );
        mediaItems.add(mediaItem);
      }
    }

    await _audioHandler.addQueueItems(mediaItems);
    currentPLayListID = playListID;

    notifyListeners();
    await panelController.show();
    await panelController.animatePanelToPosition(1,
        curve: Curves.easeOutExpo, duration: const Duration(milliseconds: 400));
    songsController.jumpToPage(0);
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) async {
      if (playlist.isEmpty) return;

      final newPlaylist = <String>{};

      for (var e in playlist) {
        newPlaylist.add(e.id);
      }

      playlistNotifier.value = newPlaylist;
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongChannelNotifier.value = mediaItem?.album ?? '';

      getColor(mediaItem?.title).then((value) {
        dominatedColor = value;
      });
      final index = playlistNotifier.value
          .toList()
          .indexWhere((element) => element == mediaItem?.id);

      songsController.jumpToPage(index);

      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  Future<void> playFromMediaId(int index) async {
    _audioHandler.skipToQueueItem(index);
  }

  Future<Color?> getColor(value) async {
    try {
      final file = File('$kFolderUrlBase/$value.jpg');

      //retrieve image data list
      final data = await file.readAsBytes();

      /*
      decrease the resolution of the image 
      in order to decrease the decoding process requirements
      */

      //decoding the image Data
      final imageData = img.decodeJpg(data);

      //fetching image width and height
      final width = imageData?.width ?? 0;
      final height = imageData?.height ?? 0;
      final colors = [];

      for (int i = 0; i < width; i += 10) {
        for (int j = 0; j < height; j += 10) {
          //get every pixel's color's four elemnt
          final pixel = imageData?.getPixel(i, j);

          final alpha = pixel!.a;
          final red = pixel.r;
          final blue = pixel.b;
          final green = pixel.g;
          if (red > 25 &&
              red < 200 &&
              blue > 25 &&
              blue < 200 &&
              green > 25 &&
              green < 200) {
            final color = Color.fromARGB(
                alpha.toInt(), red.toInt(), green.toInt(), blue.toInt());

            colors.add(color);
          }
        }
      }

      //determinate the domaint color
      Color? domainatColor;
      int maxCount = 0;
      Map<Color, int> colorsCount = {};

      for (Color color in colors) {
        int count = colorsCount[color] ?? 0;
        colorsCount[color] = count + 1;
        if (count + 1 > maxCount) {
          maxCount = count + 1;
          domainatColor = color;
        }
      }

      return domainatColor;
    } catch (e) {
      return null;
    }
  }
}

class Alert extends StatelessWidget {
  const Alert({super.key, required this.ok, required this.close});
  final Function() ok;
  final Function() close;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Looks like you have not download all of your videos'),
      content: const Text('Go to the donwload page and download them'),
      actions: [
        RawMaterialButton(
          onPressed: () {
            Navigator.pop(context);
            close();
          },
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        RawMaterialButton(
          onPressed: () {
            ok();
          },
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                ),
          ),
        )
      ],
    );
  }
}
