import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MonthlyData extends StatefulWidget {
  const MonthlyData({super.key});

  @override
  State<MonthlyData> createState() => _MonthlyDataState();
}

class _MonthlyDataState extends State<MonthlyData> {
  DateTime displayedMonth = DateTime.utc(2026, 1, 1);
  DateTime endMonth = DateTime.utc(2026,5,6);

  Map<int,List<bool>> toggles = {};

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


  void previousMonth() {
    if (displayedMonth.month > 1) {
      setState(() {
        displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
      });
    }
  }

  void nextMonth() {
    if (displayedMonth.month < 12 && displayedMonth.month < endMonth.month) {
      setState(() {
        displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
      });
    }
  }

  String intToArabic(dynamic n) {
    const english = "0123456789";
    const arabic  = "٠١٢٣٤٥٦٧٨٩";

    String s = n.toString();

    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }

    return s;
  }

  Future<File> _getTogglesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json'); // writable location
  }

  saveToggles(Map<int, List<bool>> toggles) async {
    final file = await _getTogglesFile();

    // Convert int keys → string keys
    final Map<String, dynamic> jsonReady = toggles.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    await file.writeAsString(jsonEncode(jsonReady));
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)?.settings.arguments as Map;

    Map<int, List<bool>>? toggles;
    if (args["toggles"] != null && args["toggles"] is Map<int, List<bool>>) {
      toggles = args["toggles"];
    } else {
      toggles = {}; // or default values
    }

    final weeks = getWeeksInMonth(displayedMonth);
    int totalCells = (weeks.length + 1) * 4; // 4 rows total
    List<bool> togglesList = List.generate(totalCells - (weeks.length + 1), (_) => false);
    if(toggles?[displayedMonth.month] == null){
      setState(() {
        toggles?[displayedMonth.month] = togglesList;
      });
    }

    int columns = weeks.length + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(intToArabic("${displayedMonth.year}-${displayedMonth.month.toString().padLeft(2, '0')}")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await saveToggles(toggles ?? {});
            Navigator.pushNamed(context, '/calendar_parent');
          },
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(onPressed: previousMonth, icon: const Icon(Icons.arrow_back)),
          IconButton(onPressed: nextMonth, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 1,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          // --------------------------
          // 1️⃣ HEADER ROW (week names)
          // --------------------------
          if (index < columns) {
            // First cell is empty
            if (index == columns-1) {
              return Center(child: Text(""));
            }

            return Center(
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, size: 28),
                  // const SizedBox(height: 8),
                  Text(                
                    intToArabic("${weeks[index].month.toString().padLeft(2, '0')}-${weeks[index].day.toString().padLeft(2, '0')}"),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // --------------------------
          // 2️⃣ TOGGLE BUTTONS BELOW
          // --------------------------

          if(index == columns*2 - 1 ){
            return Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text("حضور القداس",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
              )
            );
          }

          if(index == columns*3 - 1 ){
            return Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text("حضور الاجتماع",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
              )
            );
          }

          if(index == columns*4 - 1 ){
            return Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text("المذبح العائلى",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
              )
            );
          }

          int toggleIndex = index - columns;
          bool isOn = toggles?[displayedMonth.month]?[toggleIndex] ?? false;

          return Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: IconButton(
                  onPressed: () async{
                    setState((){
                      toggles?[displayedMonth.month]?[toggleIndex] = !(toggles[displayedMonth.month]?[toggleIndex] ?? true);
                    });
                    await saveToggles(toggles ?? {});
                  },
                  icon: Icon(isOn
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
                  color: isOn ? Colors.green : Colors.red,
                ),
              ),
          );
        },
      ),
    );

    // return Scaffold(
      // appBar: AppBar(
      //   title: Text("${displayedMonth.month.toString().padLeft(2, '0')}-${displayedMonth.year}"),
      //   actions: [
      //     IconButton(onPressed: previousMonth, icon: const Icon(Icons.arrow_back)),
      //     IconButton(onPressed: nextMonth, icon: const Icon(Icons.arrow_forward)),
      //   ],
      // ),
    //   body: 
    //   GridView.count(
    //     crossAxisCount: weeks.length+1, // number of columns
    //     children: List.generate(20, (index) {
    //       return Container(
    //         margin: EdgeInsets.all(8),
    //         color: Colors.blue[200],
    //         child: Center(
    //           child: Text('Item $index'),
    //         ),
    //       );
    //     }),
    //   )
      // SingleChildScrollView(
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Row(
      //         children: weeks.map((date) {
      //           return Container(
      //             width: MediaQuery.of(context).size.width * 0.13,
      //             margin: const EdgeInsets.all(8),
      //             padding: const EdgeInsets.all(12),
      //             decoration: BoxDecoration(
      //               // color: Colors.blue.shade100,
      //               borderRadius: BorderRadius.circular(12),
      //             ),
      //             child: Column(
      //               // mainAxisSize: MainAxisSize.min,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 const Icon(Icons.calendar_today, size: 28),
      //                 const SizedBox(height: 8),
      //                 Text(
      //                   "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}",
      //                   style: const TextStyle(fontSize: 10),
      //                 ),
      //                 IconButton(
      //                   onPressed: () {
      //                     // setState(() {
      //                     //   if (openedDaysItems.contains(date)) {
      //                     //     openedDaysItems.remove(date);
      //                     //   } else {
      //                     //     openedDaysItems.add(date);
      //                     //   }
      //                     // });
      //                   },
      //                   icon: Icon(
      //                   // openedDaysItems.contains(date)
      //                   //   ? Icons.radio_button_checked
      //                   //   : Icons.radio_button_unchecked,
      //                   Icons.radio_button_unchecked
      //                   ),
      //                   // color: openedDaysItems.contains(date)
      //                   //   ? Colors.green
      //                   //   : Colors.red,
      //                   color : Colors.red
      //                 ),
      //                 IconButton(
      //                   onPressed: () {
      //                     // setState(() {
      //                     //   if (openedDaysItems.contains(date)) {
      //                     //     openedDaysItems.remove(date);
      //                     //   } else {
      //                     //     openedDaysItems.add(date);
      //                     //   }
      //                     // });
      //                   },
      //                   icon: Icon(
      //                   // openedDaysItems.contains(date)
      //                   //   ? Icons.radio_button_checked
      //                   //   : Icons.radio_button_unchecked,
      //                   Icons.radio_button_unchecked
      //                   ),
      //                   // color: openedDaysItems.contains(date)
      //                   //   ? Colors.green
      //                   //   : Colors.red,
      //                   color : Colors.red
      //                 ),
      //                 IconButton(
      //                   onPressed: () {
      //                     // setState(() {
      //                     //   if (openedDaysItems.contains(date)) {
      //                     //     openedDaysItems.remove(date);
      //                     //   } else {
      //                     //     openedDaysItems.add(date);
      //                     //   }
      //                     // });
      //                   },
      //                   icon: Icon(
      //                   // openedDaysItems.contains(date)
      //                   //   ? Icons.radio_button_checked
      //                   //   : Icons.radio_button_unchecked,
      //                   Icons.radio_button_unchecked
      //                   ),
      //                   // color: openedDaysItems.contains(date)
      //                   //   ? Colors.green
      //                   //   : Colors.red,
      //                   color : Colors.red
      //                 ),
      //               ],
      //             ),
      //           );
      //         }).toList(),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.all(10),
      //         child: SizedBox(
      //           height: 10,
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
      //             // mainAxisSize: MainAxisSize.min,
      //             children: [
      //               const Text(
      //                 "data",
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                 ),
      //               ),
      //               const Text(
      //                 "data",
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                 ),
      //               ),
      //               const Text(
      //                 "data",
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                 ),
      //               ),
      //               const Text(
      //                 "data",
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    // );
  }
}
