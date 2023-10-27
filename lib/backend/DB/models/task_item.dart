class TaskItem {
  String summary;
  String? description;
  int dtEnd;
  String categories;
  int isDone;

  TaskItem({
    required this.summary,
    required this.description,
    required this.dtEnd,
    required this.categories,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'summary': summary,
      'description': description,
      'dtEnd': dtEnd,
      'categories': categories,
      "isDone": isDone
    };
  }
}
