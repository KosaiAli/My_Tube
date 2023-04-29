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
    // await db.delete('PlayLists');
    // await db.delete('Video');
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

    for (var id in videos) {
      final video =
          dataInstance.playListData.firstWhere((element) => element.id == id);

      Map<String, String> videoData = video.tojson();

      await db.insert('Video', videoData);
      dataInstance.addVideo(video);
    }
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

    return await db
        .rawQuery('SELECT * FROM Video WHERE PlaylistId LIKE "%$playListID%" ');
  }
}
