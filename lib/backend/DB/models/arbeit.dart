class Arbeit {
  int tagId;
  String month;
  int wage;

  Arbeit (
      {required this.tagId,
      required this.month,
      required this.wage,
      });

  Map<String, dynamic> toMap() {
    return {
      'tagId': tagId,
      'month': month,
      "wage": wage,
    };
  }
}
