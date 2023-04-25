import 'dart:convert';

import 'package:http/http.dart' as http;

class DownloadnClient {
  static const String _baseURL = 'clotted-boxcars.000webhostapp.com';
  // static const String _baseURL = '127.0.0.1:8000';
  static const String _listAPI = 'api/videoDetails';

  static Future getListDownloadLisnks(List list) async {
    List<Map> links = [];
    for (var videoId in list) {
      var url = Uri.https(
        _baseURL,
        '$_listAPI/$videoId',
      );
      try {
        print(url);
        var response = await http.get(url);

        var decodedData = jsonDecode(response.body);
        print(decodedData);
        links.add(
            {'Id': decodedData['id'], 'link': decodedData['mp4']['download']});
      } catch (error) {
        rethrow;
      }
      return links;
    }
  }
}
