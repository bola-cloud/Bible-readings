import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  Map<String,dynamic>? data = {};

  Set<String> openedDays = {};

  Future<File> _getOpenedDaysFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/openedDays.json'); // writable location
  }

  saveOpenedDays(Set<String> openedDays) async {
    final file = await _getOpenedDaysFile();
    await file.writeAsString(jsonEncode(openedDays.toList()));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    openedDays.add("${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}");
    await saveOpenedDays(openedDays);
    Navigator.pushNamed(context, '/reading', arguments: {
      "items": data,
      "openedDays": openedDays,
      "title": data?["${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}"]?[0] ?? "No title for this day.",
      "reading": data?["${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}"]?[1] ?? "No data for this day.",
      "date": "${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}"
    });
  }

  String? getCustomLabel(DateTime day) {
    String? title = data?["${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}"]?[0];

    return title;
  }


  @override
  Widget build(BuildContext context) {
    
    final args = ModalRoute.of(context)?.settings.arguments as Map;

    Map<String, dynamic>? items;
    if (args["data"] != null && args["data"] is Map<String, dynamic>) {
      items = args["data"];
    } else {
      items = {}; // or default values
    }

    Set<String> openedDaysItems;
    if (args["openedDays"] != null && args["openedDays"] is Set<String>) {
      openedDaysItems = args["openedDays"];
    } else {
      openedDaysItems = {}; // or default values
    }

    setState(() {
      data = items;
      openedDays = openedDaysItems;
    }); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calender'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/calendar_parent');
          },
        ),
        backgroundColor: Colors.grey,
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2026, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: DateTime.utc(2026, 1, 1),
        // selectedDayPredicate: (day) => isSameDay(day, today),
        onDaySelected: _onDaySelected,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            String dayKey = "${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}";
            bool isOpened = openedDays.contains(dayKey);
            return Container(
              decoration: BoxDecoration(
                color: isOpened ? Colors.blue[500] : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}''${getCustomLabel(day)==null ? "" : "\n${getCustomLabel(day)}"}', // your custom name
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          selectedBuilder: (context, day, _) {
            String dayKey = "${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}";
            bool isOpened = openedDays.contains(dayKey);

            return Container(
              decoration: BoxDecoration(
                color: isOpened ? Colors.blue : Colors.green,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      )
    );
  }
}