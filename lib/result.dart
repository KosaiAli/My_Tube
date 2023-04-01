// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class Result {
  final String? title;
  final String? thumb;
  final String? filesize_audio;
  final String? filesize_video;
  final String? audio;
  final String? audio_asli;
  final String? video;
  final String? video_asli;

  Result(
      {this.title,
      this.thumb,
      this.filesize_audio,
      this.filesize_video,
      this.audio,
      this.audio_asli,
      this.video,
      this.video_asli});
  factory Result.createPostResult(Map object) {
    return Result(
      title: object['title'],
      thumb: object['thumb'],
      filesize_audio: object['filesize_audio'],
      filesize_video: object['filesize_video'],
      audio: object['audio']['audio'],
      audio_asli: object['audio_asli'],
      video: object['mp4']['download'],
      video_asli: object['video_asli'],
    );
  }
  static Future<Result> connectToApi(String url) async {
    print('connecting ..');
    String apiUrl =
        'https://api.akuari.my.id/downloader/youtube3?link=$url&type=144';
    // var response = await Dio().getUri(Uri.parse(apiUrl));
    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    if (response.statusCode == 200) {
      return Result.createPostResult(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load url');
    }
  }
}
