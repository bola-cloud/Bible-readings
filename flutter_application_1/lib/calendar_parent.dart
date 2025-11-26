import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/styled_button.dart';
import 'package:path_provider/path_provider.dart';

class CalanderParent extends StatefulWidget {
  const CalanderParent({super.key});

  @override
  State<CalanderParent> createState() => _CalanderParentState();
}

class _CalanderParentState extends State<CalanderParent> {
  Map<String,dynamic> data = {};
  Set<String> openedDays = {};

  Future<File> _getOpenedDaysFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/openedDays.json'); // writable location
    
  }

  getFileData() async {
    final String res = await rootBundle.loadString('data/data.json');
    final data = await json.decode(res) as Map<String, dynamic>;
    final file = await _getOpenedDaysFile();

    if (!await file.exists()) {
      return {}; // empty set if file not yet created
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) return {};

    final List<dynamic> res2 = jsonDecode(content);
    final openedDays = res2.cast<String>().toSet();
    setState(() {
      this.data = data;
      this.openedDays = openedDays;
    });

  }

  @override
  Widget build(BuildContext context) {

    return StyledButton(
      onPressed: () async {
        await getFileData();
        Navigator.pushNamed(context, '/calendar', arguments: {
          "data": data,
          "openedDays": openedDays
          // "openedDays": openedDays.remove(date),
        });
      },
      child: Text("go to calendar"),
    );
  }
}