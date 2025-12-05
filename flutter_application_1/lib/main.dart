import 'package:flutter/material.dart';
import 'package:flutter_application_1/calendar.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/landing_page.dart';
import 'package:flutter_application_1/manner.dart';
import 'package:flutter_application_1/monthly_data.dart';
import 'package:flutter_application_1/reading.dart';
import 'package:flutter_application_1/statistics.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LandingPage(),
    routes: {
      '/calendar': (context) => const Calendar(),
      '/reading': (context) => const Reading(),
      '/home': (context) => const Home(),
      '/monthly_data': (context) => const MonthlyData(),
      '/manner': (context) => const Manner(),
      '/statistics': (context) => const Statistics(),
    },
  ));
}