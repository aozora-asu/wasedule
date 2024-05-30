class User {
  User(this.name, this.age);

  String name;
  int age;
}

class EmptyRoom {
  String building;
  int weekday;
  int period;
  String classRoom;
  EmptyRoom(
      {required this.building,
      required this.weekday,
      required this.classRoom,
      required this.period});
}
