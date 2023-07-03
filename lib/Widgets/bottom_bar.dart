import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_youtube/Models/player_controller.dart';

import '../Models/data_center.dart';
import '../constant.dart';
import './custom_clipper.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  Expanded getBottomIconButton(
      {required int index,
      required IconData selectedIcon,
      required IconData icon,
      required DataCenter dataCenter}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          dataCenter.selectedPageIndex = index;
        },
        child: Container(
          width: 40,
          color: Colors.transparent,
          child: Icon(
            dataCenter.selectedPageIndex == index ? icon : selectedIcon,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayer>(context);
    final dataCenter = Provider.of<DataCenter>(context);
    return Positioned(
      bottom: -kBottombarHeight * musicPlayer.panelPosition * 2,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 1 - musicPlayer.panelPosition,
        child: CustomPaint(
          painter: MyCustomClipper(width: kBottomNavigationBarHeight / 2),
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            width: double.infinity,
            child: Row(
              children: [
                getBottomIconButton(
                  icon: Icons.home,
                  selectedIcon: Icons.home_outlined,
                  index: 0,
                  dataCenter: dataCenter,
                ),
                const SizedBox(width: kBottomNavigationBarHeight),
                getBottomIconButton(
                  icon: Icons.download,
                  selectedIcon: Icons.download_outlined,
                  index: 1,
                  dataCenter: dataCenter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
