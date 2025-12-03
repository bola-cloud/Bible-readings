import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  Map<String,Data>? data = {};
  Map<String, String>? notes;
  DateTime endDay = DateTime.utc(2026,5,6);
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedData = await _databaseService.getDataContent();
    setState(() {
      data = fetchedData;
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if(selectedDay.isAfter(endDay)){
      return;
    }
    String day = "${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}-${selectedDay.year}";
    _databaseService.updateDataOpened(day, 1);

    Navigator.pushNamed(context, '/reading', arguments: {
      "date": day,
    });

    await _loadData();
  }

  String? getCustomLabel(DateTime day) {
    String? title = data?["${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}"]?.title;

    return title;
  }

  @override
  Widget build(BuildContext context) {

    return _isLoading ? Loading() : 

    Scaffold(
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
        rowHeight: 100,
        firstDay: DateTime.utc(2026, 1, 1),
        lastDay: endDay,
        focusedDay: DateTime.utc(2026, 1, 1),
        onDaySelected: _onDaySelected,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            String dayKey =
                "${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}-${day.year}";
            bool isOpened = data?[dayKey]?.opened == 1;

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
                    Text(
                      '${day.day}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        ),
      )
    );
  }
}