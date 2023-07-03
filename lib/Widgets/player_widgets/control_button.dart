import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/player_controller.dart';
import '../../animation_functions.dart';
import '../../notifiers/play_button_notifier.dart';
import '../../notifiers/repeat_button_notifier.dart';

class ContolButtons extends StatefulWidget {
  const ContolButtons({
    super.key,
  });

  @override
  State<ContolButtons> createState() => _ContolButtonsState();
}

class _ContolButtonsState extends State<ContolButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Opacity(
        opacity: getOpacity(musicPlayer).clamp(0, 1),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getHorizontalPadding(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: musicPlayer.shuffle,
                icon: Builder(builder: (context) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: musicPlayer.isShuffleModeEnabledNotifier,
                    builder: (context, value, child) {
                      return Icon(
                        Icons.shuffle,
                        color: value ? Colors.white : Colors.grey,
                      );
                    },
                  );
                }),
              ),
              IconButton(
                onPressed: () => musicPlayer.previous(),
                icon: const Icon(
                  Icons.skip_previous,
                ),
              ),
              ValueListenableBuilder<ButtonState>(
                valueListenable: musicPlayer.playButtonNotifier,
                child: GestureDetector(
                  onTap: musicPlayer.pause,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white54,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.pause),
                  ),
                ),
                builder: (_, value, child) {
                  switch (value) {
                    case ButtonState.paused:
                      animationController.forward();
                      break;
                    case ButtonState.playing:
                      animationController.reverse();
                      break;
                  }
                  return GestureDetector(
                    onTap: () {
                      switch (value) {
                        case ButtonState.paused:
                          musicPlayer.play();
                          break;
                        case ButtonState.playing:
                          musicPlayer.pause();
                          break;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: musicPlayer.panelPosition > 0.001
                            ? changeColor(musicPlayer.dominatedColor, 0.2)
                            : Colors.grey[800],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: AnimatedIcon(
                        progress: animationController,
                        icon: AnimatedIcons.pause_play,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                  onPressed: () async => musicPlayer.next(),
                  icon: const Icon(Icons.skip_next)),
              IconButton(
                onPressed: musicPlayer.repeat,
                icon: Builder(builder: (context) {
                  return ValueListenableBuilder<RepeatState>(
                    valueListenable: musicPlayer.repeatButtonNotifier,
                    builder: (_, value, __) {
                      switch (value) {
                        case RepeatState.off:
                          return const Icon(
                            Icons.repeat_rounded,
                            color: Colors.grey,
                          );
                        case RepeatState.repeatSong:
                          return const Icon(
                            Icons.repeat_one_rounded,
                          );

                        case RepeatState.repeatPlaylist:
                          return const Icon(
                            Icons.repeat_rounded,
                          );
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ));
  }
}
