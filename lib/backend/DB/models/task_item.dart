class TaskItem {
  String uid;
  String title;
  int dtEnd;
  String? summary;
  String? description;

  int isDone;

  TaskItem({
    required this.uid,
    required this.title,
    required this.dtEnd,
    this.summary,
    this.description,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'dtEnd': dtEnd,
      'summary': summary,
      'description': description,
      "isDone": isDone,
    };
  }
}
