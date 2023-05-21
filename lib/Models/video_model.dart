enum Downloadstatus { downloading, inQueue, stopped, error }

class VideoModel {
  final int? id;

  final String title;
  final String thumb;
  final String? videoid;
  final String? channelTitle;
  final String? playlistId;

  String? videoUrl;
  bool existedOnStorage;
  Downloadstatus videoStatus = Downloadstatus.stopped;
  double? downloaded;

  VideoModel({
    required this.title,
    required this.thumb,
    required this.existedOnStorage,
    this.id,
    this.playlistId,
    this.channelTitle,
    this.videoUrl,
    this.videoid,
  });

  factory VideoModel.createPostResult(Map object, exists) {
    return VideoModel(
        id: object['id'],
        title: object['title'] ?? object['name'],
        thumb: object['thumbnail'] ?? object['image'],
        videoid: object['videoid'],
        channelTitle: object['channelTitle'],
        existedOnStorage: exists,
        playlistId: object['PlaylistId']);
  }

  Map<String, String> tojson() {
    return {
      'videoid': videoid.toString(),
      'name': title.toString(),
      'image': thumb.toString(),
      'channelTitle': channelTitle.toString()
    };
  }
}
