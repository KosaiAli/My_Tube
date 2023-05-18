class PlayList {
  final String id;
  final String name;
  final String image;

  PlayList(this.id, this.name, this.image);

  Map<String, String> toJson() {
    return {
      'playlistid': id,
      'name': name,
      'image': image,
    };
  }

  factory PlayList.creatPlaylist(Map object) {
    print(object);
    return PlayList(object['playlistid'], object['name'], object['image']);
  }
}
