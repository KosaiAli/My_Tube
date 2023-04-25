import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_youtube/Models/client.dart';
import 'package:my_youtube/Models/playlist_model.dart';
import 'package:my_youtube/database.dart';
import 'package:my_youtube/result.dart';
import 'package:my_youtube/utility.dart';

class DataCenter extends ChangeNotifier {
  List<VideoModel> playListData = [];
  final List<String> _videosToDownload = [];
  final List<VideoModel> videos = [];

  late PlayList playList;

  bool loading = false;

  Future prepareDownloadList(String text) async {
    playListData.clear();
    _videosToDownload.clear();
    print(text);
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
      'key': api_key,
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
      // log(response.body);
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

  void ShuffleDownloadList(id) {
    if (_videosToDownload.contains(id)) {
      _videosToDownload.remove(id);
      notifyListeners();
      return;
    }
    _videosToDownload.add(id);
    print(_videosToDownload);
    notifyListeners();
  }

  List<String> get videosToDownload {
    return [..._videosToDownload];
  }

  void initDownloadVideos() async {
    videos.clear();
    await VideoDataBase.instance.fetchVideos().then((value) {
      for (var element in value) {
        print(element);
        File videoFile =
            File('/storage/emulated/0/Videos/${element['Name']}.mp4');
        videoFile.exists().then((exists) {
          videos.add(VideoModel.createPostResult(element, exists));
        });
      }
    });
    notifyListeners();
  }
}
