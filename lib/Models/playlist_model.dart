class PlayList {
  final String id;
  final String name;
  final String image;

  PlayList(this.id, this.name, this.image);

  Map<String, String> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
    };
  }
}
