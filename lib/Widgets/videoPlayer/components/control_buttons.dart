import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';

class ControlsButton extends StatelessWidget {
  const ControlsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoController>(
        builder: (context, videoController, child) {
      return AnimatedOpacity(
        opacity: videoController.hidden ? 0 : 1,
        duration: const Duration(milliseconds: 100),
        child: IgnorePointer(
          ignoring: videoController.hidden,
          child: Row(
            children: [
              Expanded(child: Column()),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: videoController.videoControl,
                      child: Icon(
                        videoController.getIcon(),
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: videoController.minimize,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
