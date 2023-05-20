import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_youtube/Models/video_controller.dart';
import 'package:my_youtube/constant.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import './Models/data_center.dart';
import './Models/database.dart';
import './Screens/download_screen.dart';
import './Models/video_model.dart';
import 'Screens/edit_playlist_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/playlist_player_screen.dart';

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
          create: (ctx) => VideoController(buildContext: ctx),
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
  late StreamSubscription _dataSupscripotion;
  bool catched = false;
  String _listenedText = '';
  late List<Widget> _pages;
  PanelController panelController = PanelController();
  final List<VideoModel> videosToDownload = [];

  PageController pageController = PageController();
  @override
  void initState() {
    Provider.of<DataCenter>(context, listen: false).initDownloadVideos();
    _pages = [const HomeScreen(), const DownloadScreen()];
    ReceiveSharingIntent.getTextStream().listen((text) async {
      panelController.open();
      await Provider.of<DataCenter>(context, listen: false)
          .prepareDownloadList(text);
    });
    super.initState();
  }

  double width = 56;
  // Future<void> download() async {
  //   if (widget.url != null) {
  //     Result.connectToApi(textEditingController.text).then((value) async {
  //       _result = value;
  //       panelController.show();
  //       panelController.open();
  //       print(panelController.isAttached);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: Builder(builder: (context) {
        //   var shape = context.findAncestorRenderObjectOfType() as RenderBox;

        //   width = shape.size.width;
        //   print(width);
        //   return FloatingActionButton(
        //     onPressed: () {},
        //   );
        // }),
        // bottomNavigationBar: BottomAppBar(
        //   notchMargin: 5,
        //   color: Colors.blue,
        //   height: 46,
        //   shape: CircularNotchedRectangle(),
        // ),
        body: SlidingUpPanel(
            controller: panelController,
            color: kScaffoldColor,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.70,
            panel: dataCenter.playListData.isNotEmpty
                ? Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 50),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: ListView.builder(
                                itemCount: dataCenter.playListData.length,
                                itemBuilder: (context, index) {
                                  var video = dataCenter.playListData[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              video.thumb.toString(),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(video.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge),
                                              const SizedBox(height: 5),
                                              Text(video.channelTitle!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  video.existedOnStorage
                                                      ? const Text(
                                                          'downloaded',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.green),
                                                        )
                                                      : const Text(
                                                          'not downloaded',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 1.3,
                                          child: Checkbox(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            value: dataCenter.videosToDownload
                                                .contains(video.videoid),
                                            onChanged: (_) {
                                              dataCenter.shuffleDownloadList(
                                                  video.videoid);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await VideoDataBase.instance
                                .createPLaylist(dataCenter);
                            dataCenter.downloadList();
                            panelController.close();
                            // print(await DownloadnClient.getListDownloadLisnks(
                            //     list));
                            // dataCenter.initDownloadVideos();
                          },
                          child: Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 60,
                            child: const Text('download'),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text('loading'),
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
                      VideoDataBase.instance
                          .fetchPlaylistVideos(dataCenter.playList.playlistid)
                          .then((value) => print(value));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Provider.of<VideoController>(context)
                                      .currentPLayListID !=
                                  null
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.blue),
                      width: kBottomNavigationBarHeight,
                      height: kBottomNavigationBarHeight,
                    ),
                  ),
                ),
              ],
            )),
      );
    });
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
}

class MyCustomClipper extends CustomPainter {
  MyCustomClipper({
    this.width = 0.0,
  });
  double width;

  Path getpath(size) {
    double center = size.width / 2;
    double ratio = width / 28;

    Path path = Path();
    path.moveTo(0, 0);

    path.lineTo(center - width - 25 * ratio, 0);

    var a = width + 5.8 * ratio;
    var b = 0.0;
    var r = width + 5 * ratio;
    var x = (a * pow(r, 2) -
            sqrt(pow(a, 2) * pow(b, 2) * pow(r, 2) +
                pow(b, 4) * pow(r, 2) -
                pow(b, 2) * pow(r, 4))) /
        (pow(a, 2) + pow(b, 2));

    var y = sqrt(pow(r, 2) - pow(x, 2));

    path.quadraticBezierTo(center - a, b, center - x, y);

    path.arcToPoint(Offset(center + x, y),
        radius: Radius.circular(r), clockwise: false);

    path.quadraticBezierTo(center + a, b, center + width + 25 * ratio, 0);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF212121);
    Path content = getpath(size);
    content.lineTo(size.width, size.height);
    content.lineTo(0, size.height);
    content.lineTo(0, 0);
    canvas.drawPath(content, paint);
    canvas.drawPath(
        getpath(size),
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.grey[700]!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
