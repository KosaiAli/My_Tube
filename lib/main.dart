import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import './constant.dart';
import './Models/data_center.dart';
import './Models/video_model.dart';
import './Models/video_controller.dart';
import './Screens/download_screen.dart';
import './Screens/edit_playlist_screen.dart';
import './Screens/home_screen.dart';
import './Widgets/custom_clipper.dart';
import './Widgets/download_panel.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => DataCenter(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => VideoController(),
        ),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          PlayListEditScreen.routeName: (ctx) => const PlayListEditScreen()
        },
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PanelController panelController = PanelController();
  final List<VideoModel> videosToDownload = [];

  @override
  void initState() {
    Provider.of<DataCenter>(context, listen: false).initDownloadVideos();

    ReceiveSharingIntent.getTextStream().listen((text) async {
      panelController.open();
      await Provider.of<DataCenter>(context, listen: false)
          .prepareDownloadList(text);
    });
    super.initState();
  }

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

  IgnorePointer getScreen(int index, Widget child, DataCenter dataCenter) {
    return IgnorePointer(
      ignoring: dataCenter.selectedPageIndex != index,
      child: Opacity(
          opacity: dataCenter.selectedPageIndex == index ? 1 : 0, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SlidingUpPanel(
            controller: panelController,
            color: kScaffoldColor,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.70,
            panel: DownloadPanel(panelController: panelController),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                getScreen(0, const HomeScreen(), dataCenter),
                getScreen(1, const DownloadScreen(), dataCenter),
                CustomPaint(
                  painter: MyCustomClipper(
                    width: kBottomNavigationBarHeight / 2,
                  ),
                  child: SizedBox(
                    height: kBottomNavigationBarHeight,
                    width: double.infinity,
                    child: Row(
                      children: [
                        getBottomIconButton(
                            icon: Icons.home,
                            selectedIcon: Icons.home_outlined,
                            index: 0,
                            dataCenter: dataCenter),
                        const SizedBox(width: kBottomNavigationBarHeight),
                        getBottomIconButton(
                            icon: Icons.download,
                            selectedIcon: Icons.download_outlined,
                            index: 1,
                            dataCenter: dataCenter),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: kBottomNavigationBarHeight -
                      kBottomNavigationBarHeight / 2,
                  child: GestureDetector(
                    onTap: () {
                      // VideoDataBase.instance.createPLaylist(dataCenter);
                      // VideoDataBase.instance.deleteAll();
                      Provider.of<DataCenter>(context, listen: false)
                          .initDownloadVideos();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Provider.of<VideoController>(context)
                                    .currentPLayListID !=
                                null
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.blue,
                      ),
                      width: kBottomNavigationBarHeight,
                      height: kBottomNavigationBarHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
