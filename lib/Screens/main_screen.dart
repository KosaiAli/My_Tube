import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'home/home_screen.dart';
import 'downloads/download_screen/download_screen.dart';
import 'downloads/download_single/download_single.dart';
import 'downloads/download_playlist/download_playlist.dart';
import '../utilites.dart';
import '../Widgets/bottom_bar.dart';
import '../Widgets/custom_float_button.dart';
import '../Models/audio_model.dart';
import '../Models/data_center.dart';
import '../constant.dart';
import '../size_confg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool hasList = false;

  final List<Audio> videosToDownload = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Provider.of<DataCenter>(context, listen: false).initDownloadAudios();

    ReceiveSharingIntent.getTextStream().listen((String text) async {
      getTextStream(text);
    });
    super.initState();
  }

  Future<void> getTextStream(text) async {
    setState(() {
      hasList = text.contains('list');
    });
    if (text.contains('list')) {
      await Provider.of<DataCenter>(context, listen: false)
          .prepareDownloadList(text);
      return;
    }
    final videoID = getVideoId(text);

    await Provider.of<DataCenter>(context, listen: false)
        .prepareDownloadSingle(videoID);
  }

  IgnorePointer getScreen(int index, Widget child, DataCenter dataCenter) {
    return IgnorePointer(
      ignoring: dataCenter.selectedPageIndex != index,
      child: Opacity(
          opacity: dataCenter.selectedPageIndex == index ? 1 : 0, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final mediaQuery = MediaQuery.of(context);
    final dataCenter = Provider.of<DataCenter>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: const Color(0xFF212121),
      body: SlidingUpPanel(
        color: kScaffoldColor,
        minHeight: 0,
        isDraggable: false,
        controller: dataCenter.panelController,
        maxHeight: mediaQuery.size.height,
        panel: hasList ? const DownloadPlaylist() : const DownloadSingle(),
        body: WillPopScope(
          onWillPop: () async {
            if (dataCenter.panelController.isPanelOpen) {
              await dataCenter.panelController.close();
              return false;
            }
            return true;
          },
          child: Stack(
            children: [
              getScreen(0, const HomeScreen(), dataCenter),
              getScreen(1, const DownloadScreen(), dataCenter),
              const CustomBottomBar(),
              const CustomFloatingButton(),
            ],
          ),
        ),
      ),
    );
  }
}
