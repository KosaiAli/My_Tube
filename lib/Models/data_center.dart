import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../Models/playlist_model.dart';
import '../Models/database.dart';
import '../Models/video_model.dart';
import '../constant.dart';
import '../utility.dart';

class DataCenter extends ChangeNotifier {
  List<VideoModel> playListData = [];
  List<VideoModel> queueVideos = [];
  List<PlayList> playlists = [];
  Set<String> _videosToDownload = {};
  final List<VideoModel> videos = [];

  late PlayList playList;

  bool loading = false;

  Dio dio = Dio();
  http.Client client = http.Client();
  CancelToken cancelToken = CancelToken();

  ScrollController downloadScreenController = ScrollController();

  int _selectedPageIndex = 0;

  set selectedPageIndex(index) {
    _selectedPageIndex = index;
    notifyListeners();
  }

  int get selectedPageIndex {
    return _selectedPageIndex;
  }

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
      var response = await client.get(uri, headers: headers);

      var itemList = jsonDecode(response.body)['items'];
      var mainItem = itemList[0]['snippet'];
      playList = PlayList(
        mainItem['playlistId'],
        '${mainItem['title']} Mix',
        mainItem['thumbnails']['high']['url'],
      );

      for (var video in itemList) {
        File videoFile =
            File('$kFolderUrlBase/${video['snippet']['title']}.mp4');

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
    initDownloadVideos();
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
        File videoFile = File('$kFolderUrlBase/${element['Name']}.mp4');
        videoFile.exists().then((exists) {
          videos.add(VideoModel.createPostResult(element, exists));
        });
      }
    });

    await VideoDataBase.instance.fetchPlaylists().then((value) {
      playlists = [];
      for (var element in value) {
        playlists.add(PlayList.creatPlaylist(element));
      }
    });

    notifyListeners();
  }

  Future<void> exists(name, id) async {
    File videoFile = File('$kFolderUrlBase/$name.mp4');

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
      directory = Directory(kFolderUrlBase);
      if (!await directory.exists()) {
        directory.create();
      }
    } catch (err) {
      return null;
    }

    return directory.path;
  }

  Future downloadVideo(VideoModel video, String format, times) async {
    if (times >= 4) {
      video.videoStatus = Downloadstatus.error;
      notifyListeners();
      skipItem(video.id);
      return;
    }

    if (video.existedOnStorage) {
      return;
    }

    client = http.Client();
    dio = Dio();
    cancelToken = CancelToken();
    video.videoStatus = Downloadstatus.downloading;
    notifyListeners();

    // String baseURL = 'clotted-boxcars.000webhostapp.com';
    // String listAPI = 'api/videoDetails';
    // print(video.id);
    // var url = Uri.https(
    //   baseURL,
    //   '$listAPI/${video.id}',
    // );

    var url = Uri.parse(
        'https://apimu.my.id/downloader/youtube3?link=https://www.youtube.com/watch?v=${video.id}&type=240');
    try {
      if (video.videoUrl == null) {
        var response = await client.get(
          url,
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
        var downloadLink = jsonDecode(response.body)['mp4']['download'];
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
    } on TimeoutException catch (_) {
      await downloadVideo(video, format, times + 1);
    } catch (e) {
      File file = File(
        '$kFolderUrlBase/${video.title}.mp4',
      );
      await file.exists().then((exists) async {
        if (exists) {
          await file.delete();
        }
      });
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
    try {
      for (var element in queueVideos) {
        await downloadVideo(element, 'mp4', 1);
      }
    } catch (e) {
      return;
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

    dio.close();
    client.close();
    cancelToken.cancel();

    queueVideos.removeWhere((element) => element.id == video.id);
    if (video.videoStatus != Downloadstatus.error) {
      video.videoStatus = Downloadstatus.stopped;
    }
    notifyListeners();
    downloadAll();
  }

  List<VideoModel> fetchPlaylistVideos(String id) {
    return [
      ...videos.where((element) {
        return element.playlistId == id;
      }).toList()
    ];
  }

  void scrollToVideoIndex(videosNotDownloaded) {
    selectedPageIndex = 1;
    _videosToDownload = videosNotDownloaded;
    int index =
        videos.indexWhere((element) => element.id == _videosToDownload.first);

    downloadScreenController.animateTo(index * (kVideoCardSize + 15),
        duration: const Duration(milliseconds: 300), curve: Curves.easeInExpo);
  }
}
