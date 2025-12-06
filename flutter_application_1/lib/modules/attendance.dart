import 'package:flutter_application_1/modules/stage_Item.dart';

class Attendance{
  final int month;
  final String data, note, manar, fadila, saint, fadilaImagePath, saintImagePath;
  final List<StageItem> fadilaStages, saintStages;

  Attendance({
    required this.month,
    required this.data,
    this.note = '',
    this.manar = '',
    this.fadila = '',
    this.saint = '',
    this.fadilaImagePath = '',
    this.saintImagePath = '',
    this.fadilaStages = const [],
    this.saintStages = const [],
  });

  // Convert Map → object (Retrieve from SQLite)
  factory Attendance.fromMap(Map<String, dynamic> map) {
    final fadilaStageList = map['fadila_stages'];
    final saintStageList = map['saint_stages'];

    return Attendance(
      month: map['month'],
      data: map['data'],
      note: map['note'],
      manar: map['manar'],
      fadila: map['fadila'],
      saint: map['saint'],
      fadilaImagePath: map['fadila_img'],
      saintImagePath: map['saint_img'],
      fadilaStages: (fadilaStageList as List<dynamic>)
          .map((e) => StageItem.fromMap(e))
          .toList(),
      saintStages: (saintStageList as List<dynamic>)
          .map((e) => StageItem.fromMap(e))
          .toList(),
    );
  }
}