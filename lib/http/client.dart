import 'dart:convert';

import 'package:http/http.dart' as http;

class DownloadnClient {
  static const String _baseURL = 'clotted-boxcars.000webhostapp.com';
  static const String _listAPI = 'api/videoDetails';

  static Future getListDownloadLisnk(id) async {
    var url = Uri.https(
      _baseURL,
      '$_listAPI/$id',
    );
    try {
      var response = await http.get(url);

      var decodedData = jsonDecode(response.body);

      return decodedData['data']['mp4']['download'];
    } catch (error) {
      rethrow;
    }
  }
}
