enum Downloadstatus { downloading, inQueue, stopped, error }

class VideoModel {
  final String title;
  final String thumb;

  String? videoUrl;
  final String? id;
  final String? channelTitle;
  final String? playlistId;
  bool existedOnStorage;
  Downloadstatus videoStatus = Downloadstatus.stopped;
  double? downloaded;
  VideoModel(
      {required this.title,
      required this.thumb,
      this.videoUrl,
      this.id,
      this.channelTitle,
      this.playlistId,
      required this.existedOnStorage});

  factory VideoModel.createPostResult(Map object, exists) {
    return VideoModel(
      title: object['title'] ?? object['Name'],
      thumb: object['thumbnail'] ?? object['Image'],
      // video: object['mp4']['download'] ?? '',
      id: object['Id'],
      channelTitle: object['channelTitle'],
      existedOnStorage: exists,
    );
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
      'Id': id.toString(),
      'Name': title.toString(),
      'Image': thumb.toString(),
      'PlaylistId': playlistId.toString(),
      'channelTitle': channelTitle.toString()
    };
  }
}
