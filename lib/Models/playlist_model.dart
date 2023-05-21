class PlayList {
  final int? id;
  final String playlistid;
  final String name;
  final String image;
  final String networkImage;

  PlayList({
    this.id,
    required this.playlistid,
    required this.name,
    required this.image,
    required this.networkImage,
  });

  Map<String, String> toJson() {
    return {
      'playlistid': playlistid,
      'name': name,
      'image': image,
      'networkImage': networkImage
    };
  }

  factory PlayList.creatPlaylist(Map object) {
    return PlayList(
        playlistid: object['playlistid'],
        name: object['name'],
        image: object['image'],
        id: object['id'],
        networkImage: object['networkImage']);
  }
}
