import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../Models/playlist_model.dart';
import '../Models/database.dart';
import 'audio_model.dart';
import '../constant.dart';
import '../utility.dart';

class DataCenter extends ChangeNotifier {
  List<Audio> playListData = [];
  List<Audio> queueAudios = [];
  List<PlayList> playlists = [];
  Set<String> _audioToDownload = {};
  final List<Audio> audios = [];

  Audio? singleAudioToDownload;
  late PlayList playList;

  bool loading = false;

  Dio dio = Dio();
  http.Client client = http.Client();
  CancelToken cancelToken = CancelToken();

  ScrollController downloadScreenController = ScrollController();
  PanelController panelController = PanelController();

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
    _audioToDownload.clear();

    if (loading) {
      return;
    }

    panelController.open();
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
      client = http.Client();
      var response = await client.get(uri, headers: headers);

      var itemList = jsonDecode(response.body)['items'];
      var mainItem = itemList[0]['snippet'];
      playList = PlayList(
        playlistid: mainItem['playlistId'],
        name: '${mainItem['title']} Mix',
        image: '$kFolderUrlBase/${mainItem['title']}.jpg',
        networkImage: mainItem['thumbnails']['medium']['url'],
      );

      for (var audio in itemList) {
        final audioFile =
            File('$kFolderUrlBase/${audio['snippet']['title']}.mp3');

        final exists = await audioFile.exists();
        playListData.add(
          Audio(
            existedOnStorage: exists,
            thumb: audio['snippet']['thumbnails']['high']['url'],
            title: audio['snippet']['title'],
            audioid: audio['snippet']['resourceId']['videoId'],
            channelTitle: audio['snippet']['videoOwnerChannelTitle'],
            playlistId: audio['snippet']['playlistId'],
          ),
        );
      }
    } catch (error) {
      loading = false;
      rethrow;
    }
    loading = false;
    initDownloadAudios();
    notifyListeners();
  }

  Future<int> prepareDownloadSingle(String audioId) async {
    if (loading) {
      return -1;
    }

    panelController.open();
    loading = true;
    singleAudioToDownload = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    Map<String, String> paramters = {
      'part': 'snippet,contentDetails',
      'key': apiKey,
      'id': audioId,
    };

    String baseUrl = 'youtube.googleapis.com';

    Uri uri = Uri.https(
      baseUrl,
      '/youtube/v3/videos',
      paramters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    client = http.Client();
    var response = await client.get(uri, headers: headers);
    var details = jsonDecode(response.body)['items'][0];
    final audioFile =
        File('$kFolderUrlBase/${details['snippet']['title']}.mp3');
    final exists = await audioFile.exists();
    singleAudioToDownload = Audio(
      existedOnStorage: exists,
      thumb: details['snippet']['thumbnails']['high']['url'],
      title: details['snippet']['title'],
      audioid: details['id'],
      channelTitle: details['snippet']['channelTitle'],
    );

    final id =
        await DB.instance.addAudioToAudio(singleAudioToDownload!.tojson());

    singleAudioToDownload!.id = id;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    loading = false;

    return id;
  }

  void shuffleDownloadList(id) {
    if (_audioToDownload.contains(id)) {
      _audioToDownload.remove(id);
      notifyListeners();
      return;
    }
    _audioToDownload.add(id);
    notifyListeners();
  }

  List<String> get audioToDownload {
    return [..._audioToDownload];
  }

  void initDownloadAudios() async {
    await Permission.storage.request();
    audios.clear();

    final databaseAudios = await DB.instance.fetchAudios();
    for (var element in databaseAudios) {
      File audioFile = File('$kFolderUrlBase/${element['name']}.mp3');
      await audioFile.exists().then((exists) {
        audios.add(Audio.createPostResult(element, exists));
      });
    }

    print(audios);

    final databasePLaylist = await DB.instance.fetchPlaylists();
    playlists = [];
    for (var element in databasePLaylist) {
      playlists.add(PlayList.creatPlaylist(element));
    }

    notifyListeners();
  }

  Future<void> exists(name, id) async {
    final audioFile = File('$kFolderUrlBase/$name.mp3');

    final exists = await audioFile.exists();
    final index = audios.indexWhere((element) => element.audioid == id);
    audios[index].existedOnStorage = exists;

    notifyListeners();
  }

  void addAudio(Audio audio) {
    audios.add(audio);
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

  Future downloadAudio(Audio audio, String format, int times) async {
    if (times >= 4) {
      audio.audioStatus = Downloadstatus.error;
      notifyListeners();
      skipItem(audio.audioid);
      return;
    }
    if (audio.existedOnStorage) {
      return;
    }

    client = http.Client();
    dio = Dio();
    cancelToken = CancelToken();
    audio.audioStatus = Downloadstatus.downloading;
    notifyListeners();

    var url = Uri.parse(
        'https://api.akuari.my.id/downloader/youtube3?link=https://www.youtube.com/watch?v=${audio.audioid}&type=240');
    try {
      double fullSize;
      if (audio.audioUrl == null) {
        var response =
            await client.get(url).timeout(const Duration(seconds: 15));
        var downloadLink = jsonDecode(response.body)['audio']['audio'];
        String size = jsonDecode(response.body)['audio']['size'];
        size = size.substring(0, size.length - 2);
        fullSize = double.parse(size);
        fullSize = fullSize * pow(1000, 2);
        audio.size = fullSize;
        audio.audioUrl = downloadLink;
      }

      final path = await getDownloadPath();

      await dio.download(audio.thumb, '$path/${audio.title}.jpg');

      await dio.download(audio.audioUrl!, '$path/${audio.title}.mp3',
          onReceiveProgress: (count, total) {
        audio.downloaded = count / audio.size;

        notifyListeners();
      }, cancelToken: cancelToken);

      exists(audio.title, audio.audioid);

      audio.audioStatus = Downloadstatus.stopped;
      notifyListeners();
    } on TimeoutException catch (_) {
      await downloadAudio(audio, format, times + 1);
    } catch (e) {
      File file = File(
        '$kFolderUrlBase/${audio.title}.mp3',
      );
      await file.exists().then((exists) async {
        if (exists) {
          await file.delete();
        }
      });
    }
  }

  void initDownloadQueue() {
    queueAudios = audios.where((element) {
      if (!element.existedOnStorage) {
        element.audioStatus = Downloadstatus.inQueue;
        return !element.existedOnStorage;
      }

      return false;
    }).toList();
  }

  Future<void> downloadAll() async {
    try {
      for (var element in queueAudios) {
        await downloadAudio(element, 'mp3', 1);
      }
    } catch (e) {
      return;
    }
  }

  void downloadList() async {
    final list = <Audio>[];
    for (var element in _audioToDownload) {
      final audio =
          playListData.singleWhere((audio) => element == audio.audioid);
      audio.audioStatus = Downloadstatus.inQueue;
      list.add(audio);
    }
    queueAudios = list;
    downloadAll();
  }

  void skipItem(id) {
    var audio = audios.singleWhere((element) => element.audioid == id);

    dio.close();
    client.close();
    cancelToken.cancel();

    queueAudios.removeWhere((element) => element.audioid == audio.audioid);
    if (audio.audioStatus != Downloadstatus.error) {
      audio.audioStatus = Downloadstatus.stopped;
    }
    notifyListeners();
    downloadAll();
  }

  Future<List<Audio>> fetchPlaylistAudios(String id) async {
    final List<Audio> audios = [];

    final values = await DB.instance.fetchPlaylistAudios(id);
    for (var element in values) {
      final name = element['name'];
      File audioFile = File('$kFolderUrlBase/$name.mp3');

      final exists = await audioFile.exists();
      audios.add(Audio.createPostResult(element, exists));
    }

    return audios;
  }

  void scrollToAudioIndex(audiosNotDownloaded) {
    selectedPageIndex = 1;

    _audioToDownload = audiosNotDownloaded;
    int index = audios
        .indexWhere((element) => element.audioid == _audioToDownload.first);

    downloadScreenController.animateTo(index * (kAudiooCardSize + 15),
        duration: const Duration(milliseconds: 300), curve: Curves.easeInExpo);
  }
}
