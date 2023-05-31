import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'data_center.dart';

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

    return await openDatabase(path, version: 2, onCreate: _creatDB);
  }

  Future _creatDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE PlayLists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  playlistid TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  image TEXT NOT NULL,
  networkImage TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE Video (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  videoid TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  image TEXT NOT NULL,
  channelTitle TEXT NOT NULL
)
''');
    await db.execute('''
  CREATE TABLE playlistvideos (
  videoid INTEGER NOT NULL,
  playlistid INTEGER NOT NULL
)
''');
  }

  Future createPLaylist(DataCenter dataInstance) async {
    final db = await instance.database;

    Map<String, String> playlistData = dataInstance.playList.toJson();

    final playList = await db.rawQuery(
        'SELECT * FROM PlayLists WHERE playlistid LIKE "%${playlistData['playlistid']}%" ');

    int? id;
    if (playList.isEmpty) {
      id = await db.insert('PlayLists', playlistData);
    } else {
      id = playList.first['id'] as int;
    }

    final videos = dataInstance.videosToDownload;

    final downloadedVideos =
        await fetchPlaylistVideos(playlistData['playlistid']);

    videos.removeWhere((videoId) {
      return downloadedVideos
          .any((downloadedVideo) => downloadedVideo['videoid'] == videoId);
    });

    for (var videoId in videos) {
      final videoInstance = dataInstance.playListData
          .firstWhere((element) => element.videoid == videoId);

      int? videoid;

      await db
          .rawQuery(
              'SELECT id FROM Video WHERE videoid LIKE "%${videoInstance.videoid}%"')
          .then(
        (video) async {
          if (video.isNotEmpty) {
            videoid = video.first['id'] as int;
            return;
          }
          Map<String, String> videoData = videoInstance.tojson();
          videoid = await db.insert('Video', videoData);
        },
      );

      await db.insert('playlistvideos', {'videoid': videoid, 'playlistid': id});
    }
    dataInstance.initDownloadVideos();
  }

  Future<List<Map<String, Object?>>> fetchVideos() async {
    final db = await instance.database;

    return await db.rawQuery('SELECT * FROM Video');
  }

  Future<List<Map<String, Object?>>> fetchPlaylists() async {
    final db = await instance.database;

    return await db.rawQuery('SELECT * FROM PlayLists');
  }

  Future<List<Map<String, Object?>>> fetchPlaylistVideos(playListID) async {
    final db = await instance.database;
    final id = await db.rawQuery(
        'SELECT id FROM PlayLists WHERE playlistid LIKE "%$playListID%"');

    return await db.rawQuery(
        'SELECT * FROM Video WHERE id in (SELECT videoid FROM playlistvideos WHERE playlistid = ${id.first['id']})');
  }

  Future removeVideoFromPlaylist(playlistID, videoID) async {
    final db = await instance.database;

    await db.delete('playlistvideos',
        where: 'videoid LIKE "%$videoID%" AND playlistid LIKE "%$playlistID%"');
  }

  Future addToPLaylist(playlistID, videoID) async {
    final db = await instance.database;

    await db.insert(
        'playlistvideos', {'videoid': videoID, 'playlistid': playlistID});
  }

  deleteAll() async {
    final db = await instance.database;

    await db.delete('PlayLists');
    await db.delete('Video');
    await db.delete('playlistvideos');
  }

  Future updatePlaylist(map) async {
    final db = await instance.database;

    await db.update('PlayLists', map,
        where: 'playlistid LIKE "%${map['playlistid']}%"');
  }

  Future<bool> hasVideo(playlistID, videoID) async {
    final db = await instance.database;

    final id = await db
        .rawQuery('SELECT id FROM Video WHERE videoid LIKE "%$videoID%"');
    if (id.isEmpty) {
      return false;
    }
    final exists = await db.rawQuery(
        'SELECT * FROM playlistvideos WHERE playlistid LIKE "%$playlistID%" AND videoid LIKE "%${id.first['id']}%"');

    return exists.isNotEmpty;
    // await db.rawQuery()
  }

  Future<int> addVideoToVideos(data) async {
    final db = await instance.database;
    int id;
    final video = await db.rawQuery(
        'SELECT id FROM Video WHERE videoid LIKE "%${data['videoid']}%"');
    if (video.isNotEmpty) {
      id = video.first['id'] as int;
    } else {
      id = await db.insert('Video', data);
    }
    return id;
  }

  Future deleteVideo(id) async {
    final db = await instance.database;

    await db.delete('Video', where: 'id LIKE "%$id%"');
  }
}
