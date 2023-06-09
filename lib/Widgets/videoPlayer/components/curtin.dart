import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:provider/provider.dart';

class Curtin extends StatelessWidget {
  const Curtin({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoController>(
        builder: (context, videoController, child) {
      return GestureDetector(
          onTap: videoController.hide,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: Colors.black.withOpacity(videoController.hidden ? 0 : 0.2),
            height: MediaQuery.of(context).size.height * 0.40,
          ));
    });
  }
}
