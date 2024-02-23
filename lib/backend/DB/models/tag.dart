class Tag {
  String title;
  int? color;
  int isBeit;
  int? wage;
  int? fee;

  Tag(
      {required this.title,
      this.color,
      required this.isBeit,
      this.wage,
      this.fee
      });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'color': color,
      'isBeit': isBeit,
      "wage": wage,
      "fee" : fee
    };
  }
}
