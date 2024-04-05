class UserInfo {
  String? url;
  String? dtEnd;
  String? backupID;

  UserInfo({this.url, this.dtEnd, this.backupID});

  Map<String, dynamic> toMap() {
    return {"url": url, "backupID": backupID, "dtEnd": dtEnd};
  }
}
