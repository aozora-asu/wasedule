enum Terms {
  spring_quarter,
  summer_quarter,
  spring_semester,
  fall_quarter,
  winter_quarter,
  fall_semester,
  full_year,
}

enum AttendStatus {
  attend('attend'),
  late('late'),
  absent('absent'),
  ;

  const AttendStatus(this.value);
  final String value;
}
