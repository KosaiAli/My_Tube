import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../Models/playlist_model.dart';
import '../Models/database.dart';
import '../Models/video_model.dart';
import '../utility.dart';

class DataCenter extends ChangeNotifier {
  List<VideoModel> playListData = [];
  List<VideoModel> queueVideos = [];
  final List<String> _videosToDownload = [];
  final List<VideoModel> videos = [];

  late PlayList playList;

  bool loading = false;

  Dio dio = Dio();
  CancelToken cancelToken = CancelToken();

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
      var mainItem = itemList[0]['snippet'];
      playList = PlayList(
        mainItem['playlistId'],
        '${mainItem['title']} Mix',
        mainItem['thumbnails']['high']['url'],
      );

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
    dio = Dio();
    cancelToken = CancelToken();
    video.videoStatus = Downloadstatus.downloading;
    notifyListeners();
    String baseURL = 'clotted-boxcars.000webhostapp.com';
    String listAPI = 'api/videoDetails';
    var url = Uri.https(
      baseURL,
      '$listAPI/${video.id}',
    );
    try {
      if (video.videoUrl == null) {
        var response = await dio.getUri(url);

        var downloadLink = response.data['data']['mp4']['download'];
        video.videoUrl = downloadLink;
      }

      await getDownloadPath().then((value) async {
        await dio.download(video.thumb, '$value/${video.title}.jpg');

        await dio.download(video.videoUrl!, '$value/${video.title}.$format',
            onReceiveProgress: (count, total) {
          video.downloaded = count / total;
          notifyListeners();
        }, cancelToken: cancelToken);
      });

      exists(video.title, video.id);

      video.videoStatus = Downloadstatus.stopped;
      notifyListeners();
    } on DioError catch (e) {
      if (e.error.runtimeType != SocketException) {
        video.videoStatus = Downloadstatus.stopped;
        return;
      }

      video.videoStatus = Downloadstatus.error;
      notifyListeners();
    }
  }

  void initDownloadQueue() {
    queueVideos = videos.where((element) {
      if (!element.existedOnStorage) {
        element.videoStatus = Downloadstatus.inQueue;
        return !element.existedOnStorage;
      }

      return false;
    }).toList();
  }

  Future<void> downloadAll() async {
    for (var element in queueVideos) {
      await downloadVideo(element, 'mp4');
    }
  }

  void downloadList() async {
    final list = <VideoModel>[];
    for (var element in _videosToDownload) {
      final video = playListData.singleWhere((video) => element == video.id);
      video.videoStatus = Downloadstatus.inQueue;
      list.add(video);
    }
    queueVideos = list;
    downloadAll();
  }

  void skipItem(id) {
    var video = videos.singleWhere((element) => element.id == id);
    if (video.videoStatus == Downloadstatus.downloading) {
      dio.close();
      cancelToken.cancel();
    }

    queueVideos.removeWhere((element) => element.id == video.id);

    video.videoStatus = Downloadstatus.stopped;
    downloadAll();
    notifyListeners();
  }
}
