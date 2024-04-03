class Tag {
  String title;
  int? color;
  int isBeit;
  int? wage;
  int? fee;
  String? tagID;

  Tag(
      {required this.title,
      this.color,
      required this.isBeit,
      this.wage,
      this.fee,
      this.tagID});
  @override
  int get hashCode {
    return DateTime.now().microsecondsSinceEpoch.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'color': color,
      'isBeit': isBeit,
      "wage": wage,
      "fee": fee,
      "tagID": tagID ?? hashCode.toString()
    };
  }
}
