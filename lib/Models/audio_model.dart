enum Downloadstatus { downloading, inQueue, stopped, error }

class Audio {
  int? id;

  final String title;
  final String thumb;
  final String? audioid;
  final String? channelTitle;
  final String? playlistId;
  String? audioUrl;
  bool existedOnStorage;
  Downloadstatus audioStatus = Downloadstatus.stopped;
  double? downloaded;
  late double size;

  Audio({
    required this.title,
    required this.thumb,
    required this.existedOnStorage,
    this.id,
    this.playlistId,
    this.channelTitle,
    this.audioUrl,
    this.audioid,
  });

  factory Audio.createPostResult(Map object, exists) {
    return Audio(
        id: object['id'],
        title: object['title'] ?? object['name'],
        thumb: object['thumbnail'] ?? object['image'],
        audioid: object['audioid'],
        channelTitle: object['channelTitle'],
        existedOnStorage: exists,
        playlistId: object['PlaylistId']);
  }

  Map<String, String> tojson() {
    return {
      'audioid': audioid.toString(),
      'name': title.toString(),
      'image': thumb.toString(),
      'channelTitle': channelTitle.toString()
    };
  }
}
