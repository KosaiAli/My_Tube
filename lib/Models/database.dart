import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './data_center.dart';

class DB {
  static final DB instance = DB._init();

  static Database? _database;

  DB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('audios.db');
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
CREATE TABLE Audio (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  audioid TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  image TEXT NOT NULL,
  channelTitle TEXT NOT NULL
)
''');
    await db.execute('''
  CREATE TABLE playlistaudios (
  audioid INTEGER NOT NULL,
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

    final audios = dataInstance.audioToDownload;

    final downloadedAudios =
        await fetchPlaylistAudios(playlistData['playlistid']);

    audios.removeWhere((audioId) {
      return downloadedAudios
          .any((downloadedAudio) => downloadedAudio['audioid'] == audioId);
    });

    for (var audioId in audios) {
      final audioInstance = dataInstance.playListData
          .firstWhere((element) => element.audioid == audioId);

      int? audioid;

      await db
          .rawQuery(
              'SELECT id FROM Audio WHERE audioid LIKE "%${audioInstance.audioid}%"')
          .then(
        (audio) async {
          if (audio.isNotEmpty) {
            audioid = audio.first['id'] as int;
            return;
          }
          Map<String, String> audioData = audioInstance.tojson();
          audioid = await db.insert('Audio', audioData);
        },
      );

      await db.insert('playlistaudios', {'audioid': audioid, 'playlistid': id});
    }
    dataInstance.initDownloadAudios();
  }

  Future<List<Map<String, Object?>>> fetchAudios() async {
    final db = await instance.database;

    return await db.rawQuery('SELECT * FROM Audio');
  }

  Future<List<Map<String, Object?>>> fetchPlaylists() async {
    final db = await instance.database;

    return await db.rawQuery('SELECT * FROM PlayLists');
  }

  Future<List<Map<String, Object?>>> fetchPlaylistAudios(playListID) async {
    final db = await instance.database;
    final id = await db.rawQuery(
        'SELECT id FROM PlayLists WHERE playlistid LIKE "%$playListID%"');

    return await db.rawQuery(
        'SELECT * FROM Audio WHERE id in (SELECT audioid FROM playlistaudios WHERE playlistid = ${id.first['id']})');
  }

  Future removeAudioFromPlaylist(playlistID, audioID) async {
    final db = await instance.database;

    await db.delete('playlistaudios',
        where: 'audioid LIKE "%$audioID%" AND playlistid LIKE "%$playlistID%"');
  }

  Future addToPLaylist(playlistID, audioID) async {
    final db = await instance.database;

    await db.insert(
        'playlistaudios', {'audioid': audioID, 'playlistid': playlistID});
  }

  deleteAll() async {
    final db = await instance.database;

    await db.delete('PlayLists');
    await db.delete('Audio');
    await db.delete('playlistaudios');
  }

  Future updatePlaylist(map) async {
    final db = await instance.database;

    await db.update('PlayLists', map,
        where: 'playlistid LIKE "%${map['playlistid']}%"');
  }

  Future<bool> hasaudio(playlistID, audioID) async {
    final db = await instance.database;

    final id = await db
        .rawQuery('SELECT id FROM Audio WHERE audioid LIKE "%$audioID%"');
    if (id.isEmpty) {
      return false;
    }
    final exists = await db.rawQuery(
        'SELECT * FROM playlistaudios WHERE playlistid LIKE "%$playlistID%" AND audioid LIKE "%${id.first['id']}%"');

    return exists.isNotEmpty;
    // await db.rawQuery()
  }

  Future<int> addAudioToAudio(data) async {
    final db = await instance.database;
    int id;
    final audio = await db.rawQuery(
        'SELECT id FROM Audio WHERE audioid LIKE "%${data['audioid']}%"');
    if (audio.isNotEmpty) {
      id = audio.first['id'] as int;
    } else {
      id = await db.insert('Audio', data);
    }
    return id;
  }

  Future deleteAudio(id) async {
    final db = await instance.database;

    await db.delete('Audio', where: 'id LIKE "%$id%"');
  }
}
