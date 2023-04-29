import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import './Models/data_center.dart';
import './Models/database.dart';
import './Screens/download_screen.dart';
import './Models/video_model.dart';
import './Screens/video_player_screen.dart';

void main() {
  runApp(MaterialApp(
      home: ChangeNotifierProvider(
          create: (context) => DataCenter(), child: const MainScreen())));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ReceiveSharingIntent.getInitialText().then((value) {
    //   if (value != null) {
    //     print('1');
    //     Navigator.of(context).pushReplacement(MaterialPageRoute(
    //       builder: (context) => MainScreen(value),
    //     ));
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(
          size: 50,
        ),
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
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  late StreamSubscription _dataSupscripotion;
  bool catched = false;
  String _listenedText = '';
  late List<Widget> _pages;
  PanelController panelController = PanelController();
  final List<VideoModel> videosToDownload = [];

  @override
  void initState() {
    Provider.of<DataCenter>(context, listen: false).initDownloadVideos();
    _pages = [const VideoPLayerScreen(), const DownloadScreen(null)];
    ReceiveSharingIntent.getTextStream().listen((text) async {
      panelController.open();
      await Provider.of<DataCenter>(context, listen: false)
          .prepareDownloadList(text);
    });
    super.initState();
  }

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
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedPageIndex,
            onTap: _selectPage,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.download_rounded), label: 'home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.download_rounded), label: 'download'),
            ]),
        body: SlidingUpPanel(
            controller: panelController,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.70,
            panel: dataCenter.playListData.isNotEmpty
                ? Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 50),
                          Expanded(
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
                                            Text(
                                              video.title,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              video.channelTitle!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
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
                                                            color: Colors.red),
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
                                              .contains(video.id),
                                          onChanged: (_) {
                                            dataCenter
                                                .shuffleDownloadList(video.id);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
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
                            child: const Text('download'),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text('loading'),
            body: _pages[_selectedPageIndex]),
      );
    });
  }
}
