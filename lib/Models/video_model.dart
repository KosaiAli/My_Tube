enum Downloadstatus { downloading, inQueue, stopped, error }

class VideoModel {
  final int? id;
  final String title;
  final String thumb;

  String? videoUrl;
  final String? videoid;
  final String? channelTitle;
  final String? playlistId;
  bool existedOnStorage;
  Downloadstatus videoStatus = Downloadstatus.stopped;
  double? downloaded;
  VideoModel(
      {this.id,
      required this.title,
      required this.thumb,
      this.videoUrl,
      this.videoid,
      this.channelTitle,
      this.playlistId,
      required this.existedOnStorage});

  factory VideoModel.createPostResult(Map object, exists) {
    return VideoModel(
        id: object['id'],
        title: object['title'] ?? object['name'],
        thumb: object['thumbnail'] ?? object['image'],
        // video: object['mp4']['download'] ?? '',
        videoid: object['videoid'],
        channelTitle: object['channelTitle'],
        existedOnStorage: exists,
        playlistId: object['PlaylistId']);
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
      'videoid': videoid.toString(),
      'name': title.toString(),
      'image': thumb.toString(),
      'channelTitle': channelTitle.toString()
    };
  }
}
