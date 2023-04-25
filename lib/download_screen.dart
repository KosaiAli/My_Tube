import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:my_youtube/Models/client.dart';
import 'package:my_youtube/data_center.dart';
import 'package:my_youtube/main.dart';
import 'package:my_youtube/result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

import 'Widgets/video_card.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen(this.url, {super.key});
  final String? url;
  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String directory = '';
  String count = '0';
  String total = '0';

  Future<String?> getDownloadPath() async {
    await Permission.storage.request();

    Directory? directory;
    try {
      directory = Directory('/storage/emulated/0/Main');
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
    await getDownloadPath().then((value) async {
      log('$value/$name$format');
      await dio.download(
        url,
        '$value/$name$format',
        onReceiveProgress: (count, total) {
          print('$count/$total');
        },
      );
    });
  }

  late VideoModel _result;
  TextEditingController textEditingController = TextEditingController();
  late PanelController panelController = PanelController();
  @override
  void initState() {
    textEditingController.text = widget.url ?? '';

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return ListView.builder(
          itemCount: dataCenter.videos.length,
          itemBuilder: (context, index) {
            return VideoCard(
              video: dataCenter.videos[index],
            );
          },
        );
      },
    );
  }
}
