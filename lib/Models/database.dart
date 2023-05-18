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
  image TEXT NOT NULL
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
        'SELECT * FROM PlayLists WHERE Id LIKE "%${playlistData['Id']}%" ');

    int? id;
    if (playList.isEmpty) {
      id = await db.insert('PlayLists', playlistData);
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
          .firstWhere((element) => element.id == videoId);

      var value;

      await db
          .rawQuery(
              'SELECT id FROM Video WHERE videoid LIKE "%${videoInstance.id}%"')
          .then(
        (video) async {
          if (video.isNotEmpty) {
            value = video.first['id'];
            return;
          }
          Map<String, String> videoData = videoInstance.tojson();
          value = await db.insert('Video', videoData);
        },
      );

      print(value);
      await db.insert('playlistvideos', {'videoid': value, 'playlistid': id});
      dataInstance.addVideo(videoInstance);
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
    final id = await db.rawQuery(
        'SELECT id FROM PlayLists WHERE playlistid LIKE "%$playListID%"');
    print(id.first['id']);
    return await db.rawQuery(
        'SELECT * FROM Video WHERE id in (SELECT videoid FROM playlistvideos WHERE playlistid = ${id.first['id']})');
  }
}
