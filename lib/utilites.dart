String getVideoId(text) {
  if (text.contains('youtu.be')) {
    return text.substring(text.indexOf('youtu.be') + 9);
  }
  return text.substring(
      text.indexOf('watch?v') + 8, text.indexOf('watch?v') + 19);
}
