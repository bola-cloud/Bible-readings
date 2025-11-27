import 'package:flutter/material.dart';
import 'package:flutter_application_1/calendar.dart';
import 'package:flutter_application_1/calendar_parent.dart';
import 'package:flutter_application_1/monthly_data.dart';
import 'package:flutter_application_1/reading.dart';

void main() {
  runApp(MaterialApp(
    home: CalanderParent(),
    routes: {
      '/calendar': (context) => const Calendar(),
      '/reading': (context) => const Reading(),
      '/calendar_parent': (context) => const CalanderParent(),
      '/monthly_data': (context) => const MonthlyData(),
    },
  ));
}

// class Sandbox extends StatelessWidget {
//   const Sandbox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sandbox'),
//         backgroundColor: Colors.grey,
//       ),
//       body: TableCalendar(
//         firstDay: DateTime.utc(2026, 1, 1),
//         lastDay: DateTime.utc(2026, 12, 31),
//         focusedDay: DateTime.now(),
//       )
//     );
//   }
// }