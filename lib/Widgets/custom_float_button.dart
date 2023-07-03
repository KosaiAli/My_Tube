import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/player_controller.dart';
import '../constant.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    return Positioned(
      bottom: -kBottombarHeight * musicPlayer.panelPosition * 2,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 1 - musicPlayer.panelPosition,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Provider.of<MusicPlayer>(context).currentPLayListID !=
                          null
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.blue,
                ),
                width: kBottomNavigationBarHeight,
                height: kBottomNavigationBarHeight,
              ),
            ),
            const SizedBox(
              height:
                  (kBottomNavigationBarHeight - kBottomNavigationBarHeight / 2),
            )
          ],
        ),
      ),
    );
  }
}
