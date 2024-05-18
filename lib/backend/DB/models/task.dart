class TaskItem {
  String? uid;
  String title;
  int dtEnd;
  String? summary;
  String? description;
  String? pageID;
  int isDone;

  TaskItem(
      {this.uid,
      required this.title,
      required this.dtEnd,
      this.summary,
      this.description,
      required this.isDone,
      required this.pageID});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'dtEnd': dtEnd,
      'summary': summary,
      'description': description,
      "isDone": isDone,
      "pageID": pageID
    };
  }
}
