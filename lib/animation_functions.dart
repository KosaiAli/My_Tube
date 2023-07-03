import 'package:flutter/material.dart';

import './size_confg.dart';
import './Models/player_controller.dart';

double safeAreaPadding(MusicPlayer musicPlayer, MediaQueryData media) {
  return musicPlayer.panelController.isPanelOpen ? media.padding.top : 0;
}

double lowMarginLimit(MusicPlayer musicPlayer, MediaQueryData media) {
  return musicPlayer.panelController.isPanelOpen
      ? getProportionateScreenHeight(5) + media.padding.top
      : getProportionateScreenHeight(5);
}

double getTopMargin(Size size, MusicPlayer musicPlayer) {
  double value;

  value = size.height * 0.18 * musicPlayer.panelPosition -
      size.height * 0.18 * musicPlayer.playlistItemControllerPosition;
  return getProportionateScreenHeight(value);
}

double getOpacity(MusicPlayer musicPlayer) {
  double panelPercent = 1 -
      musicPlayer.panelPosition +
      musicPlayer.playlistItemControllerPosition;

  return 1 - panelPercent * 5;
}

double getReversedOpacity(MusicPlayer musicPlayer) {
  if (musicPlayer.panelPosition == 0) {
    return 1.0;
  }
  double panelPercent =
      musicPlayer.panelPosition - musicPlayer.playlistItemControllerPosition;

  return 1 - panelPercent * 5;
}

double getHorizontalPadding(context) {
  final media = MediaQuery.of(context);
  final size = media.size;
  final padding = (size.width - (60 + size.width * 0.70));
  final horizontalPadding = getProportionateScreenWidth(padding);
  return horizontalPadding;
}

changeColor(Color? color, double ratio) {
  if (color == null) return Colors.grey;

  double luminance = color.computeLuminance();
  Color newColor =
      HSLColor.fromColor(color).withLightness(luminance + ratio).toColor();
  return newColor;
}
