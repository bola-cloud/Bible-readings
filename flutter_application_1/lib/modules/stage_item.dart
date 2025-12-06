class StageItem {
  final String title;
  final String body;

  StageItem({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
    };
  }

  factory StageItem.fromMap(Map<String, dynamic> map) {
    return StageItem(
      title: map['title'],
      body: map['body'],
    );
  }
}
