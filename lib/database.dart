import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my_youtube/data_center.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import './Models/playlist_model.dart';

class VideoDataBase {
  static final VideoDataBase instance = VideoDataBase._init();

  static Database? _database;

  VideoDataBase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('videos.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _creatDB);
  }

  Future _creatDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE PlayLists (
  Id TEXT PRIMARY KEY UNIQUE,
  Name TEXT NOT NULL,
  Image TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE Video (
  Id TEXT PRIMARY KEY UNIQUE,
  Name TEXT NOT NULL,
  Image TEXT NOT NULL,
  PlaylistId TEXT NOT NULL,
  channelTitle TEXT NOT NULL
)
''');
  }

  Future createPLaylist(DataCenter dataInstance) async {
    final db = await instance.database;
    // await db.delete('Video');
    // await db.delete('PlayLists');
    Map<String, String> playlistData = dataInstance.playList.toJson();

    final playList = await db.rawQuery(
        'SELECT * FROM PlayLists WHERE Id LIKE "%${playlistData['Id']}%" ');

    if (playList.isEmpty) {
      await db.insert('PlayLists', playlistData);
    }

    final videos = dataInstance.videosToDownload;
    final downloadedVideos = await db.rawQuery(
        'SELECT * FROM Video WHERE PlaylistId LIKE "%${playlistData['Id']}%" ');

    videos.removeWhere((videoId) {
      return downloadedVideos
          .any((downloadedVideo) => downloadedVideo['Id'] == videoId);
    });
    print(dataInstance.videosToDownload);
    for (var id in videos) {
      final video =
          dataInstance.playListData.firstWhere((element) => element.id == id);

      Map<String, String> videoData = video.tojson();

      await db.insert('Video', videoData);
    }

    final maps = await db.rawQuery(
        'SELECT * FROM Video WHERE PlaylistId LIKE "%${playlistData['Id']}%" ');
    // maps.forEach((element) {
    //   print(element);
    // });
    print(maps);
  }

  Future<List<Map<String, Object?>>> fetchVideos() async {
    final db = await instance.database;
    return await db.rawQuery('SELECT * FROM Video');
  }
}
