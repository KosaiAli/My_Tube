
import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator(
      {super.key,
    });
  
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (twoDigits(duration.inHours) == '00') {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }

    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoController>(
      builder: (context,videoController,child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: videoController.hidden ? 0 : 1,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      '${_printDuration(videoController.position)} / ${_printDuration(videoController.duration)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            VideoProgressIndicator(
              videoController.controller!,
              allowScrubbing: true,
            )
          ],
        );
      }
    );
  }
}
