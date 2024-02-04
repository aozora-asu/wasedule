class UserInfo {
  String url;
  UserInfo({required this.url});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
    };
  }
}
