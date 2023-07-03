import '../Models/database.dart';

class DemoPlaylist {
  Future<List<Map<String, Object?>>> fetchInitialPlaylist(
      {required String playListID}) async {
    return await DB.instance.fetchPlaylistAudios(playListID);
  }
}
