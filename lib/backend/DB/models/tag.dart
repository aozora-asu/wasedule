class Tag {
  String title;
  int? color;
  int isBeit;
  int? wage;

  Tag(
      {required this.title,
      this.color,
      required this.isBeit,
      this.wage,
      });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'color': color,
      'isBeit': isBeit,
      "wage": wage,
    };
  }
}
