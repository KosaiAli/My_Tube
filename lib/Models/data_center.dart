import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../http/client.dart';
import '../Models/playlist_model.dart';
import '../Models/database.dart';
import '../Models/result.dart';
import '../utility.dart';

class DataCenter extends ChangeNotifier {
  List<VideoModel> playListData = [];
  final List<String> _videosToDownload = [];
  final List<VideoModel> videos = [];

  late PlayList playList;

  bool loading = false;

  var dio = Dio();

  Future prepareDownloadList(String text) async {
    playListData.clear();
    _videosToDownload.clear();

    if (loading) {
      return;
    }
    loading = true;
    String playlistID;
    try {
      playlistID =
          text.substring(text.indexOf('list=') + 5, text.indexOf('&playnext'));
    } catch (e) {
      try {
        playlistID = text.substring(
            text.indexOf('list=') + 5, text.indexOf('&start_radio'));
      } catch (e2) {
        playlistID = text.substring(text.indexOf('list=') + 5, text.length);
      }
    }

    Map<String, String> paramters = {
      'part': 'snippet,contentDetails',
      'key': apiKey,
      'playlistId': playlistID,
      'maxResults': '20',
      'mine': 'true'
    };
    String baseUrl = 'youtube.googleapis.com';

    Uri uri = Uri.https(
      baseUrl,
      '/youtube/v3/playlistItems',
      paramters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    try {
      var response = await http.get(uri, headers: headers);

      var itemList = jsonDecode(response.body)['items'];
      playList = PlayList(
          itemList[0]['snippet']['playlistId'],
          '${itemList[0]['snippet']['title']} Mix',
          itemList[0]['snippet']['thumbnails']['high']['url']);

      for (var video in itemList) {
        File videoFile =
            File('/storage/emulated/0/Videos/${video['snippet']['title']}.mp4');

        await videoFile.exists().then((value) {
          playListData.add(
            VideoModel(
                existedOnStorage: value,
                thumb: video['snippet']['thumbnails']['high']['url'],
                title: video['snippet']['title'],
                id: video['snippet']['resourceId']['videoId'],
                channelTitle: video['snippet']['videoOwnerChannelTitle'],
                playlistId: video['snippet']['playlistId']),
          );
        });
      }
    } catch (error) {
      loading = false;
      rethrow;
    }
    loading = false;
    notifyListeners();
  }

  void shuffleDownloadList(id) {
    if (_videosToDownload.contains(id)) {
      _videosToDownload.remove(id);
      notifyListeners();
      return;
    }
    _videosToDownload.add(id);
    notifyListeners();
  }

  List<String> get videosToDownload {
    return [..._videosToDownload];
  }

  void initDownloadVideos() async {
    videos.clear();
    await VideoDataBase.instance.fetchVideos().then((value) {
      for (var element in value) {
        File videoFile =
            File('/storage/emulated/0/Videos/${element['Name']}.mp4');
        videoFile.exists().then((exists) {
          videos.add(VideoModel.createPostResult(element, exists));
        });
      }
    });
    notifyListeners();
  }

  Future<void> exists(name, id) async {
    File videoFile = File('/storage/emulated/0/Videos/$name.mp4');

    await videoFile.exists().then((value) {
      final index = videos.indexWhere((element) => element.id == id);
      videos[index].existedOnStorage = value;
    });
    notifyListeners();
  }

  void addVideo(VideoModel video) {
    videos.add(video);
    notifyListeners();
  }

  Future<String?> getDownloadPath() async {
    await Permission.storage.request();

    Directory? directory;
    try {
      directory = Directory('/storage/emulated/0/Videos');
      if (!await directory.exists()) {
        directory.create();
      }
    } catch (err) {
      return null;
    }

    return directory.path;
  }

  Future downloadVideo(VideoModel video, String format) async {
    if (video.existedOnStorage) {
      return;
    }

    video.downloading = true;
    notifyListeners();
    var downloadLink = await DownloadnClient.getListDownloadLisnk(video.id);

    await getDownloadPath().then((value) async {
      log('$value/${video.title}$format');
      await dio.download(
        downloadLink,
        '$value/${video.title}.$format',
        onReceiveProgress: (count, total) {
          video.downloaded = count / total;
          notifyListeners();
        },
      );
    });
    exists(video.title, video.id);

    video.downloading = false;
    notifyListeners();
  }

  Future<void> downloadAll() async {
    for (var element in videos) {
      if (!element.existedOnStorage) {
        await downloadVideo(element, 'mp4');
      }
    }
  }

  void downloadList() async {
    for (var element in _videosToDownload) {
      final video = playListData.singleWhere((video) => element == video.id);
      await downloadVideo(video, 'mp4');
    }
  }
}
