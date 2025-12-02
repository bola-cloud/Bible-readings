import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  
  static Database? _db;

  static final DatabaseService instance = DatabaseService._constructor();

  final String _notesTableName = "notes";
  final String _notesDateColumnName = "date";
  final String _notesContentColumnName = "content";
  final String _dataTableName = "data";
  final String _dataDateColumnName = "date";
  final String _dataTitleColumnName = "title";
  final String _dataReadingColumnName = "reading";
  final String _dataOpenedColumnName = "opened";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db ?? await getDatabase();
    _db = await getDatabase();
    return _db ?? await getDatabase();
  }

  Future _onCreate(Database db, int version) async {
    db.execute('''
      CREATE TABLE $_notesTableName (
        $_notesDateColumnName TEXT PRIMARY KEY,
        $_notesContentColumnName TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE $_dataTableName (
        $_dataDateColumnName TEXT PRIMARY KEY,
        $_dataTitleColumnName TEXT NOT NULL,
        $_dataReadingColumnName TEXT NOT NULL,
        $_dataOpenedColumnName INTEGER NOT NULL
      )
    ''');

    final String res = await rootBundle.loadString('data/data.json');
    final jsonData = await json.decode(res) as Map<String, dynamic>;// path to your JSON file

    for (var item in jsonData.keys) {
      await db.insert(
        _dataTableName,
        {
          _dataDateColumnName: item,
          _dataTitleColumnName: jsonData[item][0],
          _dataReadingColumnName: jsonData[item][1],
          _dataOpenedColumnName: 0,
        },
      );
    }
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        _onCreate(db, version);
      }
    );
    return database;
  }

  void addNote(String date, String content) async {
    final db = await database;
    await db.insert(_notesTableName, {
      _notesDateColumnName: date,
      _notesContentColumnName: content,
    });
  }

  Future<String?> getNoteContentByDate(String date) async {
    final db = await database;
    final data = await db.query(
      _notesTableName,
      columns: [_notesContentColumnName], // only fetch the content
      where: '$_notesDateColumnName = ?',
      whereArgs: [date],
    );

    if (data.isNotEmpty) {
      return data.first[_notesContentColumnName] as String;
    } else {
      return null; // no note found for that date
    }
  }

  void updateNoteContent(String date, String content) async {
    final db = await database;

    // Update the content for the given date
    await db.update(
      _notesTableName,
      {_notesContentColumnName: content},
      where: '$_notesDateColumnName = ?',
      whereArgs: [date],
    );
  }


  void adddata(String date, String title, String reading) async {
    final db = await database;
    await db.insert(_dataTableName, {
      _dataDateColumnName: date,
      _dataTitleColumnName: title,
      _dataReadingColumnName: reading,
    });
  }

  Future<Map<String, Data>> getData() async {
    final db = await database;

    final dataList = await db.query(
      _dataTableName,
      columns: [
        _dataDateColumnName,
        _dataTitleColumnName,
        _dataReadingColumnName,
        _dataOpenedColumnName
      ],
    );

    final Map<String, Data> dataMap = {};

    for (var row in dataList) {
      final dataItem = Data(
        date: row[_dataDateColumnName] as String,
        title: row[_dataTitleColumnName] as String,
        reading: row[_dataReadingColumnName] as String,
        opened: row[_dataOpenedColumnName] as int,
      );
      dataMap[dataItem.date] = dataItem;
    }

    return dataMap;
  }

  Future<Data?> getdataContentByDate(String date) async {
    final db = await database;
    final dataList = await db.query(
      _dataTableName,
      columns: [_dataDateColumnName,_dataTitleColumnName, _dataReadingColumnName, _dataOpenedColumnName], // only fetch the content
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
      );
    } else {
      return null; // no data for this date
    }
  }

  void updateDataOpened(String date, int opened) async {
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
}