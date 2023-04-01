import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_youtube/result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MaterialApp(home: MainScreen()));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String directory = '';
  String count = '0';
  String total = '0';
  late VideoPlayerController videoPlayerController;

  Future<String?> getDownloadPath() async {
    await Permission.storage.request();

    Directory? directory;
    try {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory.create();
      }
    } catch (err) {
      return null;
    }

    return directory.path;
  }

  var dio = Dio();
  Future downloadVideo(String url, String name, String format) async {
    getDownloadPath().then((value) {
      setState(() {
        directory = value!;
      });
    });
    print('$directory/$name$format');
    await dio.download(
      url,
      '$directory/$name$format',
      onReceiveProgress: (count, total) {
        setState(() {
          this.count = count.toString();
          this.total = total.toString();
        });
      },
    );
  }

  late Result _result;
  TextEditingController textEditingController = TextEditingController();
  bool filePicked = false;
  @override
  void initState() {
    // videoPlayerController = VideoPlayerController.file(file)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       TextField(
    //         controller: textEditingController,
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           Result.connectToApi(textEditingController.text).then((value) {
    //             setState(() {
    //               _result = value;
    //             });
    //             print(_result.title);
    //           });
    //         },
    //         child: Text('search'),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           print(_result.video);
    //           downloadVideo(_result.video!, _result.title!, '.mp4');
    //         },
    //         child: Text('download'),
    //       ),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [Text('$count/$total')],
    //       )
    //     ],
    //   ),
    // );
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          filePicked && videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController),
                )
              : Container(),
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  File file = File(
                    '/storage/emulated/0/',
                  );
                  Directory dir = Directory('/storage/emulated/0/Download');

                  print(file.path);
                  // videoPlayerController = VideoPlayerController.file(file)
                  //   ..initialize().then((value) {
                  //     setState(() {
                  //       filePicked = true;
                  //     });
                  //   });

                  print(videoPlayerController.value.duration);
                },
                child: Text('pick')),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                await videoPlayerController.pause().then((value) {});
              },
              child: Icon(Icons.play_arrow))
        ],
      ),
    );
  }
}
