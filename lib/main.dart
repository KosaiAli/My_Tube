import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'Models/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();

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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  PanelController panelController = PanelController();
  final List<VideoModel> videosToDownload = [];
  bool hasList = false;

  late AppLifecycleState _appLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
    log(state.toString());
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Provider.of<DataCenter>(context, listen: false).initDownloadVideos();

    ReceiveSharingIntent.getTextStream().listen((String text) async {
      getTextStream(text);
    });
    super.initState();
  }

  Future<void> getTextStream(text) async {
    log(text);
    log(text.contains('list').toString());
    setState(() {
      hasList = text.contains('list');
    });
    if (text.contains('list')) {
      panelController.open();
      await Provider.of<DataCenter>(context, listen: false)
          .prepareDownloadList(text);
      return;
    }
    var videoID;
    if (text.contains('youtu.be')) {
      videoID = text.substring(text.indexOf('youtu.be') + 9);
    } else if (text.contains('watch?v')) {
      videoID = text.substring(
          text.indexOf('watch?v') + 8, text.indexOf('watch?v') + 19);
    }
    panelController.open();
    await Provider.of<DataCenter>(context, listen: false)
        .prepareDownloadSingle(videoID);
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) {
    //     return DownloadSingle(videoID: videoID);
    //   },
    // ));
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
    final mediaQuery = MediaQuery.of(context);
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SlidingUpPanel(
            isDraggable: false,
            controller: panelController,
            color: kScaffoldColor,
            minHeight: 0,
            maxHeight: mediaQuery.size.height * 0.70,
            panel: hasList
                ? DownloadPanel(panelController: panelController)
                : DownloadSingle(panelController: panelController),
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
                    onTap: () {},
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

class DownloadSingle extends StatefulWidget {
  const DownloadSingle({super.key, required this.panelController});
  final PanelController panelController;
  @override
  State<DownloadSingle> createState() => _DownloadSingleState();
}

class _DownloadSingleState extends State<DownloadSingle> {
  late int id;
  bool inAnyPLaylist = false;
  @override
  void initState() {
    // init();
    super.initState();
  }

  // Future<void> init() async {
  //   await Provider.of<DataCenter>(context, listen: false)
  //       .prepareDownloadSingle(widget.videoID)
  //       .then((value) {
  //     setState(() {
  //       id = value;
  //     });
  //   });
  // }

  int selectedplaylist = -1;
  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(builder: (context, dataCenter, child) {
      if (dataCenter.singleVideoToDownload != null) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              dataCenter.singleVideoToDownload!.thumb
                                  .toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dataCenter.singleVideoToDownload!.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 5),
                              Text(
                                  dataCenter
                                      .singleVideoToDownload!.channelTitle!,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  dataCenter.singleVideoToDownload!
                                          .existedOnStorage
                                      ? const Text(
                                          'downloaded',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green),
                                        )
                                      : const Text(
                                          'not downloaded',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.red),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                ...dataCenter.playlists.map(
                  (e) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 100,
                            child: Image.file(
                              File(e.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.name,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          FutureBuilder(
                              future: VideoDataBase.instance.hasVideo(e.id,
                                  dataCenter.singleVideoToDownload!.videoid),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data == true) {
                                    inAnyPLaylist = true;
                                  }
                                  return Checkbox(
                                    value: snapshot.data == true
                                        ? snapshot.data
                                        : selectedplaylist == e.id,
                                    onChanged: (value) {
                                      if (selectedplaylist == e.id!) {
                                        setState(() {
                                          selectedplaylist = -1;
                                        });
                                        return;
                                      }
                                      setState(() {
                                        selectedplaylist = e.id!;
                                      });
                                    },
                                  );
                                }
                                return const CircularProgressIndicator();
                              })
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.red,
                                ),
                      ),
                      onPressed: () async {
                        await VideoDataBase.instance
                            .deleteVideo(dataCenter.singleVideoToDownload!.id);

                        dataCenter.initDownloadVideos();
                        widget.panelController.close();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        child: Text(
                          'Submit',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.green,
                                  ),
                        ),
                        onPressed: () async {
                          if (selectedplaylist == -1) {
                            widget.panelController.close();
                            return;
                          }

                          await VideoDataBase.instance
                              .addToPLaylist(selectedplaylist, id)
                              .then((value) {
                            dataCenter.initDownloadVideos();
                            widget.panelController.close();
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
