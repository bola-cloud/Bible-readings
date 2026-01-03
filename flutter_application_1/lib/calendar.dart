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
  Map<String, Data>? data = {};
  Map<String, String>? notes;
  DateTime endDay = DateTime(2026, DateTime.now().month, DateTime.now().day);
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = true;
  int month = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedData = await _database_service_getDataContentSafe();
    if (!mounted) return;
    setState(() {
      data = fetchedData;
      _isLoading = false;
    });
  }

  // safe wrapper in case of DB issues
  Future<Map<String, Data>?> _database_service_getDataContentSafe() async {
    try {
      return await _databaseService.getDataContent();
    } catch (_) {
      return {};
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (selectedDay.isAfter(endDay.add(const Duration(days: 1)))) {
      return;
    }
    String day =
        "${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}-${selectedDay.year}";

    // Capture navigator before any awaits to avoid using BuildContext across async gaps
    final navigator = Navigator.of(context);

    // mark opened immediately
    // await _databaseService.updateDataOpened(day, 1);

    if (!mounted) return;

    // Navigate and wait for the reading page to pop, then reload data so the calendar reflects any changes
    await navigator.pushNamed('/reading', arguments: {"date": day});

    // Reload data after returning
    await _loadData();
  }

  String? getCustomLabel(DateTime day) {
    String? title =
        data?["${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}-${day.year}"]
            ?.title;

    return title;
  }

  String intToArabic(dynamic n) {
    const english = "0123456789";
    const arabic = "٠١٢٣٤٥٦٧٨٩";

    String s = n.toString();

    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }

    return s;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                'تأملاتى',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            body: Stack(
              children: [
                // Background image (match monthly_data styling)
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/img/background.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.90),
                        BlendMode.dstATop,
                      ),
                    ),
                  ),
                ),

                // Pale overlay for readability (matches monthly_data)
                Container(color: Colors.white.withOpacity(0.30)),

                // Main content using same padding/scroll pattern as monthly_data
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 80),

                        // Calendar inside a card to match monthly_data style
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Color(0xFFF8EDE0),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: TableCalendar(
                              rowHeight: 100,
                              firstDay: DateTime(2026, 1, 1),
                              lastDay: endDay,
                              focusedDay: DateTime(2026, month, 1),
                              onDaySelected: _onDaySelected,
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  month = focusedDay.month;
                                });
                              },
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.arrow_back,
                                  size: 24,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.arrow_forward,
                                  size: 24,
                                ),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                weekendStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                headerTitleBuilder: (context, day) {
                                  final arabicMonths = [
                                    'يناير', // January
                                    'فبراير', // February
                                    'مارس', // March
                                    'أبريل', // April
                                    'مايو', // May
                                    'يونيو', // June
                                    'يوليو', // July
                                    'أغسطس', // August
                                    'سبتمبر', // September
                                    'أكتوبر', // October
                                    'نوفمبر', // November
                                    'ديسمبر', // December
                                  ];

                                  return Text(
                                    '${arabicMonths[day.month - 1]} ${intToArabic(day.year)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                                defaultBuilder: (context, day, focusedDay) {
                                  String dayKey =
                                      "${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}-${day.year}";
                                  bool isOpened = data?[dayKey]?.opened == 1;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color:
                                          day.isBefore(
                                            endDay.add(const Duration(days: 1)),
                                          )
                                          ? (isOpened
                                                ? Colors.green
                                                : Colors.red)
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    margin: const EdgeInsets.all(5),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${day.day}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (getCustomLabel(day) != null &&
                                              day.isBefore(
                                                endDay.add(
                                                  const Duration(days: 1),
                                                ),
                                              ))
                                            Text(
                                              getCustomLabel(day)!,
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
