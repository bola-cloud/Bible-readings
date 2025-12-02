class Attendance{
  final int month;
  final String data, note, manar;

  Attendance({
    required this.month,
    required this.data,
    this.note = '',
    this.manar = '',
  });
}