class CalendarItem {
  String subject;
  String title;
  int dtEnd;
  String? summary;
  String? description;

  CalendarItem({
    required this.subject,
    required this.title,
    required this.dtEnd,
    this.summary,
    this.description,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'title': title,
      'dtEnd': dtEnd,
      'summary': summary,
      'description': description,
      
    };
  }
}
