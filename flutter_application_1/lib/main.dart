// Add imports for desktop sqflite ffi initialization
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/calendar.dart';
import 'package:flutter_application_1/carlo.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/landing_page.dart';
import 'package:flutter_application_1/manner.dart';
import 'package:flutter_application_1/monthly_data.dart';
import 'package:flutter_application_1/reading.dart';
import 'package:flutter_application_1/statistics.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For desktop (Windows/Linux/Mac), initialize sqflite ffi and set the
  // global databaseFactory so the sqflite openDatabase/getDatabasesPath APIs work.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Readings',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/home': (context) => const Home(),
        '/calendar': (context) => const Calendar(),
        '/reading': (context) => const Reading(),
        '/monthly_data': (context) => const MonthlyData(),
        '/statistics': (context) => const Statistics(),
        '/manner': (context) => const Manner(),
        '/carlo': (context) => const FloatingCardsPage(),
      },
    );
  }
}
