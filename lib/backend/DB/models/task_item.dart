class TaskItem {
  String? summary;
  String? description;
  int? dtEnd;
  String categories;
  int isDone = 0;
  String? memo;

  TaskItem(
      {required this.summary,
      required this.description,
      required this.dtEnd,
      required this.categories,
      required this.isDone,
      this.memo});

  Map<String, dynamic> toMap() {
    return {
      'summary': summary,
      'description': description,
      'dtEnd': dtEnd,
      'categories': categories,
      "isDone": isDone,
      "memo": memo
    };
  }
}
