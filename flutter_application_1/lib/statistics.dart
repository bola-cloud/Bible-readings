import 'package:flutter/material.dart';
import 'package:flutter_application_1/battery_widget.dart'; // import the battery widget
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final DatabaseService _databaseService = DatabaseService.instance;

  bool _isLoading = true;
  double _percentage = 0.0;

  List _rowPercentages = [0.0, 0.0, 0.0]; // القداس, الاجتماع, المذبح العائلى

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  Future<void> deleteDatabaseIfExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'master_db.db');
    await deleteDatabase(path);
  }

  Future _calculateStatistics() async {
    final now = DateTime(2026, 5, 6);

    // 1️⃣ Opened days
    int openedDays = await _databaseService.getOpenedDaysUntil(now);

    // 2️⃣ Total days from 1-1-2026 until today
    final startDate = DateTime(2026, 1, 1);
    int totalDays = now.difference(startDate).inDays + 1;

    double percent = totalDays > 0 ? openedDays / totalDays : 0.0;

    // 3️⃣ Read all toggles up to current month
    Map<int, List<bool>> togglesMap = await _databaseService.getTogglesMapUpToMonth(now.month);

    // 4️⃣ Calculate row percentages
    List<double> rowPercentages = List.generate(3, (index) => calculateRowPercentageAllMonths(togglesMap, index, now.month));

    setState(() {
      _percentage = percent;
      _rowPercentages = rowPercentages;
      _isLoading = false;
    });

  }

  // Get the first day of each week in the month
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

  double calculateRowPercentageAllMonths(Map<int, List<bool>> togglesMap, int rowIndex, int currentMonth) {
    
    int rowCount = 0;
    int rowTotal = 0;

    // Loop over all months up to the currentMonth
    for (int month = 1; month <= currentMonth; month++) {
      List<bool>? monthToggles = togglesMap[month];
      if (monthToggles == null || monthToggles.isEmpty) continue;

      // Calculate columns for the month
      final weeks = getWeeksInMonth(DateTime(2026, month, 1)); // adjust year if needed
      int columns = weeks.length + 1;

      // Determine start and end index for the row in this month
      int startIndex = rowIndex * columns;
      int endIndex = startIndex + columns - 1;

      for (int i = startIndex; i < endIndex && i < monthToggles.length; i++) {
        rowTotal++;
        if (monthToggles[i]) rowCount++;
      }
    }

    return rowTotal > 0 ? rowCount / rowTotal : 0.0;
  }

  @override
  Widget build(BuildContext context) {

    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("أنجازاتى"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.grey,
              actions: [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: "حذف البيانات",
                  onPressed: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("تأكيد الحذف"),
                      content: Text("هل تريد حذف كل البيانات؟"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text("لا"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text("نعم"),
                        ),
                      ],
                    ),
                  );
                  if (confirm) {
                    await _databaseService.close();
                    await deleteDatabaseIfExists();
                    setState(() {
                      _isLoading = true;
                    });
                    await _calculateStatistics(); // reload statistics after deletion
                  }
                },
              ),
            ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "نسبة التأملات المفتوحة حتى اليوم",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    BatteryWidget(
                      percentage: _percentage,
                    ),
                    SizedBox(height: 32),
                    // Extra batteries for القداس, الاجتماع, المذبح العائلى
                    Column(
                      children: List.generate(3, (index) {
                        String label = ["نسبة حضور القداس حتى اليوم", "نسبة حضور الاجتماع حتى اليوم", "نسبة ممارسة المذبح العائلى حتى اليوم"][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              BatteryWidget(
                                percentage: _rowPercentages[index],
                                height: 25,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// import 'package/material.dart';
// import 'package/battery_widget.dart'; // import the battery widget
// import 'package/database_service.dart';
// import 'package/loading.dart';

// class Statistics extends StatefulWidget {
// const Statistics({super.key});

// @override
// State createState() => _StatisticsState();
// }

// class _StatisticsState extends State {
// final DatabaseService _databaseService = DatabaseService.instance;

// bool _isLoading = true;
// double _percentage = 0.0;
// Map<int, List>? _togglesMap;

// List _rowPercentages = [0.0, 0.0, 0.0]; // القداس, الاجتماع, المذبح العائلى

// @override
// void initState() {
// super.initState();
// _calculateStatistics();
// }

// Future _calculateStatistics() async {
// final now = DateTime(2026, 5, 6);

// // 1️⃣ Opened days
// int openedDays = await _databaseService.getOpenedDaysUntil(now);

// // 2️⃣ Total days from 1-1-2026 until today
// final startDate = DateTime(2026, 1, 1);
// int totalDays = now.difference(startDate).inDays + 1;

// double percent = totalDays > 0 ? openedDays / totalDays : 0.0;

// // 3️⃣ Read all toggles up to current month
// Map<int, List<bool>> togglesMap = await _databaseService.getAllTogglesUpToMonth(now.month);

// // 4️⃣ Calculate row percentages
// List<double> rowPercentages = List.generate(3, (index) => calculateRowPercentageAllMonths(togglesMap, index, now.month));

// setState(() {
//   _percentage = percent;
//   _togglesMap = togglesMap;
//   _rowPercentages = rowPercentages;
//   _isLoading = false;
// });

// }

// // Get the first day of each week in the month
// List getWeeksInMonth(DateTime month, {int weekStart = DateTime.sunday}){
// List weeks = [];

// DateTime firstOfMonth = DateTime(month.year, month.month, 1);
// DateTime lastOfMonth = DateTime(month.year, month.month + 1, 0);

// DateTime currentWeekStart = firstOfMonth.subtract(Duration(days: (firstOfMonth.weekday - weekStart + 7) % 7));

// while (currentWeekStart.isBefore(lastOfMonth) || currentWeekStart.isAtSameMomentAs(lastOfMonth)) {
//   weeks.add(currentWeekStart);
//   currentWeekStart = currentWeekStart.add(Duration(days: 7));
// }

// return weeks;

// }

// double calculateRowPercentageAllMonths(Map<int, List> togglesMap, int rowIndex, int currentMonth) {

// int rowCount = 0;
// int rowTotal = 0;

// for (int month = 1; month <= currentMonth; month++) {
//   List<bool>? monthToggles = togglesMap[month];
//   if (monthToggles == null || monthToggles.isEmpty) continue;

//   final weeks = getWeeksInMonth(DateTime(2026, month, 1));
//   int columns = weeks.length;

//   int startIndex = rowIndex * columns;
//   if (startIndex != 0) startIndex++;
//   int endIndex = startIndex + columns;

//   for (int i = startIndex; i < endIndex && i < monthToggles.length; i++) {
//     rowTotal++;
//     if (monthToggles[i]) rowCount++;
//   }
// }

// return rowTotal > 0 ? rowCount / rowTotal : 0.0;

// }

// @override
// Widget build(BuildContext context) {

// return _isLoading
//     ? Loading()
//     : Scaffold(
//         appBar: AppBar(
//           title: Text("أنجازاتى"),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           backgroundColor: Colors.grey,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "نسبة الأيام المفتوحة حتى اليوم",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 16),
//                 BatteryWidget(
//                   percentage: _percentage,
//                   height: 40,
//                 ),
//                 SizedBox(height: 32),
//                 // Extra batteries for القداس, الاجتماع, المذبح العائلى
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: List.generate(3, (index) {
//                     String label = ["قداس", "اجتماع", "المذبح العائلى"][index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//                           SizedBox(height: 8),
//                           BatteryWidget(
//                             percentage: _rowPercentages[index],
//                             height: 25,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );

// }
// }