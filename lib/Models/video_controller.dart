import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_youtube/Models/data_center.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import '../Models/video_model.dart';
import '../constant.dart';

class VideoController extends ChangeNotifier {
  VideoController({required this.buildContext});
  final BuildContext buildContext;

  List<VideoModel> videos = [];
  Set<String> notDownloadedVideos = {};

  VideoPlayerController? controller;
  PanelController panelController = PanelController();

  int currentVideoIndex = 0;

  bool initializing = false;
  bool isPlaying = false;
  bool hidden = false;
  bool _minimized = false;
  bool isPanelClosed = false;
  bool playedFinished = false;

  String? _currentPLayListID;

  String? get currentPLayListID => _currentPLayListID;
  bool get minimized => _minimized;

  Duration duration = const Duration();
  Duration position = const Duration();

  late DateTime time;
  late Timer? timer;

  set currentPLayListID(id) {
    _currentPLayListID = id;
    notifyListeners();
  }

  set minimized(value) {
    _minimized = value;
    notifyListeners();
  }

  late void Function() listener = () async {
    isPlaying = controller!.value.isPlaying;
    position = controller!.value.position;

    notifyListeners();

    if (duration.inSeconds != 0 && position.inSeconds == duration.inSeconds) {
      {
        currentVideoIndex++;
      }
      try {
        await videoInitialize(true);
      } catch (e) {
        rethrow;
      }
    }
  };

  setvideos(list) {
    videos = list;
    notifyListeners();
  }

  Future<void> playListInitialize(id, DataCenter datacenter) async {
    notDownloadedVideos = {};

    await panelController.show();
    isPanelClosed = false;

    videos = await datacenter.fetchPlaylistVideos(id);
    playedFinished = false;
    notifyListeners();
    panelController.open();

    if (controller != null && isPlaying) {
      controller!.pause();
    }
    minimized = false;
    currentPLayListID = id;
    currentVideoIndex = 0;

    videoInitialize(true);
  }

  Future<void> videoInitialize(topPlay) async {
    if (initializing) return;

    if (controller != null) {
      controller!.removeListener(listener);
    }

    if (currentVideoIndex >= videos.length) {
      hidden = false;
      currentVideoIndex--;
      playedFinished = true;
      timer!.cancel();
      notifyListeners();
      if (notDownloadedVideos.isNotEmpty) showAlert();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    var title = videos[currentVideoIndex].title;

    File file = File(
      '$kFolderUrlBase/$title.mp4',
    );
    final exists = await file.exists();

    if (!exists) {
      log(videos[currentVideoIndex].title);
      notDownloadedVideos.add(videos[currentVideoIndex].videoid!);
      if (currentVideoIndex < videos.length - 1) {
        currentVideoIndex++;
        videoInitialize(topPlay);
        return;
      } else {
        showAlert();
        return;
        // panelController.close();
        // currentPLayListID = null;
        // currentVideoIndex = 0;
        // notifyListeners();
        // throw Exception('thre no more item in the list go to donwloadpage ');
      }
    }
    initializing = true;
    controller = VideoPlayerController.file(file,
        videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: true, mixWithOthers: false));

    await controller!.initialize();
    if (timer == null) initTimer();
    initializing = false;
    duration = controller!.value.duration;
    position = controller!.value.position;
    notifyListeners();

    controller!.addListener(listener);
    if (topPlay) controller!.play();
  }

  IconData getIcon() {
    if (playedFinished) {
      return Icons.replay;
    }
    return isPlaying ? Icons.pause : Icons.play_arrow;
  }

  void hide() {
    hidden = !hidden;
    time = DateTime.now();
    notifyListeners();
  }

  void initTimer() {
    time = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print(timer.tick);
      if (DateTime.now().difference(time).inSeconds > 3) {
        hidden = true;

        notifyListeners();
      }
    });
  }

  Future<void> videoControl() async {
    if (playedFinished) {
      currentVideoIndex = 0;
      playedFinished = false;
      notifyListeners();
      videoInitialize(true);
    }
    if (controller!.value.isPlaying) {
      controller!.pause();
      isPlaying = false;
      notifyListeners();
      return;
    }
    isPlaying = true;
    notifyListeners();

    controller!.play();
  }

  double getFrameSize(size) {
    if (controller != null && controller!.value.isInitialized && minimized) {
      return 70.0;
    } else if (controller != null && controller!.value.isInitialized) {
      return size.width / controller!.value.aspectRatio;
    }
    return size.height * 0.30;
  }

  void stop() {
    currentVideoIndex = 0;
    controller!.removeListener(listener);
    controller!.pause();
  }

  void changeVideo(id) {
    var index = videos.indexWhere((element) => element.videoid == id);
    currentVideoIndex = index;
    controller!.pause();
    notifyListeners();
    videoInitialize(true);
  }

  Future<void> minimize() async {
    hidden = true;
    notifyListeners();
    if (!minimized) {
      minimized = true;
      await panelController
          .animatePanelToPosition(0,
              duration: const Duration(milliseconds: 300))
          .then((value) {
        isPanelClosed = true;
        notifyListeners();
      });

      return;
    }
    isPanelClosed = false;
    minimized = false;
    notifyListeners();
    panelController.animatePanelToPosition(1,
        duration: const Duration(milliseconds: 300));
  }

  Future<void> showAlert() async {
    await showDialog(
      context: buildContext,
      builder: (context) {
        return Alert(
          ok: ok,
        );
      },
    ).then((value) => close());
  }

  void close() {
    currentVideoIndex = 0;
    isPlaying = false;
    videoInitialize(false);
    notifyListeners();
  }

  Future<void> ok() async {
    await panelController.close().then((value) {
      currentPLayListID = null;
      currentVideoIndex = 0;

      Provider.of<DataCenter>(buildContext, listen: false)
          .scrollToVideoIndex(notDownloadedVideos);
    });
  }
}

class Alert extends StatelessWidget {
  const Alert({
    super.key,
    required this.ok,
  });
  final Function() ok;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Looks like you have not download all of your videos'),
      content: const Text('Go to the donwload page and download them'),
      actions: [
        RawMaterialButton(
          onPressed: () {},
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
            Navigator.pop(context);
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
