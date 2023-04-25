// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class VideoModel {
  final String title;
  final String thumb;
  final String? filesize_video;
  String? video;
  final String? id;
  final String? channelTitle;
  final String? playlistId;
  final bool existedOnStorage;

  VideoModel(
      {required this.title,
      required this.thumb,
      this.filesize_video,
      this.video,
      this.id,
      this.channelTitle,
      this.playlistId,
      required this.existedOnStorage});

  factory VideoModel.createPostResult(Map object, exists) {
    return VideoModel(
      title: object['title'] ?? object['Name'],
      thumb: object['thumbnail'] ?? object['Image'],
      filesize_video: object['filesize_video'],
      // video: object['mp4']['download'] ?? '',
      id: object['id'],
      channelTitle: object['channelTitle'],
      existedOnStorage: exists,
    );
  }
  // static Future<VideoModel> connectToApi(String url) async {
  //   print('connecting ..');
  //   String apiUrl =
  //       'https://api.akuari.my.id/downloader/youtube3?link=$url&type=144';
  //   // var response = await Dio().getUri(Uri.parse(apiUrl));
  //   print(apiUrl);
  //   final response = await http.get(Uri.parse(apiUrl));
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //     return VideoModel.createPostResult(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load url');
  //   }
  // }
  Map<String, String> tojson() {
    return {
      'Id': id.toString(),
      'Name': title.toString(),
      'Image': thumb.toString(),
      'PlaylistId': playlistId.toString(),
      'channelTitle': channelTitle.toString()
    };
  }
}
