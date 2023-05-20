class PlayList {
  final int? id;
  final String playlistid;
  final String name;
  final String image;

  PlayList(
      {this.id,
      required this.playlistid,
      required this.name,
      required this.image});

  Map<String, String> toJson() {
    return {
      'playlistid': playlistid,
      'name': name,
      'image': image,
    };
  }

  factory PlayList.creatPlaylist(Map object) {
    print(object);
    return PlayList(
        playlistid: object['playlistid'],
        name: object['name'],
        image: object['image'],
        id: object['id']);
  }
}
