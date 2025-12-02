class Data{
  final String date, title, reading, note;
  final int opened;

  Data({
    required this.date,
    required this.title,
    required this.reading,
    this.opened = 0,
    this.note = ""
  });
}