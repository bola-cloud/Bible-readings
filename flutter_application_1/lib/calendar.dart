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
  Map<String, String>? notes;
  Set<String> openedDays = {};
  DateTime endDay = DateTime.utc(2026,5,6);

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if(selectedDay.isAfter(endDay)){
      return null;
    }
    openedDays.add("${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}");
    await getNotesData();
    Navigator.pushNamed(context, '/reading', arguments: {
      "items": data,
      "openedDays": openedDays,
      "title": data?["${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}"]?[0] ?? "No title for this day.",
      "reading": data?["${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}"]?[1] ?? "No data for this day.",
      "date": "${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}",
      "notes": notes,
    });
  }

  String? getCustomLabel(DateTime day) {
    String? title = data?["${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}"]?[0];

    return title;
  }

  Future<File> _getNotesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json'); // writable location
  }

  getNotesData() async {
    final file = await _getNotesFile();

    if (!await file.exists()) {
      return {}; // empty set if file not yet created
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) return {};

    final Map<String, dynamic> res2 = jsonDecode(content);
    final notes = res2.map((key, value) => MapEntry(key, value.toString()));
    setState(() {
      this.notes = notes;
    });
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
        title: const Text('خطوة بخطوة'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pushNamed(context, '/calendar_parent');
          },
        ),
        backgroundColor: Colors.grey,
      ),
      body: TableCalendar(
        rowHeight: 85,
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
            String dayKey =
                "${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}";
            bool isOpened = openedDays.contains(dayKey);

            return Container(
              decoration: BoxDecoration(
                color: day.isBefore(endDay.add(const Duration(days: 1))) ? (isOpened ? Colors.green : Colors.red): Colors.grey,
                // color: isOpened ? const Color.fromARGB(255, 61, 196, 37) : const Color.fromARGB(255, 213, 211, 161),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (getCustomLabel(day) != null && day.isBefore(endDay.add(const Duration(days: 1))))
                      Text(
                        '${day.day}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    if (day.isAfter(endDay))
                      Text(
                        '${day.day}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
                      ),
                    if (getCustomLabel(day) != null && day.isBefore(endDay.add(const Duration(days: 1))))
                      Text(
                        getCustomLabel(day)!,
                        softWrap: true,           // ⬅️ allows wrapping
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
            );
          },

          selectedBuilder: (context, day, _) {
            String dayKey =
                "${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}";
            bool isOpened = openedDays.contains(dayKey);

            return Container(
              decoration: BoxDecoration(
                color: day.isBefore(endDay.add(const Duration(days: 1))) ? (isOpened ? Colors.blue : Colors.green): Colors.grey,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      )
    );
  }
}