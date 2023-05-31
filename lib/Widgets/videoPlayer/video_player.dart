import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:my_youtube/Widgets/videoPlayer/components/control_buttons.dart';
import 'package:my_youtube/Widgets/videoPlayer/components/curtin.dart';
import 'package:my_youtube/Widgets/videoPlayer/components/video_frame.dart';
import 'package:provider/provider.dart';
import 'components/progress_indicator.dart' as video_indicator;

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void initState() {
    super.initState();

    // Provider.of<VideoController>(context, listen: false).videoInitialize();
    Provider.of<VideoController>(context, listen: false).initTimer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<VideoController>(
        builder: (context, videoController, child) {
      return Row(
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (!videoController.minimized) {
                videoController.minimize();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              height: videoController.getFrameSize(size),
              width: videoController.minimized ? 120 : size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const VideoFrame(),
                  if (!videoController.minimized) const Curtin(),
                  if (!videoController.minimized) const ControlsButton(),
                  if (videoController.controller != null)
                    const video_indicator.ProgressIndicator()
                ],
              ),
            ),
          ),
          if (videoController.isPanelClosed)
            Flexible(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: videoController.isPanelClosed ? 1 : 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (videoController.isPanelClosed)
                      const SizedBox(width: 10),
                    if (videoController.isPanelClosed)
                      Expanded(
                        child: Text(
                          videoController
                              .videos[videoController.currentVideoIndex].title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ),
                    const SizedBox(width: 10),
                    if (videoController.isPanelClosed)
                      GestureDetector(
                        onTap: videoController.videoControl,
                        child: Icon(
                          videoController.getIcon(),
                          size: 35,
                        ),
                      ),
                    if (videoController.isPanelClosed)
                      const SizedBox(width: 10),
                    if (videoController.isPanelClosed)
                      GestureDetector(
                        onTap: () {
                          videoController.controller!.pause();
                          videoController.timer?.cancel();
                          videoController.currentPLayListID = null;
                          videoController.panelController.hide();
                        },
                        child: const Icon(
                          Icons.close_sharp,
                          size: 35,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
