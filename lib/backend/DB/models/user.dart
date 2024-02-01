class User {
  String url;
  User({required this.url});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
    };
  }
}
