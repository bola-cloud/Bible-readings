import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  static final DatabaseService instance = DatabaseService._constructor();

  final String _dataTableName = "data";
  final String _dataDateColumnName = "date";
  final String _dataTitleColumnName = "title";
  final String _dataReadingColumnName = "reading";
  final String _dataOpenedColumnName = "opened";
  final String _dataNoteColumnName = "note";
  final String _attendanceTableName = "attendance";
  final String _attendanceMonthColumnName = "month";
  final String _attendanceDataColumnName = "data";
  final String _attendanceNoteColumnName = "note";
  final String _attendanceMannerColumnName = "manner";
  final String _attendanceFadilaColumnName = "fadila";
  final String _attendanceFadilaStagesColumnName = "fadila_stages";
  final String _attendanceSaintColumnName = "saint";
  final String _attendanceSaintStagesColumnName = "saint_stages";
  final String _attendanceFadilaImagePathColumnName = "fadila_img";
  final String _attendanceSaintImagePathColumnName = "saint_img";
  final DateTime endDate = DateTime(2026,DateTime.now().month,DateTime.now().day);

  DatabaseService._constructor();

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  Future<Database> get database async {
    if (_db != null) return _db ?? await getDatabase();
    _db = await getDatabase();
    return _db ?? await getDatabase();
  }

  Future _onCreate(Database db, int version) async {
    db.execute('''
      CREATE TABLE $_dataTableName (
        $_dataDateColumnName TEXT PRIMARY KEY,
        $_dataTitleColumnName TEXT NOT NULL,
        $_dataReadingColumnName TEXT NOT NULL,
        $_dataOpenedColumnName INTEGER NOT NULL,
        $_dataNoteColumnName TEXT
      )
    ''');

    final String res = await rootBundle.loadString('data/data.json');
    final jsonData =
        await json.decode(res)
            as Map<String, dynamic>; // path to your JSON file

    for (var item in jsonData.keys) {
      await db.insert(_dataTableName, {
        _dataDateColumnName: item,
        _dataTitleColumnName: jsonData[item][0],
        _dataReadingColumnName: jsonData[item][1],
        _dataOpenedColumnName: 0,
        _dataNoteColumnName: "",
      });
    }

    db.execute('''
      CREATE TABLE $_attendanceTableName (
        $_attendanceMonthColumnName INTEGER PRIMARY KEY,
        $_attendanceDataColumnName TEXT NOT NULL,
        $_attendanceNoteColumnName TEXT,
        $_attendanceMannerColumnName TEXT,
        $_attendanceFadilaColumnName TEXT,
        $_attendanceFadilaStagesColumnName TEXT,
        $_attendanceSaintColumnName TEXT,
        $_attendanceSaintStagesColumnName TEXT,
        $_attendanceFadilaImagePathColumnName TEXT,
        $_attendanceSaintImagePathColumnName TEXT
      )
    ''');
  }

  Future<void> feedMonthData() async {
    for(int i=1; i<=endDate.month; i++){
      List<bool>? toggles = await getMonthAttendance(i);
      if(toggles == null){
        final weeks = getWeeksInMonth(DateTime(2026,i));
        int totalCells = (weeks.length + 1) * 5; // 4 rows total
        List<bool> togglesList = List.generate(totalCells - (weeks.length + 1), (_) => false);
        await addAttendance(i, togglesList);
      }
    }
  }

  List<DateTime> getWeeksInMonth(DateTime month, {int weekStart = DateTime.sunday}){
    List<DateTime> weeks = [];

    DateTime firstOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastOfMonth = DateTime(month.year, month.month + 1, 0);

    // Start from the weekStart before or equal to the first day of the month
    DateTime currentWeekStart = firstOfMonth.subtract(Duration(days: (firstOfMonth.weekday - weekStart + 7) % 7));

    while (currentWeekStart.isBefore(lastOfMonth) || currentWeekStart.isAtSameMomentAs(lastOfMonth)) {
      weeks.add(currentWeekStart);
      currentWeekStart = currentWeekStart.add(Duration(days: 7));
    }

    return weeks;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await _onCreate(db, version);
      },
    );
    return database;
  }

  Future<String?> getNoteContentByDate(String date) async {
    final db = await database;
    final data = await db.query(
      _dataTableName,
      columns: [_dataNoteColumnName], // only fetch the content
      where: '$_dataDateColumnName = ?',
      whereArgs: [date],
    );

    if (data.isNotEmpty) {
      return data.first[_dataNoteColumnName] as String;
    } else {
      return null; // no note found for that date
    }
  }

  Future<void> updateNoteContent(String date, String content) async {
    final db = await database;

    // Update the content for the given date
    await db.update(
      _dataTableName,
      {_dataNoteColumnName: content},
      where: '$_dataDateColumnName = ?',
      whereArgs: [date],
    );
  }

  Future<void> adddata(String date, String title, String reading) async {
    final db = await database;
    await db.insert(_dataTableName, {
      _dataDateColumnName: date,
      _dataTitleColumnName: title,
      _dataReadingColumnName: reading,
    });
  }

  Future<Map<String, Data>> getDataContent() async {
    final db = await database;

    final dataList = await db.query(
      _dataTableName,
      columns: [
        _dataDateColumnName,
        _dataTitleColumnName,
        _dataOpenedColumnName,
      ],
    );

    final Map<String, Data> dataMap = {};

    for (var row in dataList) {
      final dataItem = Data(
        date: row[_dataDateColumnName] as String,
        title: row[_dataTitleColumnName] as String,
        reading: "",
        opened: row[_dataOpenedColumnName] as int,
        note: "",
      );
      dataMap[dataItem.date] = dataItem;
    }

    return dataMap;
  }

  Future<Data?> getDataContentByDate(String date) async {
    final db = await database;
    final dataList = await db.query(
      _dataTableName,
      columns: [
        _dataDateColumnName,
        _dataTitleColumnName,
        _dataReadingColumnName,
        _dataOpenedColumnName,
        _dataNoteColumnName,
      ], // only fetch the content
      where: '$_dataDateColumnName = ?',
      whereArgs: [date],
    );

    if (dataList.isNotEmpty) {
      final row = dataList.first;
      return Data(
        date: row[_dataDateColumnName] as String,
        title: row[_dataTitleColumnName] as String,
        reading: row[_dataReadingColumnName] as String,
        opened: row[_dataOpenedColumnName] as int,
        note: row[_dataNoteColumnName] as String,
      );
    } else {
      return null; // no data for this date
    }
  }

  Future<void> updateDataOpened(String date, int opened) async {
    final db = await database;

    // Update the content for the given date
    await db.update(
      _dataTableName,
      {_dataOpenedColumnName: opened},
      where: '$_dataDateColumnName = ?',
      whereArgs: [date],
    );
  }

  Future<String> loadJsonFromAssets() async {
    final jsonString = await rootBundle.loadString('data/data.json');
    return jsonString;
  }

  Future<void> addAttendance(int month, List<bool> data) async {
    final db = await database;

    // Convert List<bool> to string of 0 and 1
    String dataString = data.map((e) => e ? '1' : '0').join();

    await db.rawInsert(
      '''
      INSERT OR REPLACE INTO $_attendanceTableName 
        ($_attendanceMonthColumnName, $_attendanceDataColumnName, $_attendanceNoteColumnName, $_attendanceMannerColumnName, $_attendanceFadilaColumnName, $_attendanceFadilaStagesColumnName, $_attendanceSaintColumnName, $_attendanceSaintStagesColumnName, $_attendanceFadilaImagePathColumnName, $_attendanceSaintImagePathColumnName)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [month, dataString, "", "", "", "", "", "", "", ""],
    );

    // 2. Load fadila JSON
    final String fadilaJsonString = await rootBundle.loadString(
      'data/fadila.json',
    );
    final fadilaJson = jsonDecode(fadilaJsonString);

    // Fetch fadila info for this month
    final fadilaObject = fadilaJson['months'][month.toString()];
    final String fadilaName = fadilaObject['name'];
    final List<dynamic> fadilaStages = fadilaObject['stages'];
    final String fadilaImage = fadilaObject['image'];

    // 3. Load saint JSON
    final String saintJsonString = await rootBundle.loadString(
      'data/saint.json',
    );
    final saintJson = jsonDecode(saintJsonString);

    // Fetch saint info for this month
    final saintObject = saintJson['months'][month.toString()];
    final String saintName = saintObject['name'];
    final List<dynamic> saintStages = saintObject['stages'];
    final String saintImage = saintObject['image'];

    // 4. Update the record with all new info
    await db.update(
      _attendanceTableName,
      {
        _attendanceFadilaColumnName: fadilaName,
        _attendanceFadilaStagesColumnName: jsonEncode(fadilaStages),
        _attendanceSaintColumnName: saintName,
        _attendanceSaintStagesColumnName: jsonEncode(saintStages),
        _attendanceFadilaImagePathColumnName: fadilaImage,
        _attendanceSaintImagePathColumnName: saintImage,
      },
      where: '$_attendanceMonthColumnName = ?',
      whereArgs: [month],
    );
  }

  Future<String?> getMonthFadilaName(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceFadilaColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return null;

    return result.first[_attendanceFadilaColumnName] as String?;
  }

  Future<String?> getMonthFadilaImage(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceFadilaImagePathColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return null;

    return result.first[_attendanceFadilaImagePathColumnName] as String?;
  }

  Future<List<dynamic>> getMonthFadilaStages(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceFadilaStagesColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return [];

    final raw = result.first[_attendanceFadilaStagesColumnName] as String?;

    if (raw == null || raw.isEmpty) return [];

    return jsonDecode(raw) as List<dynamic>;
  }

  Future<String?> getMonthSaintName(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceSaintColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return null;

    return result.first[_attendanceSaintColumnName] as String?;
  }

  Future<String?> getMonthSaintImage(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceSaintImagePathColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return null;

    return result.first[_attendanceSaintImagePathColumnName] as String?;
  }

  Future<List<dynamic>> getMonthSaintStages(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceSaintStagesColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) return [];

    final raw = result.first[_attendanceSaintStagesColumnName] as String?;

    if (raw == null || raw.isEmpty) return [];

    return jsonDecode(raw) as List<dynamic>;
  }

  Future<List<bool>?> getMonthAttendance(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceDataColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) {
      // No record → return empty or full false list
      return null;
    }

    final String dataString = result.first[_attendanceDataColumnName] as String;

    // Convert each character ('0'/'1') into a bool
    List<bool> attendance = dataString
        .split('')
        .map((char) => char == '1')
        .toList();

    return attendance;
  }

  Future<String?> getMonthNote(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceNoteColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) {
      // No record → return empty or full false list
      return null;
    }

    return result.first[_attendanceNoteColumnName] as String;
  }

  Future<String?> getMonthManner(int month) async {
    final db = await database;

    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceMannerColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    if (result.isEmpty) {
      // No record → return null
      return null;
    }

    return result.first[_attendanceMannerColumnName] as String;
  }

  Future<void> updateMonthNote(int month, String note) async {
    final db = await database;

    await db.update(
      _attendanceTableName,
      {_attendanceNoteColumnName: note},
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );
  }

  Future<void> updateMonthManner(int month, String manner) async {
    final db = await database;

    await db.update(
      _attendanceTableName,
      {_attendanceMannerColumnName: manner},
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );
  }

  Future<void> updateMonthIndex(int month, int index, bool present) async {
    final db = await database;

    // 1. Get current attendance string for the month
    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceDataColumnName],
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );

    String dataString = result.first[_attendanceDataColumnName] as String;

    // 2. Convert to list of chars to update
    List<String> dataList = dataString.split('');

    // Ensure the index is valid (0-based)
    if (index < 0 || index >= dataList.length) {
      throw Exception("Index out of range for month");
    }

    dataList[index] = present ? '1' : '0';

    // 3. Convert back to string
    String updatedData = dataList.join();

    // 4. Update the DB
    await db.update(
      _attendanceTableName,
      {_attendanceDataColumnName: updatedData},
      where: "$_attendanceMonthColumnName = ?",
      whereArgs: [month],
    );
  }

  Future<int> getOpenedDaysUntil(DateTime upToDate) async {
    final db = await database; // your DB instance

    // Convert DateTime to 'MM-DD-YYYY'
    String dateStr =
        "${upToDate.month.toString().padLeft(2, '0')}-"
        "${upToDate.day.toString().padLeft(2, '0')}-"
        "${upToDate.year.toString().padLeft(4, '0')}";

    // Use SQLite substrings to reorder stored 'MM-DD-YYYY' as 'YYYY-MM-DD' for comparison
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as openedCount 
      FROM $_dataTableName 
      WHERE $_dataOpenedColumnName = 1
      AND $_dataDateColumnName <= ?
      ''',
      [dateStr],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<int, List<bool>>> getTogglesMapUpToMonth(int month) async {
    final db = await database;

    // Query all rows where month <= given month
    final result = await db.query(
      _attendanceTableName,
      columns: [_attendanceDataColumnName, _attendanceMonthColumnName],
      where: '$_attendanceMonthColumnName <= ?',
      whereArgs: [month],
      orderBy: '$_attendanceMonthColumnName ASC',
    );

    Map<int, List<bool>> togglesMap = {};

    for (var row in result) {
      int rowMonth = row[_attendanceMonthColumnName] as int;
      String togglesStr = row[_attendanceDataColumnName] as String? ?? '';

      List<bool> togglesList = togglesStr
          .split('')
          .map((ch) => ch == '1')
          .toList();

      togglesMap[rowMonth] = togglesList;
    }

    return togglesMap;
  }
}
